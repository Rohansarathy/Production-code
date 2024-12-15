import json
import psycopg2
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

driver = webdriver.Chrome()
driver.maximize_window()

with open(credentials_file, 'r') as file:
    credentials = json.load(file)

log_file = f"{credentials['Initiation_Logfile']}\\DT&BGV_{day}{month}{year}_{mint}_{sec}.txt"

login1_success = hireright_login(driver, credentials, log_file)

try:   
    if login1_success:
        print("*********************************Executing the Process********************************")
        with open(log_file, 'a') as log:
            log.write("*********************************Executing the Process*********************************\n")
        with open(log_file, 'a') as log:
            log.write(f"Bot Start time: {current_time}\n")
        print(f"Bot Start time: {current_time}")
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
                    WHERE status = 'Initiated' 
                    AND (hireright_status IS NULL OR hireright_status = '') 
                    AND (bgv_ticket_no IS NOT NULL AND bgv_ticket_no != '') 
                    AND bgv_status = 'pending'
                """
                cursor.execute(query)
                rows = cursor.fetchall()

                # cursor.execute(f"""SELECT * FROM public.onboarding WHERE ssn = '119664346'""")
                # rows = cursor.fetchall()

                all_data = []
                for row in rows:
                    data_dict = {column_names[i]: row[i] for i in range(len(column_names))}
                    all_data.append(data_dict)
                    cursor.execute("UPDATE public.onboarding SET hireright_initiation_date = %s WHERE ssn = %s", (current_time, data_dict['ssn']))
                    conn.commit()
                    if data_dict['middle_name']:
                        Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                    else:
                        Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
                    print(f"*********************************{Techname}********************************")
                    print(f"Processing for SSN: {data_dict['ssn']}")
                    with open(log_file, 'a') as log:
                        log.write(f"*********************************{Techname}*********************************\n")
                    try:
                        hireright_ticket(driver, data_dict, log_file, credentials, conn, cursor)
                    except Exception as e:
                        print(f"Execution failed")
                        with open(log_file, 'a') as log:
                            log.write(f"Execution failed\n")
                        if data_dict['middle_name']:
                            Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                        else:
                            Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
                        recipient_emails = credentials['Recipient']
                        cc_emails = ""
                        if data_dict['tax_term'] == "1099":
                            subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
                        else:
                            subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
                        body_message = f"HireRight Execution failed for {Techname}. Kindly check the issue."
                        body_message1  =  "" 
                        attachment_path = ""
                        try:
                            Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                            print("Mail sent Successfully for HireRight Execution failed")
                        except Exception as e:
                            print("Mail not sent Successfully for HireRight Execution failed") 
                             
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
                    print("*********************************Execution Completed*********************************")
                    with open(log_file, 'a') as log:
                        log.write(f"Bot Stop time: {Close_time}\n")
                        log.write("DB connection closed\n")
                        log.write("*********************************Execution Completed*********************************\n")
                except psycopg2.Error as e:
                    print("Error closing DB connection: ", e)
                    with open(log_file, 'a') as log:
                        log.write(f"Error closing DB connection\n")

    else:
        print("Hireright login failed")
        with open(log_file, 'a') as log:
            log.write("Hireright login failed\n")
        recipient_emails = credentials['Recipient']
        cc_emails = ""
        subject = f"Hireright login failed"
        body_message = f"Hireright login failed. Kindly check the issue."
        body_message1  =  "" 
        attachment_path = ""
        try:
            Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
            print("Mail sent Successfully for Hireright login failed")
        except Exception as e:
            print("Mail not sent Successfully for Hireright login failed")

except Exception as e:
    print(f"Execution failed")
    with open(log_file, 'a') as log:
        log_file.write("Execution failed\n")