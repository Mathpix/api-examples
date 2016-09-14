//
//  Constants.swift
//  MathPix
//
//  Created by Michael Lee on 3/25/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import Foundation

struct Constants {
    
    //URLS
    static let requestURL = "http://dev-api.mathpix.com/v2/latex"
    
    //Request
    static let boundaryConstant = "----------V2ymHFg03ehbqgZCaKO6jy"
    
    //Request body
    static let bodyDetails = "--\(boundaryConstant)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n" + "Content-Type: image/jpeg\r\n\r\n"
    static let bodyEnd = "\r\n--\(boundaryConstant)--\r\n"
    
    //HUD
    static let HUDMessage = "Sending to server..."
    
    //Numeric constants
    static let barHeight = 45.0
}