import pandas as pd
import os

file_path = r'c:\Users\abhis\Workspace\backend\OT-Scheduler\data\FlutterExcel (2).xlsx'

if os.path.exists(file_path):
    try:
        df = pd.read_excel(file_path)
        for col in df.columns:
            print(col)
    except Exception as e:
        print(f"Error reading file: {e}")
else:
    print(f"File not found at {file_path}")
