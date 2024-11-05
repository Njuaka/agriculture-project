import os
import pandas as pd
from pathlib import Path

def get_data_directory_path():
    """
    Get the relative path to the data directory.
    """

    DATA_DIR = os.environ.get('DATA_DIR')     # Check if DATA_DIR environment variable is set
    if DATA_DIR:
        
        return DATA_DIR                     # Use the directory path specified in the environment variable
    else:
        
        return os.path.dirname(os.path.dirname(__file__))  # Default to the local directory structure
     

DATA_DIR = get_data_directory_path()

PATH_RAIN_FILE = os.path.join(DATA_DIR, "data", "rain.csv")
NEW_RAIN_FILE = os.path.join(DATA_DIR, "data", "modified_rain.csv")
PATH_TEMPERATURE_FILE = os.path.join(DATA_DIR, "data", "temperature.csv")
PATH_PESTICIDE_FILE = os.path.join(DATA_DIR, "data", "pesticides_usage.csv")
PATH_YIELD_FILE  = os.path.join(DATA_DIR, "data", "yield.csv")
FIGURE_PATH = os.path.join(DATA_DIR, "output/")

