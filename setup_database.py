import sqlite3
import pandas as pd

# 1. Load your CSV data
df = pd.read_csv('user_events.csv')

# 2. Connect to a NEW, clean SQLite database
# This creates 'my_project.sqlite' if it doesn't exist
conn = sqlite3.connect('my_project.sqlite')

# 3. Write the data to a table called 'user_events'
# 'if_exists=replace' ensures the table is fresh if you run this again
df.to_sql('user_events', conn, if_exists='replace', index=False)

# 4. Close the connection
conn.close()

print("Database 'my_project.sqlite' created successfully with your data!")