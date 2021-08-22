//
//  RealmObject.swift
//  Test_Project
//
//  Created by Abhijith on 21/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//
import UIKit
import RealmSwift

class WeatherObject : Object {
    
    @Persisted var structData = Data()
    @Persisted var cityName = String()
    @Persisted(primaryKey: true) var id = 0
    
    var myStruct : WeatherModel? {
        get {
            return try? JSONDecoder().decode(WeatherModel.self, from: structData)
        }
        set {
            structData = try! JSONEncoder().encode(newValue)
        }
    }
}
