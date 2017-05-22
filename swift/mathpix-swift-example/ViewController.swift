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
            processSingleImage(imageName: assetFileName);
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
}

