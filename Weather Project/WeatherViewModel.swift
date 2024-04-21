//
//  WeatherViewModel.swift
//  Weather Project
//
//  Created by Kevin Tarr on 4/19/24.
//

import Foundation

class WeatherViewModel {
    private let networkManager: NetworkManagerProviding
    
    var weatherData: WeatherData?
    var onDataReceived: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(networkManager: NetworkManagerProviding = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchWeather(for city: String) {
        networkManager.fetchWeather(for: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.weatherData = data
                    self?.onDataReceived?()
                case .failure(let error):
                    self?.onError?(error)
                }
            }
        }
    }
    
    func convertTemperature(kelvin: Double, to unit: TemperatureUnit) -> Double {
        switch unit {
        case .celsius:
            return kelvin - 273.15
        case .fahrenheit:
            return (kelvin - 273.15) * 9/5 + 32
        }
    }
    
    enum TemperatureUnit {
        case celsius, fahrenheit
    }
}
