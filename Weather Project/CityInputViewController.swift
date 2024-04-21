//
//  CityInputViewController.swift
//  Weather Project
//
//  Created by Kevin Tarr on 4/16/24.
//

import UIKit

class CityInputViewController: UIViewController {
    private let textField = UITextField()
    private let searchButton = UIButton()
    private let titleLabel = UILabel()
    private let weatherViewModel = WeatherViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .cyan
        
        // TitleLabel Configuration
        titleLabel.text = "Get Weather For Your City!!!"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // TextField Configuration
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter City Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        // SearchButton Configuration
        searchButton.setTitle("Get Weather", for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        view.addSubview(searchButton)
        
        // Apply constraints to center all elements
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    
    @objc private func searchButtonTapped() {
        guard let cityName = textField.text, !cityName.isEmpty else {
            showAlert(message: "Please enter a city name.")
            return
        }
        
        // Use viewmodel to fetch weather data before proceeding.
        weatherViewModel.fetchWeather(for: cityName)
        weatherViewModel.onDataReceived = {
            
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                //Pass ViewModel instance to Detail ViewController
                let detailVC = WeatherDetailViewController(viewModel: self.weatherViewModel)
                detailVC.cityName = cityName
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
        weatherViewModel.onError = { [weak self] error in
            self?.showAlert(message: "Failed to fetch weather data: \(error.localizedDescription)")
        }
    }
}
