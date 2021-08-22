//
//  ViewController.swift
//  Test_Project
//
//  Created by Abhijith on 20/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit
import CoreLocation

class DaysListViewController: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherTableView: UITableView!
    
    //MARK:- Variables
    var locationManger: CLLocationManager!
    var currentLocation: CLLocation?
    let measureFormat = MeasurementFormatter()
    var viewModel: DaysListViewModel?
    var dailyData: [Daily]?
    var cityNameString = ""
    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearFields()
        self.temperatureLabel.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        self.weatherTypeLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        self.temperatureLabel.isHidden = true
        self.weatherTypeLabel.isHidden = true

        //fetchUserLocation
        self.fetchUserLocation()
        
        //startBounceAnimation
        self.startBounceAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK:- Functions
    private func fetchUserLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger = CLLocationManager()
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.requestWhenInUseAuthorization()
            locationManger.requestLocation()
        }
    }
    
    private func performAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.temperatureLabel.isHidden = false
            self.weatherTypeLabel.isHidden = false
            UIView.animate(withDuration: 0.6) {
                self.temperatureLabel.transform = .identity
                self.weatherTableView.transform = .identity
                self.weatherTypeLabel.transform = .identity
            }
        }
    }
    
    private func startBounceAnimation() {
        //Bounce Animation
        UIView.animate(withDuration: 2.0, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 2,options: [.repeat,.autoreverse], animations: {
            self.weatherImageView.transform = CGAffineTransform(translationX: 0, y: -30)
        }, completion: {_ in
            self.weatherImageView.transform = .identity
        })
    }
    
    private func showLocationPermission() {
        let alert = UIAlertController(title: "Enable Location?", message: "To use this feature you must enable location in setting.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "SETTINGS", style: .default, handler: { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: clearFields
    private func clearFields() {
        weatherTypeLabel.text = ""
        temperatureLabel.text = ""
        cityLabel.text = ""
    }
    
    //MARK: bindValues
    private func bindValues() {
        viewModel?.cityName.bind { city in
            DispatchQueue.main.async {
                self.cityLabel.text = (city! + " Today").capitalized
                self.cityNameString = city?.capitalized ?? ""
            }
        }
        
        viewModel?.dailyData.bind { data in
            DispatchQueue.main.async {
                self.dailyData = data
                self.weatherTableView.reloadWithAnimation()
            }
        }
        
        viewModel?.currentWeatherData.bind{ current in
            DispatchQueue.main.async { [self] in
                if current?.weather.count ?? 0 > 0 {
                    self.weatherTypeLabel.text = "\(String(describing: current?.weather[0].weatherDescription ?? ""))".capitalized
                    if current?.weather[0].icon == "01d" {
                        self.weatherImageView.image = UIImage(named: "Sunny")
                    } else {
                        self.weatherImageView.setIconFromUrl(iconName: current!.weather[0].icon)
                    }
                }
            }
        }
        
        viewModel?.currentCelsius.bind { value in
            self.temperatureLabel.text = value
            self.performAnimation()
        }
    }
}

//MARK:- CLLocationManagerDelegate
extension DaysListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            guard self.currentLocation == nil else {
                return
            }
            //Fetch the last user location
            self.currentLocation = location
            
            //Get lat long from coordinate
            let latitude: Double = self.currentLocation!.coordinate.latitude
            let longitude: Double = self.currentLocation!.coordinate.longitude
            
            //Setting the User lat,Long to shared class
            NetworkManager.shared.latitude = latitude
            NetworkManager.shared.longitude = longitude
            
            //Initialise viewmodel Object
            self.viewModel = DaysListViewModel(location: location)
            //Bind Values
            self.bindValues()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            self.showLocationPermission()
            print("restricted")
        case .denied:
            self.showLocationPermission()
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("When In Use")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
}

//MARK:- UITableViewDelegate
extension DaysListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.getCellDataCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModelObj = self.viewModel else {
            return UITableViewCell()
        }
        return viewModelObj.prepareCellForDisplay(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellData = dailyData  {
            DispatchQueue.main.async {
                let detailsVC = UIStoryboard.Main.weatherDetailsVC() as! WeatherDetailsViewController
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.modalTransitionStyle = .crossDissolve
                detailsVC.placeName = self.cityNameString
                detailsVC.onClick = { status in
                    self.startBounceAnimation()
                }
                detailsVC.weatherData = cellData[indexPath.row]
                self.present(detailsVC, animated: false, completion: nil)
            }
        }
    }
}
