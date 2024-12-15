import psutil

def is_process_running(pid):
    try:
        ps = psutil.Process(pid)
        ps.name()  # Just to check if the process is alive
        return True
    except psutil.NoSuchProcess:
        return False


# # Replace with your code logic or list of PIDs
# pids = [12340, 5678, 91011]  # Example list of process IDs

# for pid in pids:
#     try:
#         # Attempt to create a Process object for the PID
#         ps = psutil.Process(pid)
#         name = ps.name()  # Get the name of the process
#     except psutil.NoSuchProcess:
#         # Catch the error if the process no longer exists
#         pass  # You can log or handle this as needed
#     else:
#         # If no exception, proceed with your logic
#         if "target_process_name" in name:  # Replace with your condition
#             print(f"{name} running with PID: {pid}")
