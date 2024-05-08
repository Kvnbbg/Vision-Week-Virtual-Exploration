import pandas as pd

# Assuming you have a connection to your database established
employees_df = pd.read_sql_query("SELECT name, salary FROM Employees", connection)

# Access the name and salary columns
names = employees_df["name"]
salaries = employees_df["salary"]
