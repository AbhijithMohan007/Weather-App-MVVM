//
//  README.md
//  Created by Abhijith on 20/08/21.
//  Copyright © 2021 Abhijith. All rights reserved.
// Purpose: Interview Test for iRoid

# Product Name


Version: 1.0


## Requirements
- Xcode 11.0 above
- iOS 12 and above

## Architecture
MVVM
- Model : HomeModel.swift
- View : HomeViewController.swift
- ViewModel : HomeViewModel.Swift

## New Features!
You can also:
- Find the vehicles on the map while clicking the 
- Can change the map theme colours, 3 styles(night,silver,light)
- Can able to find the corresponding car location by tapping the card view.
- Can sort the cars on the map based on the model 

## Thirdparty libraries(Pod Files)

### King Fisher
- Asynchronous image downloading and caching.
- Loading image from either URLSession-based networking or local provided data.
- Useful image processors and filters provided.
-  Multiple-layer hybrid cache for both memory and disk.

- Prefetching images and showing them from cache to boost your app.
-  UIButton to directly set an image from a URL.
- Customizable placeholder and indicator while loading images.

### Alamofire '~> 5.2'
- Chainable Request / Response Methods
- URL / JSON Parameter Encoding
- Upload File / Data / Stream / MultipartFormData
- Download File using Request or Resume Data
- Authentication with URLCredential
- HTTP Response Validation
- Network Reachability
- Comprehensive Unit and Integration Test Coverage


## Project Files
### NetworkLayer
- Created a singleton network class named Networkmanager.Swift
- Which passed the response as JsonData inside the completion handler as Result<Data,Error>.
- Now have only created for .GET method.We can create for .POST method in future.
- Api call are down through the Alamofire library
 ***Usage***
           NetworkManager.shared.apiCallFor(API URL)


## Extensions

### UIimage+Cache
    - Created Extension Class for Uiimage for caching and storing the image using kingfisher
    
### UIstring+Extension
    - For securing the string live confidential informations
      eg: Car License number,


### BorderButton
     - IBDesignable button for handle form the Storyboard

### UIViewcontroller+Toast
      - Created global toast view for all the view controller
      - we can simply cal self.showToast("message") inside the UIviewcontroller


#KignFisher for image download and cache
      pod 'Kingfisher'

 #Alamofire for network calls
      pod 'Alamofire', '~> 5.2'
