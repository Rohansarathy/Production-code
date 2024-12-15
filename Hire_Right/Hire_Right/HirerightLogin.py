import time
from datetime import datetime
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def hireright_login(driver, credentials, log_file):
    
    try:
        driver.get(credentials['Hireright_URL'])
        driver.maximize_window()
        
        WebDriverWait(driver, 10).until(EC.visibility_of_element_located((By.ID, 'company_id')))
        driver.find_element(By.ID, 'company_id').send_keys(credentials['HrCompanyID'])
        time.sleep(1)
        driver.find_element(By.ID, 'user_name').send_keys(credentials['Hrusername'])
        time.sleep(1)
        driver.find_element(By.ID, 'password').send_keys(credentials['Hrpassword'])
        time.sleep(1)
        driver.find_element(By.XPATH, '//*[@id="login_form"]/fieldset/div[8]/button').click()
        
        Verfication = WebDriverWait(driver, 10).until(EC.visibility_of_element_located((By.XPATH, '//*[@id="mfa_form"]/div[3]/div[2]/input')))
        if Verfication:
            driver.find_element(By.XPATH, '//*[@id="mfa_form"]/div[3]/div[2]/input').click()
            
        WebDriverWait(driver, 800).until(EC.presence_of_element_located((By.XPATH, '//*[@id="_jsx_0_1l"]')))
        print("HireRight Login Successful")
        with open(log_file, 'a') as log:
            log.write("Hireright login successful\n")
        return True
    except Exception as e:
        print(f"HireRight Login Unsuccessful: {e}")
        with open(log_file, 'a') as log:
            log.write(f"HireRight Login Unsuccessful: {e}\n")
        return False