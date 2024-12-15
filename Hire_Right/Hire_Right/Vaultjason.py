import json

credentials = {
    "Hireright_URL": "https://ows01.hireright.com/login/",
    "HrCompanyID": "ITGC",
    "Hrusername": "ybot",
    "Hrpassword": "Secure#3",
    "Fuse URL": "https://fuse.i-t-g.net/login.php",
    "Fusername": "ybot",
    "Fpassword": "Bluebird1@3",
    "Default_Path": "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Hire_Right",
    "Initiation_Logfile" : "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Hire_Right\\Log\\Initiation",
    "HireRight_team" : "ldevi@i-t-g.net, rkamigashima@i-t-g.net",
    "Recipient" :  "ybot@i-t-g.net",
    "DB_HOST" : "onboarding-app-db.cluster-cesmhx7exvaw.us-east-2.rds.amazonaws.com",
    "DB_PORT" : "5432",
    "DB_NAME" : "onboardingdb",
    "DB_USERNAME" : "postgres",
    "DB_PASSWORD" : "+U%xLgV:ze-4PZUS7Mp~(}2~Hn{6",
}

with open("Hirerightcredentials.json", "w") as json_file:
    json.dump(credentials, json_file)