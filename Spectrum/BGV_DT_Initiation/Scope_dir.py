import os
import shutil
import tempfile
import time
import psutil

def cleanup_temp_items(directories=None, retries=3, wait_time=5):
    if directories is None:
        directories = [
            tempfile.gettempdir(),        # Default system TEMP directory
            r"C:\Windows\SystemTemp"     # Additional directory to clean
        ]

    deleted_items = []
    failed_items = []

    # Ensure all Chrome processes are terminated
    for process in psutil.process_iter():
        try:
            # if process.name() == "chrome.exe" or process.name() == "chromedriver.exe":
            if process.name() == "chromedriver.exe":
                process.terminate()
                print(f"Terminated: {process.name()} (pid={process.pid})")
        except psutil.NoSuchProcess:
            print(f"Process no longer exists (pid={process.pid})")
        except Exception as e:
            print(f"Failed to terminate process {process.pid}: {e}")

    # Retry logic for cleanup
    for attempt in range(retries):
        for temp_dir in directories:
            for item in os.listdir(temp_dir):
                item_path = os.path.join(temp_dir, item)

                if item.startswith("scoped_"):
                    try:
                        if os.path.isdir(item_path):
                            shutil.rmtree(item_path)
                        else:
                            os.remove(item_path)
                        print(f"Deleted: {item_path}")
                        deleted_items.append(item_path)
                    except Exception as e:
                        print(f"Failed to delete {item_path} on attempt {attempt + 1}: {e}")
                        failed_items.append(item_path)

        if not failed_items:
            break

        time.sleep(wait_time)

    # Final attempt to remove any remaining failed items
    for item_path in failed_items:
        try:
            if os.path.isdir(item_path):
                shutil.rmtree(item_path)
            else:
                os.remove(item_path)
            print(f"Deleted on final attempt: {item_path}")
        except Exception as e:
            print(f"Still failed to delete {item_path}: {e}")

    return deleted_items

# Optional: If you
