import requests
import datetime

def Teamspass(First_name, Last_name, Message, PC_Number, Term):
    
    endpoint_url = "https://prod-161.westus.logic.azure.com:443/workflows/edca1ad7774546ed9785d6b4be78e42f/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=gkT4KOtXA9mdgebT-1LDUtEgbYy_vfDXWT5rVccIRMk"
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
                            "<strong>Process</strong>: Cox\n\n"
                            "<strong>Task</strong>: DT & BGV Initiation\n\n"
                            "<strong>Time</strong>: " + str(datetime.datetime.now()) + "\n\n"
                            "<strong>Robot Name</strong>: Yitro Tech RPA"
                }
            ]
        }

    try:
        response = requests.post(endpoint_url, json=message_content)
        response.raise_for_status()
        print(f"Message posted successfully: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Failed to send message: {e}")
