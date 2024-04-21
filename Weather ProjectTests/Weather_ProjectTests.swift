//
//  Weather_ProjectTests.swift
//  Weather ProjectTests
//
//  Created by Kevin Tarr on 4/19/24.
//

import XCTest
@testable import Weather_Project

final class Weather_ProjectTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = WeatherViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        mockNetworkManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchWeatherSuccess() {
        let expectedWeatherData = WeatherData(
            coord: Coord(lon: -0.1257, lat: 51.5085),  // Example coordinates for London
            weather: [
                Weather(id: 300, main: "Drizzle", description: "light intensity drizzle", icon: "09d")
            ],
            base: "stations",
            main: Main(
                temp: 280.32,  // Example temperature in Kelvin
                feelsLike: 278.34,
                tempMin: 279.15,
                tempMax: 281.15,
                pressure: 1012,
                humidity: 81
            ),
            visibility: 10000,
            wind: Wind(speed: 4.1, deg: 80),
            clouds: Clouds(all: 90),
            dt: 1485789600,
            sys: Sys(
                type: 1,
                id: 5091,
                country: "GB",
                sunrise: 1485762037,
                sunset: 1485794875
            ),
            timezone: 0,
            id: 2643743,
            name: "London",
            cod: 200
        )
        mockNetworkManager.mockResult = .success(expectedWeatherData)
        
        let expectation = XCTestExpectation(description: "Fetch weather data successfully")
        
        viewModel.onDataReceived = {
            XCTAssertEqual(self.viewModel.weatherData, expectedWeatherData)
            expectation.fulfill()
        }
        
        viewModel.fetchWeather(for: "TestCity")
        
        // It's important to wait for the result since network calls are asynchronous
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchWeatherFailure() {
        let expectedError = NSError(domain: "NetworkManager", code: 2, userInfo: nil)
        mockNetworkManager.mockResult = .failure(expectedError)
        
        let expectation = XCTestExpectation(description: "Fetch weather data with failure")
        
        viewModel.onError = { error in
            XCTAssertEqual(error as NSError, expectedError)
            expectation.fulfill()
        }
        
        viewModel.fetchWeather(for: "TestCity")
        
        // It's important to wait for the result since network calls are asynchronous
        wait(for: [expectation], timeout: 1.0)
    }
}

class MockNetworkManager: NetworkManagerProviding {
    var mockResult: Result<WeatherData, Error>!
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        completion(mockResult)
    }
}
