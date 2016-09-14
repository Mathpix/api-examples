//
//  ImageService.swift
//  MathPix
//
//  Created by Sergey Glushchenko on 6/20/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import UIKit

class ImageService: NSObject {

    var submitImageTask: NSURLSessionDataTask?
    
    func currentSessionConfiguration(uid: String?) -> NSURLSessionConfiguration {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        if let deviceId = uid {
            configuration.HTTPAdditionalHeaders = [
                "deviceId": deviceId
            ]
        }
        
        return configuration
    }
    
    func sendImageToServer(uid: String?, image:UIImage, complitionHandler:((data: NSData?, error: NSError? ) -> Void)?) {
        let request = NSMutableURLRequest()
        let requestUrl = Constants.requestURL
        let URL = NSURL(string: requestUrl)
        let imageData = UIImageJPEGRepresentation(image, 0.9)
        let bodyFirst = Constants.bodyDetails as NSString
        let bodyLast = Constants.bodyEnd as NSString
        let body = NSMutableData()
        
        body.appendData(bodyFirst.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData!)
        body.appendData(bodyLast.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let bodyLength = String(body.length)
        
        request.addValue("4985f625", forHTTPHeaderField: "app_id")
        request.addValue("4423301b832793e217d04bc44eb041d3", forHTTPHeaderField: "app_key")
        request.setValue(
            "multipart/form-data; boundary=" + Constants.boundaryConstant,
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue(bodyLength, forHTTPHeaderField: "Content-Length")
        
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        request.HTTPShouldHandleCookies = false
        request.timeoutInterval = 15
        request.HTTPBody = body
        request.URL = URL
        
        submitImageTask?.cancel()
        
        let session = NSURLSession(configuration: self.currentSessionConfiguration(uid))
        submitImageTask = session.dataTaskWithRequest(request) { (data, response, error) in
            var currentError: NSError? = nil
            var JSONObject: AnyObject?
            if let resultData = data {
                do {
                    JSONObject = try NSJSONSerialization.JSONObjectWithData(resultData, options: NSJSONReadingOptions.MutableLeaves)
                } catch {
                     currentError = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey : "JSON Parse error"])
                    return
                }
                
                if let responseObject = JSONObject as? NSDictionary {
                    if let responseError = responseObject["error"] as? String where responseError.characters.count > 0 {
                        currentError = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey : responseError, "title": "Send image error"])
                    }
                }
            }
            if let resultError = error where resultError.code != NSURLErrorCancelled {
                if resultError.code == NSURLErrorTimedOut {
                    currentError = NSError(domain: "localhost", code: -2, userInfo: [NSLocalizedDescriptionKey : "Our servers are currently experiencing heavy load.  We apologize for the inconvenience.  Please try again later.", "title": "Send image timeout"])
                }
                else {
                    currentError = NSError(domain: "localhost", code: -2, userInfo: [NSLocalizedDescriptionKey : resultError.localizedDescription, "title": "Send image error"])
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                complitionHandler?(data: data, error: currentError)
            })
        }
        
        submitImageTask?.resume()
    }
}
