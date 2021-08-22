//
//  WeatherDetailsViewModel.swift
//  Test_Project
//
//  Created by Abhijith on 21/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit

struct WeatherDetailsViewModel {
    var weatherData: Daily!
    var detailsDict:BoxBind<[[String: String]]?> = BoxBind(nil)
    var lowHighTemp: BoxBind<String> = BoxBind("")
    var descriptionString: BoxBind<String> = BoxBind("")
    var currentTemp: BoxBind<String> = BoxBind("")
    
    //MARK:- init
    init(weatherData: Daily) {
        self.weatherData = weatherData
        self.getCurrentTemp()
        self.getWeatherDetails()
    }
    
    //MARK:- getWeatherDetails
    mutating func getWeatherDetails() {
        //sunRiseTime
        let sunRiseTime = Date.getTimeFrom(dateInterval: weatherData.sunrise)
        let sunRiseDict = ["title": "SUNRISE",
                           "value": sunRiseTime]
        //sunSetTime
        let sunSetTime = Date.getTimeFrom(dateInterval: weatherData.sunset)
        let sunSetDict = ["title": "SUNSET",
                          "value": sunSetTime]
        //moonRiseDict
        let moonRiseTime = Date.getTimeFrom(dateInterval: weatherData.moonrise)
        let moonRiseDict = ["title": "MOONRISE",
                            "value": moonRiseTime]
        //moonSetDict
        let moonSetTime = Date.getTimeFrom(dateInterval: weatherData.moonset)
        let moonSetDict = ["title": "MOONSET",
                           "value": moonSetTime]
        //pressureDict
        let pressureDict = ["title": "PRESSURE",
                            "value": "\(weatherData.pressure) hPa"]
        //humidityDict
        let humidityDict = ["title": "HUMIDITY",
                            "value": "\(weatherData.humidity)%"]
        
        //chanceOfRainDict
        let chanceOfRainDict = ["title": "CHANCE OF RAIN",
                                "value": "\(Int(weatherData.rain ?? 0.0))%"]
        
        //uviDict
        let uviDict = ["title": "UV INDEX",
                           "value": "\(weatherData.uvi)"]
        
        //windSpeedDict
        let windSpeedDict = ["title": "WIND",
                           "value": "\(weatherData.windSpeed) kph"]
        //precipitationDict
        let precipitationDict = ["title": "PRECIPITATION",
                           "value": "\(weatherData.pop) cm"]
        
        detailsDict.value = [sunRiseDict
                ,sunSetDict
                ,moonRiseDict
                ,moonSetDict
                ,pressureDict
                ,humidityDict
                ,chanceOfRainDict
                ,uviDict
                ,windSpeedDict
                ,precipitationDict]
    }
    
    //MARK:- getCurrentTemp
    func getCurrentTemp(_ isCelsius: Bool = true) {
        var avoidDecimal = Int(weatherData.temp.max)
        switch avoidDecimal.getDayTime() {
        case .morning:
            avoidDecimal = Int(weatherData.temp.morn)
        case .evening:
            avoidDecimal = Int(weatherData.temp.eve)
        case .day:
            avoidDecimal = Int(weatherData.temp.day)
        case .night:
            avoidDecimal = Int(weatherData.temp.night)
        }
        let temp = Measurement(value: isCelsius ? Double(avoidDecimal) : Double(Int((avoidDecimal) * 9/5) + 32), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        
        //LowHigh value
        self.getHighLowTemp(isCelsius)
        
        //getDescriptionString
        self.getDescriptionString(isCelsius)
        
        self.currentTemp.value = "\(Int(temp.value))" + (isCelsius ? "°C" : "°F")
    }
    
    //MARK:- getHighLowTemp
    func getHighLowTemp(_ isCelsius: Bool = true) {
        let highTemp = Measurement(value: isCelsius ? Double(weatherData.temp.max) : Double((weatherData.temp.max) * 9/5 + 32), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        let lowTemp = Measurement(value: isCelsius ? Double(weatherData.temp.min) : Double((Int(weatherData.temp.min) * 9/5) + 32), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        let level = "°"
        self.lowHighTemp.value = ("H: " + String(Int(highTemp.value))) + level + "  " + ("L: " + String(Int(lowTemp.value)) + level)
    }
    
    //MARK:- getDescriptionString
    func getDescriptionString(_ isCelsius: Bool = true){
        let date = Date(timeIntervalSince1970: Double(weatherData.dt))
        var description = ""
        let dayString = Date.getDayOfWeekFrom(date: date)
        let butString = weatherData.temp.day == weatherData.feelsLike.day ? "" : "but"
        let tempValue = Int(weatherData.temp.day)
        let fellLikeValue = Int(weatherData.feelsLike.day)
        let temp = Measurement(value: Double(tempValue), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        let feel =  Measurement(value: Double(fellLikeValue), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        description = "\(dayString): " + "\(weatherData.weather[0].weatherDescription)" + ".The temperature shows " + "\(temp)." + "\(butString) its feels like \(feel)"

        descriptionString.value = description
    }
    
    //MARK:- todaysForecast
    func todaysForecast(_ isCelsius: Bool = true) -> String {
        let date = Date(timeIntervalSince1970: Double(weatherData.dt))
        var description = ""
        let dayString = Date.getDayOfWeekFrom(date: date)
        let butString = weatherData.temp.day == weatherData.feelsLike.day ? "" : "but"
        let tempValue = Int(weatherData.temp.day)
        let fellLikeValue = Int(weatherData.feelsLike.day)
        let temp = Measurement(value: Double(tempValue), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        let feel =  Measurement(value: Double(fellLikeValue), unit: isCelsius ? UnitTemperature.celsius : UnitTemperature.fahrenheit)
        description = "\(dayString): " + "\(weatherData.weather[0].weatherDescription)" + ".The temperature shows " + "\(temp)." + "\(butString) its feels like \(feel)."

        return description
    }
    
    //MARK:- Cell Display Functions
    func prepareCellForDisplay(collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherDetailsCollectionViewCell", for: indexPath) as! WeatherDetailsCollectionViewCell
        if let cellData = detailsDict.value {
            if cellData.count > 0 {
                cell.titleLabel.text = cellData[indexPath.item]["title"]
                cell.valueLabel.text = cellData[indexPath.item]["value"]
            }
        }
        return cell
    }
    
}
