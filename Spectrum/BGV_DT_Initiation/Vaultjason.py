import json

credentials = {
    "CrimShieldURL": "https://cs01.crimshield.com/pro/actions/loginAction.do",
    "username": "ybot05",
    "password": "Bluebird1@5",
    "Fuse URL": "https://fuse.i-t-g.net/login.php",
    "Fusername": "ybot",
    "Fpassword": "Bluebird1@3",
    "Default_Path": "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_Spectrum\\Technician_Details",
    "Logfile" : "C:\\Users\\Administrator\\OneDrive - ITG Communications, LLC\\onboarding_data\\Onboarding_Spectrum\\Log\\BGV_DT_initiation",
    "OffPhNo" : "7312361130",
    "Distance" : "50",
    "ybotID" : "ybot@i-t-g.net",
    "Businessdays" : "2",
    "DB_HOST" : "onboarding-app-db.cluster-cesmhx7exvaw.us-east-2.rds.amazonaws.com",
    "DB_PORT" : "5432",
    "DB_NAME" : "onboardingdb",
    "DB_USERNAME" : "postgres",
    "DB_PASSWORD" : "+U%xLgV:ze-4PZUS7Mp~(}2~Hn{6",
}

with open("credentials.json", "w") as json_file:
    json.dump(credentials, json_file)