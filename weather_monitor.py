import firebase_admin
from firebase_admin import credentials, firestore
import requests
import time

# --- CONFIGURATION ---
# 1. Firebase Setup
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. API Setup
API_KEY = " "#Your API key 
CITY = "Chennai"
URL = f"http://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric"

def analyze_weather():
    try:
        response = requests.get(URL)
        data = response.json()
        
        if response.status_code != 200:
            print("Error fetching weather data")
            return

        # Extract stats
        weather_desc = data['weather'][0]['description'].lower()
        wind_speed = data['wind'].get('speed', 0)
        humidity = data['main'].get('humidity', 0)
        
        # DISASTER LOGIC
        # Thresholds: High wind (>15m/s), Heavy rain, or specific keywords
        disaster_keywords = ["cyclone", "hurricane", "tornado", "thunderstorm", "heavy intensity rain"]
        is_disaster = any(word in weather_desc for word in disaster_keywords) or wind_speed > 15
        
        if is_disaster:
            status_msg = f"🚨 DISASTER ALERT: {weather_desc.upper()}! Wind: {wind_speed}m/s. Seek shelter!"
            is_emergency = True
        else:
            status_msg = f"System Active: {weather_desc.capitalize()}. Conditions are currently safe."
            is_emergency = False

        # Only update Firebase if a disaster is detected OR every hour for heartbeat
        # For your testing, we will update it every time so you see it working
        print(f"Sending to App: {status_msg}")
        db.collection('status').document('current').set({
            'alert_message': status_msg,
            'is_emergency': is_emergency,
            'last_updated': firestore.SERVER_TIMESTAMP,
            'city': CITY
        })

    except Exception as e:
        print(f"Loop Error: {e}")

# Run every 5 minutes
print("Disaster AI Monitor Active...")
while True:
    analyze_weather()
    time.sleep(300)
