import re
import time
from datetime import datetime
from Sendmail import Sendmail
from datetime import datetime, timedelta
from difflib import SequenceMatcher
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def hireright_ticket(driver, data_dict, log_file, credentials, conn, cursor):

    print("HireRight_Ticket")
    with open(log_file, 'a') as log:
        log.write("HireRight_Ticket-Initiating\n")

    def slow_typing(element, text, delay=0.0):
        for char in text:
            element.send_keys(char)
            time.sleep(delay)

    for attempt in range(3):
        try:
            driver.refresh()
            time.sleep(3)
            WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.TAG_NAME, 'body')))
            Techsearch = WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.NAME, 'txtSearch')))
            break
        except Exception as e:
            print(f"Retrying... Attempt {attempt + 1}")
            with open(log_file, 'a') as log:
                log.write(f"Retrying... Attempt {attempt + 1}\n")
            if attempt == 2:
                print(f"Failed to find search box for SSN: {data_dict['ssn']}")
                with open(log_file, 'a') as log:
                    log.write(f"Failed to find search box for SSN: {data_dict['ssn']}\n")
                # # Optionally capture screenshot for troubleshooting
                # driver.save_screenshot(f"screenshot_{data_dict['ssn']}.png")
                return
    
    time.sleep(1)
    slow_typing(Techsearch, f"{data_dict['last_name']}")
    time.sleep(2)
    driver.find_element(By.XPATH, '//*[@id="_jsx_0_r"]/div').click()
    print("Searching")
    time.sleep(3)
    element2 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "_jsx_0_cv")))
    time.sleep(2)
    rows = element2.find_elements(By.TAG_NAME, "tr")

    # Initialize the flags
    row_flag = False
    proceed_flag = True

    # Check if there are rows in the table
    if len(rows) <= 1:
        print("No rows found")
        row_flag = True
    else:
        current_date = datetime.now()
        twelve_months_ago = current_date - timedelta(days=365)

        for i, row_elem in enumerate(rows):
            if i == 0:
                continue

            cells = row_elem.find_elements(By.TAG_NAME, "td")
            if len(cells) >= 10:
                first_name = cells[2].text.strip().lower()
                middle_name = cells[3].text.strip().lower()
                last_name = cells[4].text.strip().lower()
                status = cells[7].text.strip().lower()

                if first_name == data_dict['first_name'].lower() and last_name == data_dict['last_name'].lower():
                    if data_dict['middle_name']:
                        if middle_name == data_dict['middle_name'].lower():
                            is_name_matched = True
                        else:
                            is_name_matched = False
                    else:
                        is_name_matched = True

                    if is_name_matched:
                        try:
                            request_date_div = cells[9].find_element(By.CSS_SELECTOR, "div.jsx30matrixcolumn_cell_value")
                            time.sleep(1)
                            request_date_text = request_date_div.get_attribute('innerText').strip()

                            print(f"Row {i+1}, Cell 10 (Request Date): {request_date_text}")
                            print(f"Row {i+1}, Status: {status}")

                            if request_date_text:
                                request_date = datetime.strptime(request_date_text, "%b %d, %Y")
                                if request_date >= twelve_months_ago and ('completed' in status):
                                # if request_date >= twelve_months_ago and ('completed' in status or 'cancelled' in status):
                                    proceed_flag = False
                                    with open(log_file, 'a') as log:
                                        log.write("Tech Search: Do not proceed - recent 'Completed' or 'Cancelled' status found\n")
                                    break
                            else:
                                print(f"Row {i+1}, Cell 10 (Request Date) is empty")
                                with open(log_file, 'a') as log:
                                    log.write(f"Row {i+1}, Cell 10 (Request Date) is empty\n")
                        except ValueError:
                            print(f"Row {i+1}, Cell 10 (Request Date) has an invalid date format: {request_date_text}")
                            with open(log_file, 'a') as log:
                                log.write(f"Row {i+1}, Cell 10 (Request Date) has an invalid date format: {request_date_text}\n")
                        except Exception as e:
                            print(f"Row {i+1}, Cell 10 (Request Date) encountered an error: {e}")
                            with open(log_file, 'a') as log:
                                log.write(f"Row {i+1}, Cell 10 (Request Date) encountered an error: {e}\n")
                    else:
                        print(f"Row {i+1} does not match the first name '{data_dict['first_name']}', middle name '{data_dict['middle_name']}', and last name '{data_dict['last_name']}'")
                else:
                    print(f"Row {i+1} does not match the first name '{data_dict['first_name']}' and last name '{data_dict['last_name']}'")
        time.sleep(2)
        
    # close_button = WebDriverWait(driver, 10).until(
    #     EC.element_to_be_clickable((By.CSS_SELECTOR, 'span.jsx30block span[onclick^="jsx3.dl"][id^="_jsx_0_c6"]')))
    # close_button.click()
    close_button = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, "(//span[@label='CloseButtonContainer'])[1]"))
    )
    close_button.click()
    time.sleep(1)

    #New Request
    if row_flag or proceed_flag:
        element = WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, '//img[@title="Start new request" and @alt=""]')))
        driver.execute_script("arguments[0].scrollIntoView(true);", element)
        WebDriverWait(driver, 2).until(EC.visibility_of(element))
        driver.execute_script("arguments[0].click();", element)
        print("Clicked the 'Start new request' button.")
        with open(log_file, 'a') as log:
            log.write("Start new request\n")
        time.sleep(2)

        try:
            element = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, "//div[@class='new-order-dropdown']//a[contains(text(), 'All Products and Packages')]")))
            element.click()
            time.sleep(2)
            print("All Products and Packages Element selected")
        except:
            print("All Products and Packages Element not found or not clickable")
                
        # Switch to the iframe   
        iframe = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CSS_SELECTOR, "iframe[src*='order_form']")))
        driver.switch_to.frame(iframe)
        print("Iframe Selected") 
        time.sleep(2)

        max_attempts = 3
        pc_found = False

        for attempt in range(max_attempts):
            try:
                select_link = WebDriverWait(driver, 20).until(
                    EC.presence_of_element_located((By.XPATH, '//*[@id="job_location_toolbar_section_select_btn"]'))
                )
                select_link.click()
                print("Selecting the new click")
                time.sleep(2)
                
                print(f"PC={data_dict['pc_number']}")
                search = WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.XPATH, '//*[@id="job_location_grid_section_filter"]'))
                )
                search.clear()
                slow_typing(search, f"{data_dict['pc_number']}")
                time.sleep(2)
                
                table = WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.ID, "table_job_locations"))
                )
                rows = table.find_elements(By.XPATH, ".//tr[contains(@class, 'jqgrow')]")
                # pattern = re.compile(rf"\bPC[-\s]?{data_dict['pc_number']}\b", re.IGNORECASE)
                pattern = re.compile(rf"\bPC[-\s]*{data_dict['pc_number']}\b", re.IGNORECASE)
                for row in rows:
                    nick_name_cell = row.find_element(By.XPATH, ".//td[@aria-describedby='table_job_locations_nickName']")
                    print(f"Row text: {nick_name_cell.text.strip()}")
                    if pattern.search(nick_name_cell.text.strip()):
                        print(f"Match found for: {nick_name_cell.text.strip()}")
                        select_link = row.find_element(By.XPATH, ".//a[@class='gridLink']")
                        select_link.click()
                        with open(log_file, 'a') as log:
                            log.write(f"PC:{data_dict['pc_number']} found and Clicked\n")
                        pc_found = True
                        time.sleep(2)
                        break
                    else:
                        print(f"PC-{data_dict['pc_number']} not found in the table")
                
                if pc_found:
                    # Verify if the correct PC is selected
                    selected_pc_info = WebDriverWait(driver, 10).until(
                        EC.presence_of_element_located((By.XPATH, '//*[@id="selected_job_location_info_section"]'))
                    ).text
                    
                    if data_dict['pc_number'].lower() in selected_pc_info.lower():
                        print("Correct PC selected")
                        with open(log_file, 'a') as log:
                            log.write("Correct PC selected\n")
                        break
                    else:
                        print("Incorrect PC selected, retrying...")
                        time.sleep(2)
                else:
                    print(f"PC-{data_dict['pc_number']} not found in the table, retrying...")
                    time.sleep(2)
            except Exception as e:
                print("An error occurred: while selecting PC")
                with open(log_file, 'a') as log:
                    log.write(f"An error occurred: while selecting PC\n")
                time.sleep(2)
            finally:
                if pc_found:
                    break
        if not pc_found:
            print("Maximum attempts reached. PC not found.")
            with open(log_file, 'a') as log:
                log.write("Maximum attempts reached. PC not found.\n")
            if data_dict['middle_name']:
                Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
            else:
                Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
            recipient_emails = credentials['Recipient']
            cc_emails = "ldevi@i-t-g.net"
            if data_dict['tax_term'] == "1099":
                subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
            else:
                subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
            body_message = f"PC not found for {Techname} in HireRight. Kindly check the issue."
            body_message1  =  "" 
            attachment_path = ""
            try:
                Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                print("Mail sent Successfully for PC not found in HireRight")
            except Exception as e:
                print("Mail not sent Successfully for PC not found in HireRight")
        else:
            button1 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
            button1.click()
            time.sleep(3)
                    
            dropdown = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="productBundleSelect"]')))
            desired_option = dropdown.find_element(By.XPATH, '//*[@id="productBundleSelect"]/option[2]')
            desired_option.click()
            time.sleep(8)
            try:
                button2 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
                button2.click()
            except:
                try:
                    but2 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="order_conf_title"]')))
                    but2.click()
                    button2 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
                    button2.click()
                except:    
                    button2 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
                    button2.click()
            finally:
                time.sleep(3)
                    
            button3 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
            button3.click()
            time.sleep(3)

            max_attempts = 2
            Licensepage_found = False       
            print("Personal Information")
            #Personal Information 
            for attempt in range(max_attempts):
                first_name_element = WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID664"]')))
                first_name_upper = data_dict['first_name'].upper()
                first_name_element.send_keys(first_name_upper)
                print(data_dict['first_name'])
                time.sleep(1)
                        
                if data_dict['middle_name']:
                    middle_name_element = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID665"]')))
                    middle_name_upper = data_dict['middle_name'].upper()
                    middle_name_element.send_keys(middle_name_upper)
                    time.sleep(1)
                    print(data_dict['middle_name'])
                        
                last_name_element = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID666"]')))
                last_name_upper = data_dict['last_name'].upper()
                last_name_element.send_keys(last_name_upper)
                time.sleep(1)
                print(data_dict['last_name'])
                if data_dict['suffix'] not in [None, 'none']:
                    def format_suffix(suffix):
                        suffix_map = {
                            'Jr': 'Jr.',
                            'Sr': 'Sr.',
                            'I': 'I',
                            'II': 'II',
                            'III': 'III',
                            'IV': 'IV',
                            'V': 'V',
                            'VI': 'VI',
                        }
                        normalized_suffix = suffix.lower()
                        return suffix_map.get(normalized_suffix, suffix)
                    
                    formatted_suffix = format_suffix(data_dict['suffix'])
                    suffix = formatted_suffix
                    if suffix:
                        # suffix_dropdown = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID667"]')))
                        # select = Select(suffix_dropdown)
                        # select.select_by_visible_text(suffix)
                        # print(f"Selected suffix: {suffix}")
                        # time.sleep(1)
                        try:
                            suffix_dropdown = WebDriverWait(driver, 10).until(
                                EC.presence_of_element_located((By.XPATH, '//*[@id="ID667"]'))
                            )
                            select = Select(suffix_dropdown)
                            select.select_by_visible_text(suffix)
                            print(f"Selected suffix: {suffix}")
                            time.sleep(1)
                        except Exception as e:
                            print(f"Error selecting suffix: {e}")

                # Select the dropdown option
                dropdown1 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID685"]')))
                desired_option = dropdown1.find_element(By.XPATH, '//*[@id="ID685"]/option[235]')
                desired_option.click()
                time.sleep(2)
        
                def similar(a, b):
                    return SequenceMatcher(None, a, b).ratio()

                try:
                    # Format the city and state
                    city = data_dict['tech_city'].replace('_', ' ').title()
                    state = data_dict['tech_state'].replace('_', ' ').title()
                    if 'Of' in state:
                        state = state.replace(' Of ', ' of ')
                    
                    # Format the address
                    address = f"{data_dict['address']} {city}, {state}, USA"
                    print(f"Formatted License State: {address}")
                    found = False
                    # Input the address
                    address_input = driver.find_element(By.XPATH, '//*[@id="ID692_google_street_autocomplete"]')
                    address_input.clear()
                    address_input.send_keys(address)
                    print("Address Entered")
                    time.sleep(1)

                    with open(log_file, 'a') as log:
                        log.write(f"Address: {address}\n")

                    # Wait for the address suggestions to appear
                    dropdown_xpath = '//div[contains(@class, "pac-item")]'
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, dropdown_xpath)))

                    # Re-locate the address items to avoid stale element exception
                    address_items = driver.find_elements(By.XPATH, dropdown_xpath)

                    if len(address_items) == 1:
                        address_items[0].click()
                        found = True
                        print(f"1.Only one suggestion found and clicked: '{address_items}'")
                        print(f"2.Only one suggestion found and clicked: '{address_items[0].text}'")
                        with open(log_file, 'a') as log:
                            log.write(f"Only one suggestion found and clicked.\n")
                    else:
                        best_match = None
                        best_similarity = 0.0
                        target_address = data_dict['address'].strip().lower()

                        for item in address_items:
                            item_text = item.text.strip().replace("\n", " ")
                            print(f"Found suggestion: '{item_text}'")

                            # Improve similarity calculation by focusing on the address part
                            item_address = item_text.split(',')[0].strip().lower()
                            similarity_score = similar(target_address, item_address)
                            print(f"Similarity score: {similarity_score}")

                            if similarity_score >= 0.7:
                                if similarity_score > best_similarity:
                                    best_similarity = similarity_score
                                    best_match = item

                        if best_match:
                            best_match.click()
                            found = True
                            print(f"Best match found and clicked: '{best_match}'")
                            print(f"Best match found and clicked: '{best_match.text}'")
                            with open(log_file, 'a') as log:
                                log.write(f"Best match found and clicked.\n")
                        else:
                            print("Desired address not found in the suggestions")
                            with open(log_file, 'a') as log:
                                log.write("Desired address not found in the suggestions\n")
                except Exception as e:
                    print("Error finding or selecting address")
                time.sleep(1)
                try:
                    if not found:
                        # Format the address
                        address = f"{data_dict['address']}"
                        print(f"Formatted License State: {address}")
                        print("Manually entering the address")
                        address_input = driver.find_element(By.XPATH, '//*[@id="ID692_google_street_autocomplete"]')
                        address_input.clear()
                        address_input.send_keys(address)
                        print(f"Address entered manually: {data_dict['address']}")
                        with open(log_file, 'a') as log:
                            log.write("Address entered manually.\n")
                    else:
                        print("Address founded")
                except Exception as e:
                    print("Address founded")
                try:
                    city = data_dict['tech_city'].replace('_', ' ').title()
                    address_input = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID690"]')))
                    value = address_input.get_attribute('value').strip()
                    if value == city:
                        print("City: Found")    
                    else: 
                        time.sleep(1)    
                        address_input.clear()
                        address_input.send_keys(city)
                        time.sleep(1)

                    state = data_dict['tech_state'].replace('_', ' ').title()
                    if 'Of' in state:
                        state = state.replace(' Of ', ' of ')
                    print(f"Formatted tech_state: {state}")
                    
                    state_dropdown = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID688"]')))
                    select = Select(state_dropdown)
                    select.select_by_visible_text(state)
                    time.sleep(1)

                except Exception as e:
                    print("Error updating city or state")
                    with open(log_file, 'a') as log:
                        log.write("Error updating city or state\n")
                
                zip_input = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID687"]')))
                zip = zip_input.get_attribute('value').strip()
                if zip == data_dict['zip_code']:
                    print("ZIP: Found")    
                else:
                    time.sleep(1)    
                    zip_input.clear()
                    zip_input.send_keys(data_dict['zip_code'])
                    time.sleep(1)

                WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID676_id"]')))
                driver.find_element(By.XPATH, '//*[@id="ID676_id"]').send_keys(data_dict['tech_phone_no'])
                time.sleep(1)

                email = {data_dict['tech_mail_id']}
                if email:
                    #Enter Email
                    WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID679"]')))
                    driver.find_element(By.XPATH, '//*[@id="ID679"]').send_keys(email)
                    time.sleep(1)
                else:
                    #No Email
                    checkbox = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="HasNoEmail"]')))
                    desired_option = checkbox.find_element(By.XPATH, '//*[@id="HasNoEmail"]')
                    desired_option.click()
                print("Email entered")
                
                tech_dob_str = str(data_dict['tech_dob'])
                if '-' in tech_dob_str:
                    year, month, day = tech_dob_str.split('-')
                    with open(log_file, 'a') as log:
                        log.write(f"DOB = {year}, {month}, {day}\n")
                else:
                    print("Unsupported date format or missing delimiter '-'")
                    with open(log_file, 'a') as log:
                        log.write("Unsupported date format or missing delimiter '-'\n")
                    return
                    
                try:
                    #select the month
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID738_mm"]')))
                    month_select = Select(driver.find_element(By.XPATH, '//*[@id="ID738_mm"]'))
                    month_select.select_by_value(month)

                    #select the day
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID738_dd"]')))
                    day_select = Select(driver.find_element(By.XPATH, '//*[@id="ID738_dd"]'))
                    day_select.select_by_value(day)

                    #select the year
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID738_yyyy"]')))
                    year_select = Select(driver.find_element(By.XPATH, '//*[@id="ID738_yyyy"]'))
                    year_select.select_by_value(year)

                    #ReSelect the month
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID739_mm"]')))
                    month_select = Select(driver.find_element(By.XPATH, '//*[@id="ID739_mm"]'))
                    month_select.select_by_value(month)
                                
                    #ReSelect the day
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID739_dd"]')))
                    day_select = Select(driver.find_element(By.XPATH, '//*[@id="ID739_dd"]'))
                    day_select.select_by_value(day)
                                
                    #ReSelect the year
                    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="ID739_yyyy"]')))
                    year_select = Select(driver.find_element(By.XPATH, '//*[@id="ID739_yyyy"]'))
                    year_select.select_by_value(year)

                except Exception as e:
                    print("An error occurred: While entering DOB")
                    with open(log_file, 'a') as log:
                        log.write(f"An error occurred: While entering DOB\n")
                time.sleep(1)
                            
                if f"{data_dict['ssn']}":
                    #Select SSN
                    WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="id_value1"]')))
                    driver.find_element(By.XPATH, '//*[@id="id_value1"]').send_keys(f"{data_dict['ssn']}")
                    time.sleep(1)
                                
                    #ReSelect SSN
                    WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="id_value_duplicate1"]')))
                    driver.find_element(By.XPATH, '//*[@id="id_value_duplicate1"]').send_keys(f"{data_dict['ssn']}")
                    time.sleep(1)
                else:
                    #No SSN
                    checkbox = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="HasNoSSN"]')))
                    desired_option = checkbox.find_element(By.XPATH, '//*[@id="HasNoSSN"]')
                    desired_option.click()
                print("SSN entered") 
                with open(log_file, 'a') as log:
                    log.write("SSN entered\n")  
                        
                button3 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
                button3.click()
                time.sleep(3)
                Licensepage_found = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, 'mvr_region1'))) 
                if Licensepage_found:
                    print("Licence Page found") 
                    break
            if not Licensepage_found:
                print("Tech details are not valid")
                with open(log_file, 'a') as log:
                    log.write("Tech details are not valid\n")
                cursor.execute("UPDATE public.onboarding SET hireright_status = %s WHERE ssn = %s", ('Tech_details_error', data_dict['ssn']))
                conn.commit()
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
                    body_message = f"Tech Detail is not valid or not entered in HireRight for {Techname}. Kindly check it."
                    body_message1  =  "" 
                    attachment_path = ""
                try:
                    Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                    print("Mail sent Successfully for Tech Detail is not valid or not entered in HireRight")
                except Exception as e:
                    print("Mail not sent Successfully for Tech Detail is not valid or not entered in HireRight")
            else:
                try:
                    #Selecting State
                    data_dict['license_state'] = data_dict['license_state'].replace('_', ' ').title()
                    print(f"License State: {data_dict['license_state']}")
                    if 'Of' in data_dict['license_state']:
                        data_dict['license_state'] = data_dict['license_state'].replace(' Of ', ' of ')
                        print(f"Formatted License State: {data_dict['license_state']}")
                    state_dropdown = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, 'mvr_region1')))
                    select = Select(state_dropdown)
                    select.select_by_visible_text(data_dict['license_state'])
                    print(f"Selected state: {data_dict['license_state']}")
                    time.sleep(2)

                    #License Number
                    driver.find_element(By.XPATH, '//*[@id="mvr_dln1"]').send_keys(data_dict['license_number'])
                    time.sleep(1)
                
                    button4 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
                    button4.click()
                    time.sleep(3)
                except Exception as e:
                    print("State&License_Next")
                    with open(log_file, 'a') as log:
                        log.write("State&License_Next\n")

                time.sleep(1)
                checkbox_found = False        
                checkbox_found = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="_tmp_LegalReq"]')))
                checkbox_found.click()
                time.sleep(1)
                print("Checkbox Selected")
                with open(log_file, 'a') as log:
                    log.write("Checkbox Selected\n")
                if not checkbox_found:
                    print("Checkbox not found within the time limit")
                    with open(log_file, 'a') as log:
                        log.write("Checkbox not found within the time limit\n")
                    cursor.execute("UPDATE public.onboarding SET hireright_status = %s WHERE ssn = %s", ('License_error', data_dict['ssn']))
                    conn.commit()
                    # cursor.execute("UPDATE public.onboarding SET bgv_status_mail_sent = NULL WHERE ssn = %s", (data_dict['ssn'],))
                    # conn.commit()
                    if data_dict['middle_name']:
                        Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                    else:
                        Techname = f"{data_dict['first_name']} {data_dict['last_name']}"

                    recipient_emails = credentials['Recipient']
                    cc_emails = {data_dict['hr_coordinator']}
                    if data_dict['tax_term'] == "1099":
                        subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
                    else:
                        subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
                        body_message = f"License Detail is not valid in HireRight for {Techname}. Kindly check it."
                        body_message1  =  "" 
                        attachment_path = ""
                    try:
                        Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                        print("Mail sent Successfully for License Detail is not valid in HireRight")
                    except Exception as e:
                        print("Mail not sent Successfully for License Detail is not valid in HireRight")
                
                if checkbox_found:
                    button5 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="next_link"]')))
                    button5.click()
                    time.sleep(3)

                    warning_found = False
                    try:
                        WebDriverWait(driver, 5).until(
                            EC.presence_of_element_located((By.XPATH, "//div[@role='heading' and contains(text(), 'Warning')]")))
                        # Find all elements that contain the text 'Warning'
                        warning_elements = driver.find_elements(By.XPATH, "//div[contains(text(), 'Warning')]")
                        if warning_elements:
                            warning_element_xpath = "//div[@id='duplicate_order_warning_fader']//td[contains(text(), 'One or more background requests may have already been entered for this candidate:')]"
                            warning_element = WebDriverWait(driver, 5).until(
                                EC.presence_of_element_located((By.XPATH, warning_element_xpath)))

                            # Check if the warning element contains the specific text
                            if "One or more background requests may have already been entered for this candidate:" in warning_element.text:
                                print("Duplicate")
                                warning_found = True
                                cancel_button = WebDriverWait(driver, 5).until(
                                    EC.element_to_be_clickable((By.XPATH, "//a[@class='styled_button_main' and contains(text(),'Cancel This Order')]")))
                                cancel_button.click()
                                print("Cancelled the order")

                                close_button = WebDriverWait(driver, 5).until(
                                    EC.element_to_be_clickable((By.XPATH, "//span[contains(@style, 'background-position: 0 -643px')]")))
                                close_button.click()
                                print("Close button clicked")
                                cursor.execute("UPDATE public.onboarding SET hireright_status = %s WHERE ssn = %s", ('Duplicate', data_dict['ssn']))
                                conn.commit()
                                cursor.execute("UPDATE public.onboarding SET bgv_status_mail_sent = NULL WHERE ssn = %s", (data_dict['ssn'],))
                                conn.commit()
                                if data_dict['middle_name']:
                                    Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                                else:
                                    Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
                                recipient_emails = credentials['Recipient']
                                cc_emails = "ldevi@i-t-g.net"
                                if data_dict['tax_term'] == "1099":
                                    subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
                                else:
                                    subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
                                body_message = f"Duplicate entry found in HireRight for {Techname}. Kindly check it."
                                body_message1  =  "" 
                                attachment_path = ""
                                try:
                                    Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                                    print("Mail sent Successfully for Duplicate entry found in HireRight")
                                except Exception as e:
                                    print("Mail not sent Successfully for Duplicate entry found in HireRight")
                        else:
                            print("Warning elements not found, moving to next step.")
                    except Exception as e:
                        print("No warning found, moving to next step")
                        with open(log_file, 'a') as log:
                            log.write("No warning found, moving to next step\n")

                    if not warning_found:
                        WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.CSS_SELECTOR, "label[guid='10CA8']")))
                        radio = driver.find_element(By.CSS_SELECTOR, "label[guid='10CA8']")
                        radio.click()
                        time.sleep(2)
                                    
                        button5 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="process_first_esign_page"]')))
                        button5.click()
                        time.sleep(2)
                        print("First Condition-Disclosure and Authorization form") 
                        with open(log_file, 'a') as log:
                            log.write("First Condition Selected-Disclosure and Authorization form\n")

                        WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.CSS_SELECTOR, "label[guid='10CA8']")))
                        radio = driver.find_element(By.CSS_SELECTOR, "label[guid='10CA8']")
                        radio.click()
                        time.sleep(2)
                        print("Second Condition-Applicant Disclosure Form") 
                        with open(log_file, 'a') as log:
                            log.write("Second Condition Selected-Applicant Disclosure Form\n")
                        
                        # Submit
                        submit = False
                        try:
                            submit = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="enabled_submit_button"]')))
                            if submit:
                                submit.click()
                                print("Click Submit to Inititatitate BG-1")
                                with open(log_file, 'a') as log:
                                    log.write("Click Submit to Inititatitate BG-1\n")
                                time.sleep(5)
                                try:
                                    gender_value = data_dict['gender']
                                    if gender_value.lower() == "male":
                                        radio_button = driver.find_element(By.XPATH, "//label[contains(text(), 'Male')]//input")
                                        radio_button.click()
                                    elif gender_value.lower() == "female":
                                        radio_button = driver.find_element(By.XPATH, "//label[contains(text(), 'Female')]//input")
                                        radio_button.click()
                                    elif gender_value.lower() == "choose not to answer":
                                        radio_button = driver.find_element(By.XPATH, "//label[contains(text(), 'Choose Not to Answer')]//input")
                                        radio_button.click()
                                    else:
                                        print("Invalid gender value provided.")
                                    print(f"Gender: {gender_value}")
                                    with open(log_file, 'a') as log:
                                        log.write(f"Gender: {gender_value}\n")
                                    submit = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="enabled_submit_button"]')))
                                    submit.click()
                                    print("Click Submit after gender selection to Inititatitate BG-2")
                                    with open(log_file, 'a') as log:
                                        log.write("Click Submit after gender selection to Inititatitate BG-2\n")
                                    time.sleep(5)
                                except Exception as e:
                                    print("Gender value not found.")
                                    with open(log_file, 'a') as log:
                                        log.write("Gender value not found.\n")
                                try:
                                    skip_checkbox = WebDriverWait(driver, 10).until(
                                        EC.presence_of_element_located((By.XPATH, '//*[@id="skip_3304_0"]'))
                                    )
                                    if skip_checkbox:
                                        skip_checkbox.click()
                                        time.sleep(2)
                                        submit = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="enabled_submit_button"]')))
                                        submit.click()
                                        print("Checked 'Skip this document' checkbox to Inititatitate BG-3")
                                        with open(log_file, 'a') as log:
                                            log.write("Checked 'Skip this document' checkbox to Inititatitate BG-3\n")
                                        if data_dict['middle_name']:
                                            Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                                        else:
                                            Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
                                        if data_dict['tax_term'] == "1099":
                                            subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
                                        else:
                                            subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
                                        recipient_emails = credentials['HireRight_team']
                                        cc_emails = credentials['Recipient']
                                        body_message = f"I hope you're doing well. The tech {Techname} required consent form to upload in HireRight to process Background Verification."
                                        body_message1  =  "" 
                                        attachment_path = ""
                                        try:
                                            Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                                            print("Mail sent Successfully for consent form")
                                        except Exception as e:
                                            print("Mail not sent Successfully for consent form")
                                    else:
                                        print("Skip checkbox not found or already selected.")
                                        with open(log_file, 'a') as log:
                                            log.write("Skip checkbox not found or already selected.\n")
                                except Exception as e:
                                    print("Skip this doc checkbox not found.")
                                    with open(log_file, 'a') as log:
                                        log.write("Skip this doc checkbox not found.\n")
                        except Exception as e:
                            print("Submit button not found, moving to GCIC form or Gender selection.")
                            with open(log_file, 'a') as log:
                                log.write("Submit button not found, moving to GCIC form or Gender selection.\n")

                        if not submit:
                            button6 = False
                            try:
                                button6 = WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="process_first_esign_page"]')))
                                if button6:
                                    try:
                                        print("Going to GCIC Consent Form")
                                        with open(log_file, 'a') as log:
                                            log.write("Going to GCIC Consent Form.\n")
                                        button6.click()
                                        time.sleep(2)
                                        WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.CSS_SELECTOR, "label[guid='10CA8']")))
                                        radio = driver.find_element(By.CSS_SELECTOR, "label[guid='10CA8']")
                                        radio.click()
                                        print("Third Condition-GCIC Consent Form") 
                                        with open(log_file, 'a') as log:
                                            log.write("Third Condition Selected-GCIC Consent Form\n")
                                    except Exception as e:
                                        print("Third Condition Selected-GCIC Consent Form not found.")
                            except Exception as e:
                                print("GCIC Consent Form not found, moving to submit.")
                                with open(log_file, 'a') as log:
                                    log.write("GCIC Consent Form not found, moving to submit.\n")
                            # Submit
                            button7 = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="enabled_submit_button"]')))
                            button7.click()
                            print("Click Submit after third condition to Inititatitate BG-4\n")
                            with open(log_file, 'a') as log:
                                log.write("Click Submit after third condition to Inititatitate BG-4\n")
                            time.sleep(5)

                        #close tab
                        closetab = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, '//*[@id="close_tab_message"]/a')))
                        closetab.click()
                        print("Close the Tab")
                        with open(log_file, 'a') as log:
                            log.write("Close the Tab\n")
                        print("BGV Initiated in HireRight")
                        with open(log_file, 'a') as log:
                            log.write("BGV Initiated in HireRight Successfully.\n")
                        time.sleep(2)
                        cursor.execute("UPDATE public.onboarding SET hireright_status = %s WHERE ssn = %s", ('Initiated', data_dict['ssn']))
                        conn.commit()
                        cursor.execute("UPDATE public.onboarding SET bgv_status_mail_sent = NULL WHERE ssn = %s", (data_dict['ssn'],))
                        conn.commit()
                        if data_dict['middle_name']:
                            Techname = f"{data_dict['first_name']} {data_dict['middle_name']} {data_dict['last_name']}"
                        else:
                            Techname = f"{data_dict['first_name']} {data_dict['last_name']}"
                        print(f"HireRight executed successfully for {Techname}")
                        recipient_emails = credentials['HireRight_team']
                        cc_emails = credentials['Recipient']
                        if data_dict['tax_term'] == "1099":
                            subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']} - {data_dict['company_name']}|{Techname}"
                        else:
                            subject = f"PC-{data_dict['pc_number']}|{data_dict['tax_term']}|{Techname}"
                        body_message = f"BGV is initiated for {Techname} in HireRight."
                        body_message1  =  f"BGV Fuse Ticket - {data_dict['bgv_ticket_no']}" 
                        attachment_path = ""
                        try:
                            Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
                            print("Mail sent Successfully for BGV is initiated in HireRight")
                        except Exception as e:
                            print("Mail not sent Successfully for BGV is initiated in HireRight")
    else:
        print("Duplicate entry found in HireRight")
        cursor.execute("UPDATE public.onboarding SET hireright_status = %s WHERE ssn = %s", ('Duplicate', data_dict['ssn']))
        conn.commit()
        cursor.execute("UPDATE public.onboarding SET bgv_status_mail_sent = NULL WHERE ssn = %s", (data_dict['ssn'],))
        conn.commit()
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
        body_message = f"Duplicate entry found in HireRight for {Techname}. Kindly check it."
        body_message1  =  "" 
        attachment_path = ""
        try:
            Sendmail(recipient_emails, cc_emails, subject, body_message, body_message1, attachment_path)
            print("Mail sent Successfully for Duplicate entry found in HireRight")
        except Exception as e:
            print("Mail not sent Successfully for Duplicate entry found in HireRight")