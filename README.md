# Weather Project
The Weather Project is an iOS application that allows users to enter a city name and retrieve current weather data using the OpenWeatherMap API.

## Features
Fetch current weather by city name.
Display temperature, humidity, wind speed, and more.
Dynamic UI with data updates.
Prerequisites
To run this project, you'll need:

## Requirements
- iOS 15.0+
- Xcode 12+
- Swift 5.0+
- Valid API key from OpenWeatherMap


## Setup and Installation
1. Clone the repository to your local machine.
2. Open the `.xcodeproj` file in Xcode.
3. Run the project on your simulator or physical device.

## API Key Configuration
- Navigate to the Config.plist file in the project.
- Replace the placeholder APIKey value with your actual OpenWeatherMap API key.

## Running the Project
- Open Weather Project.xcodeproj in Xcode.
- Select your target device or simulator.
- Press Cmd + R to build and run the application.

## Architecture
This project follows the Model-View-ViewModel (MVVM) architecture:
Model: Defines the data structure and network logic.
View: Handles the display of UI components.
ViewModel: Manages the data for the view layer, converting models into viewable formats and handling user interactions.

## Testing
The project includes unit tests to verify the functionality of fetching weather data:
To run the unit tests, select the test navigator in Xcode and click the play button next to the test suite.
Navigate to the Weather_ProjectTests directory.
Use Cmd + U in Xcode to run the tests.

## Additional Notes
Ensure your device or simulator has internet connectivity to fetch live data.
The project uses URLSession for network requests without any third-party networking libraries.
