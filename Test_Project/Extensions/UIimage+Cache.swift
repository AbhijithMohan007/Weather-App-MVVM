//
//  UIimage+Cache.swift
//
//  Created by Abhijith on 20/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setIconFromUrl(iconName: String) {
        self.setImageFromUrl(url: "http://openweathermap.org/img/wn/\(iconName)@2x.png")
    }
    
    //Downloading and Cache image
    func setImageFromUrl(url: String) {
        if let url = URL(string:url) {
            self.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    self.image = value.image
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func rotateDownloadedImageFromUrl(url: String) {
        if let url = URL(string:url) {
            self.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    //                    print("Image: \(value.image). Got from: \(value.cacheType)")
                    self.image = self.rotateImage(image: value.image)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func rotateImage(image:UIImage) -> UIImage
    {
        var rotatedImage = UIImage()
        switch image.imageOrientation
        {
        case .right:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
            
        case .down:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            
        case .left:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            
        default:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }
        
        return rotatedImage
    }
}

extension UIImage {
    //Downloading and Cache image
    func downloadImage(from urlString : String)-> UIImage{
        guard let url = URL.init(string: urlString) else {
            return UIImage.init()
        }
        let resource = ImageResource(downloadURL: url)
        var image = UIImage()
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                print("Image: \(value.image). Got from: \(value.cacheType)")
                image = value.image
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}
