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
directors =  [my_path_CCBIS, my_path_CCBISDW, my_path_cleaned]

# Set file names
log_fileName = time.strftime("%Y%m%d") + '_CCBIS.log'
audit_fileName = time.strftime("%Y%m%d") + '_CCBIS_audit.xlsx'

# Set log file
os.chdir(my_path)
LOG = logging.getLogger(log_fileName)
LOG.setLevel(logging.DEBUG)
# Create file handler which logs even debug messages
fh = logging.FileHandler(log_fileName, 'w') # 'w'-overwrite; 'a'-append
fh.setLevel(logging.INFO)
# Create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
# Create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s : [%(levelname)s] %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# Add the handlers to the logger
LOG.addHandler(fh)
LOG.addHandler(ch)

# Check path
if not os.path.exists(my_path):
    os.makedirs(my_path)
    LOG.info("Directory created: " + my_path)
# Clean log files
else:
    logExtension = ".log"
    auditExtension = '.xlsx'
    for root_folder, folders, files in os.walk(my_path):
        for file in files:
            file_path = os.path.join(root_folder, file)
            file_extension = os.path.splitext(file)[1]
            if file_extension == logExtension and file != log_fileName:
                if not os.remove(file_path):
                    LOG.info("File deleted successfully: " + file_path)
                else:
                    LOG.info("Unable to delete the " + file_path)
            if file_extension == auditExtension and file != audit_fileName:
                if not os.remove(file_path):
                    LOG.info("File deleted successfully: " + file_path)
                else:
                    LOG.info("Unable to delete the " + file_path)

# Create directors
for director in directors:
    if not os.path.exists(director):
        os.makedirs(director)
        LOG.debug('\nDirectory created: ' + director)

#=============================================================================
#=== Extract from CCBIS to CSV
#=============================================================================
LOG.info('==== Extract: from CCBIS(SQL Server) ====')
# Set up SQL Server connector
os.chdir(my_path_CCBIS)
sql_conn = pyodbc.connect('DRIVER={SQL Server}; SERVER=localhost; DATABASE=CCBIS; UID=sa; PWD=SQLServer2019')

# Get table name list
LOG.info('The tables are creating in ' + my_path_CCBIS + ':')
tables = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME != 'sysdiagrams'"
tbls = pandas.read_sql(tables, sql_conn)

for index, row in tbls.iterrows():
    tableName = row['TABLE_NAME']
    LOG.info('--' + str(index+1) + '. ' + tableName + '.csv')  
    # Read from SQL Server CCBIS
    query = "SELECT * FROM [dbo].[" + row['TABLE_NAME'] + "]"  
    df = pandas.read_sql(query, sql_conn)
    # Write to CCBIS/*.csv
    try:
        df.to_csv(my_path_CCBIS + "/" + tableName + '.csv', index=False)
    except:
        tb = sys.exc_info()[2]
        LOG.warn('**** File did NOT update successfully. Please try again after make sure file is not opened and have pomission to write. - ' + my_path_CCBIS + "/" + tableName + '.csv')
        continue

LOG.info('Extract Completed Successfully - ' + str(len(os.listdir('.'))) + ' files created in ' + my_path_CCBIS)  

#=============================================================================
#=== Cleaning: duplication, missing, outline
#=============================================================================

# Cleaning
os.chdir(my_path_CCBIS)
#colours = ['#000099', '#ffff00'] # specify the colours - yellow is missing. blue is not missing.
LOG.info("==== Cleaning Start ====")
for file in glob.glob("*.csv"):
    tableName = str(file)[:-4]    
    cleanFile = tableName + "_clean.csv"   

    # Get PK
    pkNameQuery = "SELECT Col.Column_Name as PkName from INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col WHERE Col.Constraint_Name = Tab.Constraint_Name AND Col.Table_Name = Tab.Table_Name AND Constraint_Type = 'PRIMARY KEY' AND Col.Table_Name = '" + tableName +"'"
    pkList = list(pandas.read_sql(pkNameQuery, sql_conn)["PkName"])

    # Get data
    df = pandas.read_csv(file, index_col = pkList)
    size_org = df.shape[0]
    cols = df.columns
    LOG.info('From: ' + file + ' - size' + str(df.shape))

    # Drop duplicate
    df.drop_duplicates(keep="first", inplace=True)

    # Print duplication info
    size_cleaned = df.shape[0]
    LOG.info('To    : ' + cleanFile + ' - size' + str(df.shape))
    num_duplication = size_org - size_cleaned
    if num_duplication > 0:
        LOG.info('------ [Duplication] ' + str(num_duplication) + ' records dropped from ' + file)
    
    # Set numeric columns
    df_numeric = df.select_dtypes(include=[np.number])
    numeric_cols = df_numeric.columns.values
   
    # Set non numeric columns
    df_non_numeric = df.select_dtypes(exclude=[np.number])
    non_numeric_cols = df_non_numeric.columns.values

    for col in df.columns:
        # cleaning missing
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
                LOG.info('------ [Missing] ' + file + ' - "{}" - {}%'.format(col, round(pct_missing*100)) + ', ' + str(num_missing) + ' records missed - filling with ' + str(med))
            # When not numeric, fill with most frequent value     
            else:
                top = df[col].describe()['top'] # impute with the most frequent value.
                df[col] = df[col].fillna(top)
                LOG.info('------ [Missing] ' + file + ' - "{}" - {}%'.format(col, round(pct_missing*100)) + ', ' + str(num_missing) + ' records missed - filling with "' + top + '"')

        # cleaning outliner
        #df.boxplot(column=col)

    # write to the new csf in 'cleaned' director
    try:
        df.to_csv(my_path_cleaned + "/" + cleanFile)
    except:
        tb = sys.exc_info()[2]
        LOG.warn('**** File did NOT update successfully. Please try again after make sure file is not opened and have pomission to write. - ' + my_path_cleaned + "/" + cleanFile)
        continue

    os.chdir(my_path_CCBIS)

LOG.info('Cleaning Completed Successfully - ' + str(len(os.listdir(my_path_cleaned))) + ' files created in ' + my_path_cleaned)    

#=============================================================================
#=== Transfer
#=============================================================================