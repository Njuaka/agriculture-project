import pandas as pd
import pycountry
import pycountry_convert as pc
from typing import Dict
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split



class InitialPreprocessingData:
    
    def __init__(self, df, df1) -> None:
        self.df = df
        self.df1 = df1  
        
    def rename_columns(self, list_columns: Dict[str, str]):
        '''
        this function helps rename the columns Country and Year
        for rain dataset to ease merging of the data
        '''
        self.df1.rename(columns=list_columns, inplace=True)
        
        return self.df1

    def replace_value(self, column, value, new_value):
        '''
        this function permit the modification of country value
        cote d'Ivoire for the temperature dataset
        '''
        
        self.df[column] = self.df[column].replace(value, new_value)
        
        return self.df



def merge_data(df1, df2, list_columns):
    '''
    the combine all the data by mering with id country
    and year
    '''
    return pd.merge(df1, df2, on=list_columns, how='inner')



class FinalDataColumns:
    
    def __init__(self, df1):

        self.df1 = df1
              
    def select_columns(self, columns):
        '''
        select specific columns of interest from the merged data
        
        Returns:
        a dataframe with only selected columns of interest
        '''
        
        if not all(col in self.df1.columns for col in columns):
            raise ValueError("one or more columns are not in dF")
        
        return self.df1[columns]


class renamedCombinedData:
    
    def __init__(self, df2):
        self.df2 = df2
    
    def rename_final_raw_data_columns(self, columns_mapping):
        """
        Rename columns in a dataframe
        """
        # Vectorized operation to replace column names
        new_columns = self.df2.columns.to_series().replace(columns_mapping)
        
        self.df2.columns = new_columns
        
        return self.df2


class TranformRawData:
    
    def __init__(self, df: pd.DataFrame, column_name: str) -> None:
        self.df = df
        self.column_name = column_name
    
    def get_continent(self, country_name):
        
        try:
            # Get the ISO alpha-2 code of the country
            country_code = pycountry.countries.lookup(country_name).alpha_2
            # Get the continent code from country code
            continent_code = pc.country_alpha2_to_continent_code(country_code)
            # Convert continent code to continent name
            continent_name = pc.convert_continent_code_to_continent_name(continent_code)
            return continent_name
        except:
            return None
        
    def map_continent(self):
     # Apply the get_continent function to map countries to continents
        self.df = self.df.assign(Continent=self.df['Country'].apply(self.get_continent))
        #print(self.df.head())
        return self.df
        
    

    def replace_column_data(self) -> pd.DataFrame:
        """
        Replace '..' with '0' in the specified column and convert the column to integers.
        """
        if self.column_name not in self.df.columns:
            raise ValueError(f"The column '{self.column_name}' is not in the DataFrame.")
        
        self.df.loc[self.df[self.column_name] == '..', self.column_name] = '0'
        
        
        self.df.loc[:, self.column_name] = self.df[self.column_name].astype(int)     # Conversion
        
        return self.df


class RfPredictionModel:
    
    def __init__(self, data, features_column, target_column):
        self.data = data
        self.target_column = target_column
        self.features_column = features_column
        self.test_size = 0.3
        self.random_state = 0
        self.model = None
        self.X_train, self.X_test, self.y_train, self.y_test = None, None, None, None
        self.y_pred = None
        self.mse = None
        self.score = None
        self.feature_importance = None

    def train_and_evaluate(self):
        
        X = self.data[self.features_column]    
        y = self.data[self.target_column]

        # Split the dataset into training and testing sets
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            X, y, test_size=self.test_size, random_state=self.random_state)

        #print(f"Training and testing shapes: {self.X_train.shape}, {self.X_test.shape}, {self.y_train.shape}, {self.y_test.shape}")

        # Build and fit the RandomForestRegressor model
        self.model = RandomForestRegressor(random_state=self.random_state)
        self.model.fit(self.X_train, self.y_train)

        # Predict and evaluate the model on the test set
        self.y_pred = self.model.predict(self.X_test)
        self.score = self.model.score(self.X_test, self.y_test)
        self.mse = mean_squared_error(self.y_test, self.y_pred)
        self.feature_importance = self.model.feature_importances_

    def get_model_results(self):
        return {
            'X_train': self.X_train,
            'X_test': self.X_test,
            'y_train': self.y_train,
            'y_test': self.y_test,
            'y_pred': self.y_pred,
            'feature_importance': self.feature_importance
        }