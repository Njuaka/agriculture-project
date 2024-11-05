import pandas as pd
import pytest
from pipeline.utils.constants import *
from pipeline.writer.writer import *
from pipeline.processors.processor import *
from pipeline.reader.reader import *

    
@pytest.mark.transform  
def test_transform_data():
    
    test_temp_data= read_temp_file()
    assert isinstance(test_temp_data, pd.DataFrame)
    
    test_data_transform= transform_data()
    assert isinstance(test_data_transform, pd.DataFrame)
    
