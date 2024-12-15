import json
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time



def fuse_login(driver, credentials_file):
    with open(credentials_file, 'r') as file:
        credentials = json.load(file)

    try:
        driver.execute_script(f"window.open('{credentials['Fuse URL']}');")
        driver.switch_to.window(driver.window_handles[1])
        time.sleep(5)
        try:
            WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="topicons"]/ul/li[5]/a')))
            print("Fuse Login Successful")
            with open(credentials['Logfile'], 'a') as log:
                log.write("Fuse login was successful.\n")
            return True
        except:
            pass
        WebDriverWait(driver, 5).until(EC.visibility_of_element_located((By.XPATH, '//*[@id="form"]/div[1]/input')))
        driver.find_element(By.XPATH, '//*[@id="form"]/div[1]/input').send_keys(credentials['Fusername'])
        time.sleep(1)
        driver.find_element(By.XPATH, '//*[@id="multi_user_timeout_pin"]').send_keys(credentials['Fpassword'])
        time.sleep(1)
        driver.find_element(By.XPATH, '//*[@id="form"]/div[3]/a').click()

        try:
            WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, '//*[@id="topicons"]/ul/li[5]/a')))
            print("Fuse Login Successful")
            with open(credentials['Logfile'], 'a') as log:
                log.write("Fuse login was successful.\n")
            try:
                popup_exists = WebDriverWait(driver, 5).until(EC.visibility_of_element_located((By.XPATH, '//*[@id="example_main_notification"]/tbody/tr/td[1]')))
                if popup_exists:
                    driver.find_element(By.XPATH, '//*[@id="update_frm"]/div/div/h2/div[3]/label/div').click()
                    time.sleep(2)
                    alert = driver.switch_to.alert
                    alert.accept()
                    time.sleep(1)
                    try:
                        driver.find_element(By.XPATH, '//*[@id="example_main_notification"]/tbody/tr/td[4]/div/a').click()
                    except:
                        print("Popup closed")
                else:
                    print("Popup not found")
            except:
                print("Popup not found")
                
            return True
        except:
            print("Fuse Login Unsuccessful")
            with open(credentials['Logfile'], 'a') as log:
                log.write("Fuse login failed.\n")
            return False

    finally:
        pass