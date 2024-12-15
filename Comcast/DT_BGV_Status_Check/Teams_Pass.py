import requests
import datetime

def Teamspass(First_name, Last_name, Message, PC_Number, Term):
    
    webhook_url = "https://itgcomm.webhook.office.com/webhookb2/275af351-ebb5-4a87-8e07-2b3bd147a71a@4646f10c-2417-49ee-975a-5c79c274186c/IncomingWebhook/55006b337b5a4e188c558529ddd8b8a3/ea06a1f0-65a2-41ab-a068-91e4a0da8371"
    # webhook_url = "https://yitroglobal1.webhook.office.com/webhookb2/72e88dca-ee83-4344-84a6-249629232339@70c08f1c-9d34-4b5e-9613-f3459778e480/IncomingWebhook/5448e5901d7847d6b8bab96ce92ac566/73be572b-64ba-4a51-b950-5ee307d61d7b"

    success = True

    if success:
        message_content = {
            "@type": "MessageCard",
            "@context": "https://schema.org/extensions",
            "summary": "Status is Success",
            "themeColor": "#008000",
            "sections": [
                {
                    "startGroup": True,
                    "title": "Onboarding Process",
                    "text": f"{Message} {First_name}_{Last_name}\n\n"
                            f"<strong>PC</strong>: {PC_Number}\n\n"
                            f"<strong>Tax_Term</strong>: {Term}\n\n"
                            "<strong>Process</strong>: Comcast\n\n"
                            "<strong>Task</strong>: DT&BGV Status Check\n\n"
                            "<strong>Time</strong>: " + str(datetime.datetime.now()) + "\n\n"
                            "<strong>Robot Name</strong>: Yitro Tech RPA"
                }
            ]
        }

    requests.post(webhook_url, json=message_content)
