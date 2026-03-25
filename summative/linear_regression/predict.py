import pickle
import numpy as np

# ── Load the best-performing model and its preprocessing components ──────────
with open('best_energy_model.pkl', 'rb') as f:
    model_data = pickle.load(f)

model    = model_data['model']
scaler   = model_data['scaler']
features = model_data['features']

# ── Helper: prompt the user until a valid number is entered ──────────────────
def get_float(prompt):
    while True:
        raw = input(prompt).strip()
        try:
            return float(raw)
        except ValueError:
            print(f"Invalid input '{raw}'. Please enter a numeric value.\n")

def get_int_choice(prompt, choices):
    while True:
        raw = input(prompt).strip()
        try:
            value = int(raw)
            if value in choices:
                return value
            print(f"Please enter one of {choices}.\n")
        except ValueError:
            print(f"Invalid input '{raw}'. Please enter a whole number.\n")

# ── Collect inputs interactively ─────────────────────────────────────────────
print("\n=== Energy Consumption Predictor ===\n")

square_footage   = get_float("Square Footage (e.g. 2500): ")
num_occupants    = get_float("Number of Occupants (e.g. 4): ")
appliances_used  = get_float("Appliances Used (e.g. 8): ")
avg_temperature  = get_float("Average Temperature in °C (e.g. 22.5): ")
day_of_week      = get_int_choice("Day of Week  [0 = Weekday, 1 = Weekend]: ", choices=[0, 1])

# ── Build input array, scale it, and predict ─────────────────────────────────
user_input   = np.array([[square_footage, num_occupants, appliances_used,
                          avg_temperature, day_of_week]])
scaled_input = scaler.transform(user_input)
prediction   = model.predict(scaled_input)

# ── Display result ────────────────────────────────────────────────────────────
print(f"\nPredicted Energy Consumption: {prediction[0]:.2f} kWh")
