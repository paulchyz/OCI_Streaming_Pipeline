import os
import glob
json_path_list = glob.glob(f"/Users/scacela/Downloads/*.zip")
json_path = json_path_list[0]
print("\nTEST\n")
print(json_path)
print("\nTEST2\n")
print(json_path_list)
print("\nTEST3\n")
dirname = os.path.dirname(os.path.abspath(__file__))
print(dirname)
