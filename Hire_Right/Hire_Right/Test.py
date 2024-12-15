import json
import psycopg2
import time
from datetime import datetime
from selenium import webdriver
from Sendmail import Sendmail
from HirerightLogin import hireright_login
from HireRight_Ticket import hireright_ticket


current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print(f"{current_time}")

# Extract date and time components
year = current_time[0:4]
month = current_time[5:7]
day = current_time[8:10]
mint = current_time[11:13]
sec = current_time[14:16]

credentials_file = 'Hirerightcredentials.json'

# driver = webdriver.Chrome()
# driver.maximize_window()

try:
    with open(credentials_file, 'r') as file:
        credentials = json.load(file)

    log_file = f"{credentials['Initiation_Logfile']}\\DT&BGV_{day}{month}{year}_{mint}_{sec}.txt"
    
    with open(log_file, 'a') as log:
        log.write("*********************************Executing the Process*********************************\n")
    with open(log_file, 'a') as log:
        log.write(f"Bot Start time: {current_time}\n")
        
    # login1_success = hireright_login(driver, credentials, log_file)
    
    # if login1_success:
        try:
            conn = psycopg2.connect(
            dbname=credentials['DB_NAME'],
            user=credentials['DB_USERNAME'],
            password=credentials['DB_PASSWORD'],
            host=credentials['DB_HOST'],
            port=credentials['DB_PORT']
            )
            print("DB Connected")
            with open(log_file, 'a') as log:
                log.write("DB Connected\n")

            with conn.cursor() as cursor:
                # Get column names
                cursor.execute(
                    "SELECT column_name FROM information_schema.columns WHERE table_name = 'onboarding' AND table_schema = 'public'"
                )
                columns = cursor.fetchall()
                column_names = [col[0] for col in columns]

                select_columns = ', '.join(column_names)

                query = """
                    SELECT * 
                    FROM public.onboarding 
                    WHERE ssn= '512497494'
                """
                cursor.execute(query)
                rows = cursor.fetchall()

                all_data = []
                for row in rows:
                    data_dict = {column_names[i]: row[i] for i in range(len(column_names))}
                    all_data.append(data_dict)
                    print(f"Processing for SSN: {data_dict['first_name']} {data_dict['last_name']}")
                    if data_dict['middle_name']:
                        Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                    else:
                        Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
                    if data_dict['tax_term'] == "1099":
                        subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
                    else:
                        subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
                    recipient_emails = data_dict['hr_coordinator']
                    cc_emails = f"{credentials['HireRight_team']},{credentials['Recipient']}"
                    body_message = f"I hope you're doing well. Could you please get the consent form for {Techname} and share with HireRight team to upload for BG processing."
                    body_message1  =  "" 
                    attachment_path = ""
                    try:
                        Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                        print("Mail sent Successfully for consent form")
                    except Exception as e:
                        print("Mail not sent Successfully for consent form")
                    
        except psycopg2.Error as e:
            print("Error connecting to database")
            with open(log_file, 'a') as log:
                log.write("Error connecting to database\n")
        finally:
            if conn:
                try:
                    # Close the database connection
                    conn.close()
                    print("DB connection closed")
                    Close_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    print(f"{Close_time}")
                    with open(log_file, 'a') as log:
                        log.write(f"Bot Stop time: {Close_time}\n")
                        log.write("DB connection closed\n")
                        log.write("*********************************Executing Completed*********************************\n")
                except psycopg2.Error as e:
                    print("Error closing DB connection: ", e)
                    with open(log_file, 'a') as log:
                        log.write(f"Error closing DB connection: {e}\n")

    # else:
    #     print("Hireright login failed")
    #     with open(log_file, 'a') as log:
    #         log.write("Hireright login failed\n")
    #     recipient_emails = credentials['Recipient']
    #     cc_emails = ""
    #     subject = f"Hireright login failed"
    #     body_message = f"Hireright login failed. Kindly check the issue."
    #     body_message1  =  "" 
    #     attachment_path = ""
    #     try:
    #         Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
    #         print("Mail sent Successfully for Hireright login failed")
    #         with open(log_file, 'a') as log:
    #             log_file.write(f"Mail sent Successfully for Hireright login failed\n")
    #     except Exception as e:
    #         print("Mail not sent Successfully for Hireright login failed")
    #         with open(log_file, 'a') as log:
    #             log_file.write("Mail not sent Successfully for Hireright login failed\n")

except Exception as e:
    print("Execution failed")
    with open(log_file, 'a') as log:
        log_file.write("Execution failed\n")
    recipient_emails = credentials['Recipient']
    cc_emails = ""
    subject = f"HireRight Execution failed"
    body_message = f"HireRight Execution failed. Kindly check the issue."
    body_message1  =  "" 
    attachment_path = ""
    try:
        Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
        print("Mail sent Successfully for HireRight Execution failed")
        with open(log_file, 'a') as log:
            log_file.write(f"Mail sent Successfully for HireRight Execution failed\n")
    except Exception as e:
        print("Mail not sent Successfully for HireRight Execution failed")
        with open(log_file, 'a') as log:
            log_file.write("Mail not sent Successfully for HireRight Execution failed\n")

# finally:
#     driver.quit()