import pyodbc

def get_conn():
    return pyodbc.connect(
        "Driver={ODBC Driver 17 for SQL Server};"
       "Server=localhost;Database=MovieDB;Trusted_Connection=yes;"
    )