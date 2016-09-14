//
//  ViewController.swift
//  Sample-Mathpix
//
//  Created by Sergey Glushchenko on 7/18/16.
//  Copyright © 2016 Mathpix. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate, CameraViewControllerDelegate {

    private let showCameraRollSegue = "showCameraRoll"
    
    @IBOutlet weak var webView: UIWebView!
    
    var data: NSData? {
        didSet{
            if (isViewLoaded()){
                updateLatex(data: data)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        if let URL = NSBundle.mainBundle().URLForResource("latex", withExtension: "html") {
            let request = NSURLRequest(URL: URL)
            self.webView.loadRequest(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        updateLatex(data: data)
    }
    
    func updateLatex(data data: NSData?) {
        //data same with data from server without deserialize or any changes
        if let resultData = data,
           let stringJSON = String(data: resultData, encoding: NSUTF8StringEncoding) {
            print(stringJSON)
            let methodInvocation = String(format: "setResultJson(%@);", stringJSON)
            print(methodInvocation)
            webView.stringByEvaluatingJavaScriptFromString(methodInvocation)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showCameraRollSegue {
            if let navController = segue.destinationViewController as? UINavigationController,
                let cameraViewController = navController.topViewController as? CameraViewController {
                cameraViewController.delegate = self
            }
        }
    }
    
    func capturedLatex(data: NSData?) {
        self.data = data
    }
}

