import json

credentials = {
    "InfomartURL": "https://webasap.infomart-usa.net/?id=116815941",
    "username": "Ybot",
    "password": "Infomart06!",
    "Account_Number": "101120863",
    "FuseURL": "https://fuse.i-t-g.net/login.php",
    "Fusername": "ybot",
    "Fpassword": "Bluebird1@3",
    "Distance" : "50",
    "Default_Path": "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_COX\\Technicians",
    "Logfile" : "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_COX\\Log\\BGV_DT_Status",
    "ybotID" : "ybot@i-t-g.net",
    "Recipient": "ybot@i-t-g.net",
    "cox_team" : "prokesh@i-t-g.net,yugandhar.chenga@i-t-g.net",
    # "cox_team":"ybot@i-t-g.net",
    "FuseUpdateTime" : "11",
    "DB_HOST" : "onboarding-app-db.cluster-cesmhx7exvaw.us-east-2.rds.amazonaws.com",
    "DB_PORT" : "5432",
    "DB_NAME" : "onboardingdb",
    "DB_USERNAME" : "postgres",
    "DB_PASSWORD" : "+U%xLgV:ze-4PZUS7Mp~(}2~Hn{6",
}

with open("Infomart.json", "w") as json_file:
    json.dump(credentials, json_file)