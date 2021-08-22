//
//  NetworkManager.swift
//
//  Created by Abhijith on 20/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager {
    typealias responseCompletion = ((Result<WeatherModel,Error>) -> Void)
    static let shared = NetworkManager()
    var latitude: Double?
    var longitude: Double?
    
    init() {}
    
    private func buildWeatherUrl() -> String {
        guard latitude != nil || longitude != nil else {
            return ""
        }
        return BaseUrl.weatherApi.rawValue + "/onecall?lat=\(latitude!)&lon=\(longitude!)&units=metric&appid=\(ApiKey.weatherKey.rawValue)"
    }
    
    func weatherApiCall(completion: @escaping responseCompletion) {
        // Do any additional setup after loading the view.
        guard let url = URL(string: buildWeatherUrl()) else {
            completion(.failure(NetworkError.parameterNil))
            return
        }
        
        let request = AF.request(url)
        request.responseJSON { (response) in
            switch (response.result) {
            case.success(_):
                do {
                    if let responseData = response.data {
                        let items = try JSONDecoder().decode(WeatherModel.self, from: responseData)
                        completion(.success(items))
                        //print("sucess")
                    } else {
                        completion(.failure(NetworkError.encodingFail))
                    }
                } catch DecodingError.dataCorrupted(let context) {
                    print(context)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            case .failure(_):
                completion(.failure(NetworkError.errorInResponse))
            }
        }
    }
}

public enum NetworkError: String, Error {
    case parameterNil = "Parameter Were Nil"
    case encodingFail = "Encoding Fails"
    case errorInResponse = "Something went wrong please try after sometimes"
}
