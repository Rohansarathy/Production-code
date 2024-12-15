import requests
import datetime

def Teamsfail(First_name, Last_name, Message):
    
    webhook_url = "https://yitroglobal1.webhook.office.com/webhookb2/72e88dca-ee83-4344-84a6-249629232339@70c08f1c-9d34-4b5e-9613-f3459778e480/IncomingWebhook/5448e5901d7847d6b8bab96ce92ac566/73be572b-64ba-4a51-b950-5ee307d61d7b"

    success = True

    if success:
        message_content = {
            "@type": "MessageCard",
            "@context": "https://schema.org/extensions",
            "summary": "Status is Failure",
            "themeColor": "#FF0000",
            "sections": [
                {
                    "startGroup": True,
                    "title": "Onboarding Process",
                    "text":f"{Message} {First_name}_{Last_name}\n\n"
                            "<strong>Process</strong>: Comcast\n\n"
                            "<strong>Task</strong>: DT&BGV Status Check\n\n"
                            "<strong>Time</strong>: " + str(datetime.datetime.now()) + "\n\n"
                            "<strong>Robot Name</strong>: Yitro Tech RPA"
                }
            ]
        }

    requests.post(webhook_url, json=message_content)

