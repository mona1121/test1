import requests

url = "https://api.tap.company/v2/charges/"

payload = {
    "amount": 1,
    "currency": "SAR",
    "customer_initiated": True,
    "threeDSecure": True,
    "save_card": False,
    "description": "Test Description",
    "metadata": { "udf1": "Metadata 1" },
    "reference": {
        "transaction": "txn_01",
        "order": "ord_01"
    },
    "receipt": {
        "email": True,
        "sms": False
    },
    "customer": {
        "first_name": "test",
        "middle_name": "test",
        "last_name": "test",
        "email": "test@test.com",
        "phone": {
            "country_code": 965,
            "number": 51234567
        }
    },
    "merchant": { "id": "1234" },
    "source": { "id": "src_all" },
    "post": { "url": "http://your_website.com/post_url" },
    "redirect": { "url": "http://your_website.com/redirect_url" }
}
headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "Authorization": "Bearer sk_test_XKokBfNWv6FIYuTMg5sLPjhJ"
}

response = requests.post(url, json=payload, headers=headers)

print(response.text)