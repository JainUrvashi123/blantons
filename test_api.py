import urllib.request
import json

req1 = urllib.request.Request(
    'https://blantonslab.com/m_api/jewelry-detail',
    data=json.dumps({"jewelry_id": "1197"}).encode('utf-8'),
    headers={'Content-Type': 'application/json'},
    method='GET'
)
try:
    with urllib.request.urlopen(req1) as f:
        print("Detail:", f.read().decode('utf-8'))
except Exception as e:
    print("Detail Error:", e)

req2 = urllib.request.Request(
    'https://blantonslab.com/m_api/jewelry-add-cart',
    data=json.dumps({"jewelry_id": "1197"}).encode('utf-8'),
    headers={'Content-Type': 'application/json'},
    method='GET'
)
try:
    with urllib.request.urlopen(req2) as f:
        print("Cart:", f.read().decode('utf-8'))
except Exception as e:
    print("Cart Error:", e)
