//
//  WeatherDetailsViewController.swift
//  Test_Project
//
//  Created by Abhijith on 21/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherDetailsViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var celsiusImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var celsiusLabel: UILabel!
    @IBOutlet weak var fellsLikeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsCollectionView: UICollectionView!
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var topBgView: UIView!
    
    //MARK:- Variables
    var weatherData: Daily!
    var weatherViewModel: WeatherDetailsViewModel!
    var location: CLLocation!
    var placeName = ""
    var onClick: ((Bool) -> Void)?
    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.celsiusButton.isSelected = true
        self.placeNameLabel.text = placeName
        self.topBgView.transform = CGAffineTransform(scaleX: 2, y: 2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performDampingAnimation()
        }
        //requestNotification
        self.requestNotification()
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        guard weatherData != nil else {
            return
        }
        self.weatherViewModel = WeatherDetailsViewModel(weatherData: weatherData)
        self.weatherTypeLabel.text = "\(weatherData.weather[0].weatherDescription)".capitalized
        //lowHighTemp
        self.weatherViewModel.lowHighTemp.bind { value in
            self.fellsLikeLabel.text = value
        }
        //descriptionString
        self.weatherViewModel.descriptionString.bind { value in
            self.descriptionLabel.text = value
        }
        //currentTemp
        self.weatherViewModel.currentTemp.bind { value in
            self.celsiusLabel.text = value
        }
        //currentTemp
        self.weatherViewModel.lowHighTemp.bind { value in
            self.fellsLikeLabel.text = value
        }
        
        self.weatherViewModel.detailsDict.bind {_ in
            DispatchQueue.main.async {
                self.detailsCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performAnimation()
    }
    
    //MARK:- Functions
    private func performDampingAnimation() {
        //Bounce Animation
        UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 0.9, initialSpringVelocity: 5,options: [.autoreverse], animations: {
            self.celsiusImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: {_ in
            self.celsiusImageView.transform = .identity
        })
    }
    
    private func performAnimation() {
        UIView.animate(withDuration: 1) {
            self.topBgView.transform = .identity
        }
    }
    
    func requestNotification() {
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    // Schedule Local Notification
                    self.scheduleLocalNotification()
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleLocalNotification()
                break
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional:
                break
            case .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Weather Updates"
        notificationContent.subtitle = "Today's forecast"
        notificationContent.body = self.weatherViewModel.todaysForecast()
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 6, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
    //MARK:- Button Actions
    @IBAction func levelConversionAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        topBgView.shake()
        celsiusImageView.image = UIImage(named: sender.isSelected ? "cImage" : "fImage")
        //Reverse Celsius to Farenheat and vice versa
        self.weatherViewModel.getCurrentTemp(sender.isSelected)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.onClick?(true)
        })
    }
}

//MARK:- Extension
extension WeatherDetailsViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weatherViewModel.detailsDict.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.weatherViewModel.prepareCellForDisplay(collectionView: collectionView, indexPath: indexPath)
    }
}

extension WeatherDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.2, height: 66)
    }
}

extension WeatherDetailsViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
