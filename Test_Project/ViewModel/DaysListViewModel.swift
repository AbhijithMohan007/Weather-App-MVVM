//
//  DatListViewModel.swift
//  Test_Project
//
//  Created by Abhijith on 20/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

struct DaysListViewModel {
    //MARK:- Binding Objects
    var cityName: BoxBind<String?> = BoxBind("--")
    var currentWeatherData: BoxBind<Daily?> = BoxBind(nil)
    var dailyData: BoxBind<[Daily]?> = BoxBind(nil)
    var currentCelsius: BoxBind<String> = BoxBind("")
    var location: CLLocation?
    let realm = try! Realm()
    
    //MARK:- InIt
    init(location: CLLocation) {
        self.location = location
        self.fetchCityFromGeoLocation()
        self.callWeatherApi()
    }
    
    //MARK:- InIt
    func getCurrentTemp(temp: Double) {
        var avoidDecimal = Int(temp)
        switch avoidDecimal.getDayTime() {
        case .morning:
            avoidDecimal = Int(temp)
        case .evening:
            avoidDecimal = Int(temp)
        case .day:
            avoidDecimal = Int(temp)
        case .night:
            avoidDecimal = Int(temp)
        }
        let temp = Measurement(value: Double(avoidDecimal), unit: UnitTemperature.celsius)
        
        self.currentCelsius.value = String(Int(temp.value)) + "°C"
    }
    
    //MARK:- WeatherApi
    func callWeatherApi() {
        NetworkManager.shared.weatherApiCall { result in
            switch result {
            case .success(let data):
                //print(data)
                DispatchQueue.main.async {
                    if data.daily.count > 0 {
                        self.currentWeatherData.value = data.daily[0]
                    }
                    self.dailyData.value = data.daily
                    self.getCurrentTemp(temp: data.current.temp)
                }
                
                //Saving Data to realM locally
                try! realm.write {
                    let myReal = WeatherObject()
                    myReal.myStruct = data
                    myReal.cityName = self.cityName.value ?? ""
                    myReal.id = 1234
                    realm.add(myReal,update: .modified)
                }
            case .failure(_):
                //Fetching data from realm
                let dataModel = realm.object(ofType: WeatherObject.self, forPrimaryKey: 1234)
                if let weatherData = dataModel?.myStruct {
                    DispatchQueue.main.async {
                        if weatherData.daily.count > 0 {
                            self.currentWeatherData.value = weatherData.daily[0]
                        }
                        self.cityName.value = dataModel?.cityName
                        self.dailyData.value = weatherData.daily
                        self.getCurrentTemp(temp: weatherData.current.temp)
                    }
                }
            }
        }
    }
    
    //MARK:- Fetch CityName
    func fetchCityFromGeoLocation() {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location!) { (placemarks, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = placemarks[0]
                    if let city = placemark.locality {
                        self.cityName.value = city
                    }
                }
            }
        }
    }
    
    //MARK:- TableCell Display Functions
    func getCellDataCount() -> Int {
        guard let count = dailyData.value?.count else {
            return 0
        }
        return count
    }
    
    func prepareCellForDisplay(tableView: UITableView,indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell") as! WeatherTableViewCell
        
        if let dailyData = dailyData.value {
            let date = Date(timeIntervalSince1970: Double(dailyData[indexPath.row].dt))
            let dayString = Date.getDayOfWeekFrom(date: date)
            cell.dayLabel.text = dayString
            
            if dailyData[indexPath.row].weather.count > 0 {
                if dailyData[indexPath.row].weather[0].icon == "01d" {
                    cell.weatherImageView.image = UIImage(named: "Sunny")
                } else {
                    cell.weatherImageView.setIconFromUrl(iconName: dailyData[indexPath.row].weather[0].icon)
                }
            }
            var avoidDecimal = Int(dailyData[indexPath.row].temp.max)
            switch avoidDecimal.getDayTime() {
            case .morning:
                avoidDecimal = Int(dailyData[indexPath.row].temp.morn)
            case .evening:
                avoidDecimal = Int(dailyData[indexPath.row].temp.eve)
            case .day:
                avoidDecimal = Int(dailyData[indexPath.row].temp.day)
            case .night:
                avoidDecimal = Int(dailyData[indexPath.row].temp.night)
            }
            let temp = Measurement(value: Double(avoidDecimal), unit: UnitTemperature.celsius)
            cell.celsiusLabel.text  = "\(Int(temp.value))" + "°C"
        }
        cell.selectionStyle = .none
        
        return cell
    }
}
