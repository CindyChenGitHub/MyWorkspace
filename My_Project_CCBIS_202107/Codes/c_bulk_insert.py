""" 
    Name:           c_bulk_insert.py
    Author:         Randy Runtsch
    Date:           March 17, 2021
    Description:    This module contains the c_bulk_insert class that connect to a SQL Server database
                    and executes the BULK INSERT utility to insert data from a CSV file into a table.
    Prerequisites:  1. Create the database data table.
                    2. Create the database update_csv_log table.
"""
import pyodbc
class c_bulk_insert:
    def __init__(self, csv_file_nm, sql_server_nm, db_nm, db_table_nm):
        # Connect to the database, perform the insert, and update the log table.
        conn = self.connect_db(sql_server_nm, db_nm)
        self.insert_data(conn, csv_file_nm, db_table_nm)
        conn.close
    def connect_db(self, sql_server_nm, db_nm):
        # Connect to the server and database with Windows authentication.
        conn_string = 'DRIVER={SQL Server};SERVER=' + sql_server_nm + ';DATABASE=' + db_nm + ';Trusted_Connection=yes;'
        conn = pyodbc.connect(conn_string)
        return conn
    def insert_data(self, conn, csv_file_nm, db_table_nm):
        # Insert the data from the CSV file into the database table.
        # Assemble the BULK INSERT query. Be sure to skip the header row by specifying FIRSTROW = 2.
        qry = "BULK INSERT " + db_table_nm + " FROM '" + csv_file_nm + "' WITH (FORMAT = 'CSV', FIRSTROW = 2)"
        # Execute the query
        cursor = conn.cursor()
        success = cursor.execute(qry)
        conn.commit()
        cursor.close