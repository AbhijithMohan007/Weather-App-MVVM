//
//  Created by Abhijith on 20/08/21
//  Copyright © 2019 Apple. All rights reserved.
//

//Category Class For UIFont.Change the font here to change the app font
import UIKit
extension UIFont {
    //MARK: setAppFontLight
    class func setAppFontLight(_ size:CGFloat)->(UIFont){
        return UIFont(name: "Poppins-Light", size: size)!
    }
    //MARK: setAppFont
    class func setAppFont(_ size:CGFloat)->(UIFont){
        return UIFont(name: "Poppins-Regular", size: size)!
    }
    //MARK: setAppFontMedium
    class func setAppFontMedium(_ size:CGFloat)->(UIFont){
        return UIFont(name: "Poppins-Medium", size: size)!
    }
    //MARK: setAppFontBold
    class func setAppFontBold(_ size:CGFloat)->(UIFont){
        return UIFont(name: "Poppins-Bold", size: size)!
    }
}
