# AI-Based Real-Time Disaster Alert System

## 1. Introduction
This project is a software-centric **Disaster Alert System** built on the MERN stack. It provides real-time safety assessments by fetching data from external Weather APIs and comparing them against safety thresholds.

### Key Features:
* **Live Weather Assessment**: Classifies status as "Good" or "Bad" based on atmospheric data.
* **Emergency Map**: Visualizes safe house locations for immediate evacuation.
* **Emergency Call**: Integrated one-touch dialing for local emergency services.

## 2. Methodology
The system replaces physical sensors with **Virtual Data Ingestion**. 
* **API Integration**: Connects to OpenWeather or ThingSpeak to retrieve levels of $Clouds$, $Temparature$, and $Humidity$.
* **Range-Based Decision Logic**: The system uses conditional logic (If/Else) to monitor pollutant ranges. If a value exceeds the safe limit, an automated alert is triggered.



## 3. Coding (Tech Stack)
* **Frontend**: React.js (Dashboard & Maps).
* **Backend**: Node.js & Express.js (API handling & Range Logic).
* **Database**: MongoDB (User Auth & Safe House coordinates).
* **Data Visualization**: ThingSpeak for real-time pollutant graphs.

## 4. Results
* **Dynamic Alerts**: Successfully displays "Good" or "Bad" weather status based on real-time API thresholds.
* **Safe House Navigation**: Map markers correctly identify and display nearby shelters.
* **Direct Emergency Dialing**: Initiates phone calls to emergency numbers directly from the dashboard.

# 5. Output
<img width="960" height="540" alt="Screenshot 2026-02-07 093445" src="https://github.com/user-attachments/assets/b1e8ca70-268d-408f-a90a-88a7ea3dc36d" /><img width="960" height="540" alt="Screenshot 2026-02-07 093531" src="https://github.com/user-attachments/assets/69886921-650c-4215-acfe-4250b3f25f9c" />
