//
//  ViewController.swift
//  mathpix-swift-example
//
//  Created by admin on 5/22/17.
//  Copyright © 2017 Mathpix. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let assetFileName = getAssetFile(imageName: "limit") {
            //processSingleImage(imageName: assetFileName)
            processSingleImage1(imageName: assetFileName)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func getAssetFile(imageName : String?) -> String? {
        return Bundle.main.path(forResource: imageName, ofType: ".jpg");
    }
    
    func processSingleImage(imageName : String) {
        if let data = NSData(contentsOfFile: imageName) {
            let base64String = data.base64EncodedString(options: .init(rawValue: 0))
            let parameters : Parameters = [
                "url" : "data:image/jpeg;base64," + base64String
            ]
            
            Alamofire.request("https://api.mathpix.com/v3/latex",
                              method: .post,
                              parameters : parameters,
                              encoding: JSONEncoding.default,
                              headers: [
                                "app_id" : "mathpix",
                                "app_key" : "139ee4b61be2e4abcfb1238d9eb99902"
                ])
                .responseJSON{ response in
                if let JSON = response.result.value {
                    print("\(JSON)")
                }
            }
        }
    }
    
    func processSingleImage1(imageName : String) {
        if let data = NSData(contentsOfFile: imageName) {
            let base64String = data.base64EncodedString(options: .init(rawValue: 0))
            let parameters = [
                "url" : "data:image/jpeg;base64," + base64String
            ]
            
            let headers = [
                "content-type": "application/json",
                "app_id": "mathpix",
                "app_key": "139ee4b61be2e4abcfb1238d9eb99902"
            ]
            do {
                let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                let request = NSMutableURLRequest(url: NSURL(string: "https://api.mathpix.com/v3/latex")! as URL,
                                                  cachePolicy: .useProtocolCachePolicy,
                                                  timeoutInterval: 60.0)
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headers
                request.httpBody = postData as Data
                
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    if (error != nil) {
                        print("Error: \(error!)")
                    } else {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                            print("Result: \(json)")
                            
                        } catch {
                            print(error)
                        }
                    }
                })
                
                dataTask.resume()
            } catch {
                print(error)
            }
        }
    }
}

