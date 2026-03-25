# Energy Consumption Predictor — Python Backend & Flutter App

## Mission Description 
Our mission is to optimize residential energy usage through intelligent prediction. This system forecasts monthly consumption (kWh) based on square footage, occupancy, and climate data. By identifying energy-intensive patterns, users can reduce costs and utilities can enhance grid sustainability.

### Public API Endpoint 
- **Live Swagger UI:** [https://energy-api-sgov.onrender.com/docs]
- **Base Prediction URL:** `https://energy-api-sgov.onrender.com/predict`

### Video Demo 
- **YouTube Link:** [https://youtu.be/AcxNG_aEP64]


---

## Technical Details

### Dataset & Models
- **Source:** Residential Energy Logs (regressive analysis).
- **Features:** Sq-Ft, Occupants, Appliances, Temperature, Day Type.
- **Models:** SGDRegressor, Decision Tree, and **Random Forest (Best Performance)**.

### API Features
- **Validation:** Pydantic models with strict range constraints (e.g. Temp -30°C to 55°C).
- **Security:** CSRF-protected/CORS restricted origin handling in `main.py`.
- **Dynamic Updates:** `/retrain` endpoint for model hot-swapping.

---

## How to Run Project

### 1. Run Mobile App (Flutter)
1. Ensure Flutter is installed.
2. `cd FlutterApp`
3. `flutter pub get`
4. `flutter run`

### 2. Run API Locally (Optional)
1. `cd API`
2. `pip install -r requirements.txt`
3. `uvicorn main:app --reload`
