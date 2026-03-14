import pickle
import numpy as np

# Load the best-performing model and its preprocessing components
with open('best_energy_model.pkl', 'rb') as f:
    model_data = pickle.load(f)

model = model_data['model']
scaler = model_data['scaler']
features = model_data['features']

# Define a sample input: 
# Square Footage=2500, Number of Occupants=4, Appliances Used=8, Average Temperature=22.5, Day of Week=0 (Weekday)
sample_input = np.array([[2500, 4, 8, 22.5, 0]])

# Scale the input using the loaded scaler
scaled_input = scaler.transform(sample_input)

# Run model.predict() and print the predicted energy consumption
prediction = model.predict(scaled_input)

print(f"Features: {features}")
print(f"Sample Input: {sample_input[0]}")
print(f"Predicted Energy Consumption: {prediction[0]:.2f} kWh")

# To change input values for different predictions, modify the 'sample_input' array above.
# Example: [Square Footage, Occupants, Appliances, Avg Temp, Day Type (0-6)]
