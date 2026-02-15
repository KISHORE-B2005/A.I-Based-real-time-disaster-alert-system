    import firebase_admin
    from firebase_admin import credentials, firestore

    # Use the serviceAccountKey.json you downloaded earlier
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    def send_alert_to_app(location_name, lat, lng):
        # This automatically adds a new pin to your Flutter Map!
        db.collection('safehouses').add({
            'name': location_name,
            'lat': lat,
            'lng': lng,
            'timestamp': firestore.SERVER_TIMESTAMP
        })

    # Example: AI detects high rain in a specific area
    send_alert_to_app("Emergency Shelter A", 13.04, 80.21)
