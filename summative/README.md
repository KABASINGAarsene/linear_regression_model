# Energy Consumption Predictor — Python Backend & Flutter App

## Mission: Residential Energy Optimization
The objective of this project is to build an intelligent system that predicts residential energy consumption based on environmental and usage factors. By understanding these patterns, homeowners can optimize their appliance usage and local governments can better forecast grid demand.

### Dataset Description
- **Source:** Residential Energy Dataset (Synthetic patterns based on real-world consumption indices).
- **Volume:** ~1,000+ records of residential energy logs.
- **Features:** 
    - `Square Footage`: Total living area (continuous).
    - `Number of Occupants`: People residing (integer).
    - `Appliances Used`: Count of active appliances (integer).
    - `Average Temperature`: Outdoor temp in °C (continuous).
    - `Day of Week`: Binary (0 for Weekday, 1 for Weekend).
- **Target:** `Energy Consumption` in kWh.

---

## Project Structure
- `linear_regression/`: Contains the `multivariate.ipynb` training notebook and saved `.pkl` artifacts.
- `API/`: FastAPI implementation providing prediction and retraining endpoints.
- `FlutterApp/`: Beautiful sustainability-themed mobile app with real-time predictions.

---

## Getting Started

### 1. API Setup
```bash
cd API
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```
- **Swagger Documentation:** [http://localhost:8000/docs](http://localhost:8000/docs)

### 2. Flutter App Setup
```bash
cd FlutterApp
flutter pub get
flutter run
```

---


