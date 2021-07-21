#=============================================================================
#=== Install and import necessary modules
#=============================================================================
from import_neccessary_modules import *
modules = ['os', 'pandas', 'pyodbc', 'numpy', 'glob', 'seaborn', 'matplotlib', 'logging', 'time']
for module in modules:
    import_neccessary_modules(module)

import os
import pandas
import pyodbc
import numpy as np
import glob
import seaborn as sns
import matplotlib.pyplot as plt
import logging
import time
#=============================================================================
#=== Set path and config
#=============================================================================

# Set path
my_path = r"C:\MyDataFiles\Data_CCBIS_202107"
my_path_CCBIS = my_path + "\CCBIS"
my_path_CCBISDW = my_path + "\CCBISDW"
my_path_cleaned = my_path + "\cleaned"

# Set file name
log_fileName = time.strftime("%Y%m%d") + '_CCBIS.log'

# Set log file
os.chdir(my_path)
LOG = logging.getLogger(log_fileName)
LOG.setLevel(logging.DEBUG)
# create file handler which logs even debug messages
fh = logging.FileHandler(log_fileName, 'w') # 'w'-overwrite; 'a'-append
fh.setLevel(logging.INFO)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s:[%(levelname)s] %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add the handlers to the logger
LOG.addHandler(fh)
LOG.addHandler(ch)


# Create directors
directors =  [my_path_CCBIS, my_path_CCBISDW, my_path_cleaned]
for director in directors:
    if not os.path.exists(director):
        os.makedirs(director)
        LOG.debug('\nDirectory created: ' + director)

#=============================================================================
#=== Extract from CCBIS to CSV
#=============================================================================

#Set up SQL Server connector
os.chdir(my_path_CCBIS)
sql_conn = pyodbc.connect('DRIVER={SQL Server}; SERVER=localhost; DATABASE=CCBIS; UID=sa; PWD=SQLServer2019')

#Let's do a test to see if we can extract data
query = "SELECT * FROM [dbo].[Dimagent]"
df = pandas.read_sql(query,sql_conn)
df.head(3)

# get table name list
tables = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME != 'sysdiagrams'"
tbls = pandas.read_sql(tables, sql_conn)
tbls.head(20)

LOG.debug('The tables are creating in ' + my_path_CCBIS + ':')
for index, row in tbls.iterrows():
    tableName = row['TABLE_NAME']
    query = "SELECT * FROM [dbo].[" + row['TABLE_NAME'] + "]"  
    df = pandas.read_sql(query, sql_conn)
    df.to_csv(my_path_CCBIS + "/" + tableName + '.csv', index=False)
    LOG.debug('--' + tableName)

LOG.info('==== Extract Completed Successfully - ' + str(len(os.listdir('.'))) + ' files created in ' + my_path_CCBIS)  

#=============================================================================
#=== Cleaning: duplication, missing, outline
#=============================================================================

# Cleaning
os.chdir(my_path_CCBIS)
colours = ['#000099', '#ffff00'] # specify the colours - yellow is missing. blue is not missing.
LOG.debug("==== Cleaning Start ====")
for file in glob.glob("*.csv"):

    # get file
    df = pandas.read_csv(file)
    size_org = df.size
    LOG.debug('From: ' + file + str(df.shape))

    # drop duplicate
    df.drop_duplicates(keep="first", inplace=True)
    size_cleaned = df.size
    num_duplication = size_cleaned - size_org
    if num_duplication > 0:
        LOG.info('--[Duplication] ' + str(num_duplication) + ' records dropped from ' + file)
    
    # set numeric columns
    df_numeric = df.select_dtypes(include=[np.number])
    numeric_cols = df_numeric.columns.values
   
    # set non numeric columns
    df_non_numeric = df.select_dtypes(exclude=[np.number])
    non_numeric_cols = df_non_numeric.columns.values

    for col in df.columns:
        missing = df[col].isnull()
        num_missing = np.sum(missing)
        pct_missing = np.mean(missing)
             
        if num_missing > 0: 

            # Print Missing Data Percentage List - % of missing.
            df['{}_ismissing'.format(col)] = missing

            # When numeric, fill with midian value 
            if col in numeric_cols:
                med = df[col].median()
                df[col] = df[col].fillna(med)
                LOG.info('[Missing] ' + file + ' {} - {}%'.format(col, round(pct_missing*100)) + ', ' + str(num_missing) + ' records missing - filled with ' + str(med))
            # When not numeric, fill with most frequent value     
            else:
                top = df[col].describe()['top'] # impute with the most frequent value.
                df[col] = df[col].fillna(top)
                LOG.info('[Missing] ' + file + ' {} - {}%'.format(col, round(pct_missing*100)) + ', ' + str(num_missing) + ' records missing - filled with "' + top + '"')

    # set new file path
    dataFileName = file
    dataFileName_new = str(dataFileName)[:-4] + "_clean.csv"
    os.chdir(my_path_cleaned)
    file = dataFileName_new

    # write to the new csf in 'cleaned' director
    df.to_csv(file, index=False) 
    LOG.debug('To:   ' + file + str(df.shape))

    os.chdir(my_path_CCBIS)

LOG.info('==== Cleaning Completed Successfully - ' + str(len(os.listdir(my_path_cleaned))) + ' files created in ' + my_path_cleaned)    