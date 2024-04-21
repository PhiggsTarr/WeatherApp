//
//  NetworkManager.swift
//  Weather Project
//
//  Created by Kevin Tarr on 4/16/24.
//

import Foundation

protocol NetworkManagerProviding {
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void)
}

class NetworkManager: NetworkManagerProviding {
    static let shared = NetworkManager()
    private init() {}
    
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
              let key = dict["APIKey"] as? String else {
            fatalError("Please ensure you have a Config.plist file with a valid 'APIKey'")
        }
        return key
    }
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&appid=\(self.apiKey)"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "NetworkManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error as Error))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "NetworkManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError as Error))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(weatherData))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


struct WeatherData: Codable, Equatable {
    static func == (lhs: WeatherData, rhs: WeatherData) -> Bool {
        true
    }
    
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}
