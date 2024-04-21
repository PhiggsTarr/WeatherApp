//
//  WeatherDetailViewController.swift
//  Weather Project
//
//  Created by Kevin Tarr on 4/16/24.
//

import UIKit

class WeatherDetailViewController: UIViewController, UITableViewDataSource {
    var viewModel: WeatherViewModel?
    var cityName: String?
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Set up the segmented control first
        setupSegmentedControl()
        // Then, set up the table view
        setupTableView()
        // Bind ViewModel closures
        bindViewModel()
        viewModel?.fetchWeather(for: cityName ?? "")
    }
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel?.onDataReceived = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel?.onError = { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }
    }
    
    private func setupSegmentedControl() {
        temperatureUnitSegmentedControl.selectedSegmentIndex = 0 // Default to Fahrenheit
        temperatureUnitSegmentedControl.addTarget(self, action: #selector(temperatureUnitDidChange(_:)), for: .valueChanged)
        
        view.addSubview(temperatureUnitSegmentedControl)
        temperatureUnitSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .cyan
        temperatureUnitSegmentedControl.backgroundColor = .cyan
        temperatureUnitSegmentedControl.selectedSegmentTintColor = .systemBackground
        
        NSLayoutConstraint.activate([
            temperatureUnitSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureUnitSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        ])
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .cyan
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: temperatureUnitSegmentedControl.bottomAnchor, constant: 8),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    @objc private func temperatureUnitDidChange(_ sender: UISegmentedControl) {
        // Trigger the temperature conversion and update the UI accordingly
        tableView.reloadData()
    }
    
    private let temperatureUnitSegmentedControl = UISegmentedControl(items: ["Fahrenheit", "Celsius"])
    
    //Function to refresh weather data
    @objc private func refreshWeatherData() {
        viewModel?.fetchWeather(for: cityName ?? "")
    }
    
    private func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        view.subviews.forEach { subview in
            if let activityIndicator = subview as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.weatherData == nil ? 0 : 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Reset image for reused cells
        cell.imageView?.image = nil
        // Reset text for reused cells
        cell.textLabel?.text = ""
        // Cancel any ongoing task
        cell.imageView?.currentDataTask?.cancel()
        // Set Cell Color
        cell.backgroundColor = .cyan
        
        if let weatherData = viewModel?.weatherData {
            switch indexPath.row {
            case 0:
                // Temperature cell configuration
                let unit: TemperatureUnit = temperatureUnitSegmentedControl.selectedSegmentIndex == 0 ? .fahrenheit : .celsius
                let temperatureValue = convertTemperature(kelvin: weatherData.main.temp, to: unit)
                cell.textLabel?.text = String(format: "%.1f°%@", temperatureValue, unit == .celsius ? "C" : "F")
            case 1:
                // Description cell configuration
                cell.textLabel?.text = weatherData.weather.first?.description ?? "No description"
            case 2:
                // Icon cell configuration
                if let iconCode = weatherData.weather.first?.icon {
                    fetchIcon(for: iconCode) { iconImage in
                        DispatchQueue.main.async {
                            // Ensure the cell is still in the tableView and visible before setting the image
                            if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                                cell.imageView?.image = iconImage
                                cell.setNeedsLayout()
                            }
                        }
                    }
                }
            case 3:
                // Wind cell configuration
                cell.textLabel?.text = "Wind Speed: \(weatherData.wind.speed) m/s"
            case 4:
                // Humidity cell configuration
                cell.textLabel?.text = "Humidity: \(weatherData.main.humidity)%"
            case 5:
                // Pressure cell configuration
                cell.textLabel?.text = "Pressure: \(weatherData.main.pressure) hPa"
                // Lowest Temperature cell configuration
            case 6:
                let unit: TemperatureUnit = temperatureUnitSegmentedControl.selectedSegmentIndex == 0 ? .fahrenheit : .celsius
                let temperatureValue = convertTemperature(kelvin: weatherData.main.tempMin, to: unit)
                cell.textLabel?.text = "Lowest Temperature " + String(format: "%.1f°%@", temperatureValue, unit == .fahrenheit ? "F" : "C")
                // Highest Temperature cell configuration
            case 7:
                let unit: TemperatureUnit = temperatureUnitSegmentedControl.selectedSegmentIndex == 0 ? .fahrenheit : .celsius
                let temperatureValue = convertTemperature(kelvin: weatherData.main.tempMax, to: unit)
                cell.textLabel?.text = "Highest Temperature " + String(format: "%.1f°%@", temperatureValue, unit == .fahrenheit ? "F" : "C")
            default:
                break
            }
        }
        
        return cell
    }
    
    func fetchIcon(for code: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = "https://openweathermap.org/img/w/\(code).png"
        guard let url = URL(string: urlString) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}

extension UIImageView {
    private static var taskKey: UInt8 = 0
    
    var currentDataTask: URLSessionDataTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
