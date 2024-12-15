import os
from robot.api.deco import keyword

@keyword
def move_and_rename_files_based_on_keyword(keyword, source_folder, target_folder, new_name_pattern):
    files = os.listdir(source_folder)
    moved_files = []
    for file in files:
        if keyword.lower() in file.lower():
            try:
                # Define new file name based on the pattern
                new_name = new_name_pattern.format(keyword=keyword)
                
                # Original and new paths
                src_path = os.path.join(source_folder, file)
                dst_path = os.path.join(target_folder, new_name)
                
                # Rename and move the file
                os.rename(src_path, dst_path)
                moved_files.append(new_name)
            except Exception as e:
                print(f"Error moving file {file}: {e}")
    return moved_files
