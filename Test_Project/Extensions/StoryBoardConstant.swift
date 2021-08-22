//
//  StoryBoardConstant.swift
//  Test_Project
//
//  Created by Abhijith on 21/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit

protocol StoryboardScene: RawRepresentable {

    static var storyboardName: String {get}
}

extension StoryboardScene {

    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: self.storyboardName, bundle: nil)
    }

    func viewController() -> UIViewController {
        // swiftlint:disable:next force_cast
        return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue as! String)
    }
}

extension UIStoryboard {
    struct Main {
        private enum Identifier: String, StoryboardScene {
            static let storyboardName           = "Main"
            case dayListVC                      = "DaysListViewController"
            case weatherDetailsVC               = "WeatherDetailsViewController"
           
        }
        static func dayListVC() -> UIViewController {
            return Identifier.dayListVC.viewController()
        }
        static func weatherDetailsVC() -> UIViewController {
            return Identifier.weatherDetailsVC.viewController()
        }
    }
}
