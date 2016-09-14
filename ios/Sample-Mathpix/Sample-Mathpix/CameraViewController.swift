//
//  CameraViewController.swift
//  Sample-Mathpix
//
//  Created by Sergey Glushchenko on 7/18/16.
//  Copyright © 2016 Mathpix. All rights reserved.
//

import UIKit

protocol CameraViewControllerDelegate {
    func capturedLatex(data: NSData?)
}

class CameraViewController: UIViewController, CACameraSessionDelegate {

    @IBOutlet weak var cameraView : CameraSessionView?
    
    var delegate: CameraViewControllerDelegate?
    
    let imageService = ImageService()
    
    let cropOverlay = CropControlOverlay()
    
    var uid = DeviceUID.instance().uid()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
    }

    func setupCamera() {
        self.cameraView?.delegate = self
        self.cameraView?.hideCameraToogleButton()
    }
    
    private func setupOverlay(){
        view.addSubview(cropOverlay)
        cropOverlay.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    @IBAction func backButtonClick(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func flashButtonClick(sender: AnyObject) {
        self.cameraView?.onTapFlashButton()
    }

    //CACameraSessionDelegate method
    func didCaptureImage(image: UIImage!) {
        var resultImage = image
        if let cameraView = self.cameraView {
            //Resize image with aspectRation to screen
            var rect = CGRectZero
            let aspectX = image.size.width / cameraView.bounds.size.width
            let aspectY = image.size.height / cameraView.bounds.size.height
            var aspectRationImage: CGFloat = 0.0
            
            if aspectX > aspectY {
                aspectRationImage = cameraView.bounds.size.width / cameraView.bounds.size.height
                rect.origin.y = 0
                rect.size.height = image.size.height
                
                let widthOfImage = aspectRationImage * image.size.height
                let halfOriginalImage = image.size.width / 2
                let halfNewImage = widthOfImage / 2
                let offsetImageX = halfOriginalImage - halfNewImage
                rect.origin.x = offsetImageX
                rect.size.width = widthOfImage
            }
            else {
                aspectRationImage = cameraView.bounds.size.height / cameraView.bounds.size.width
                rect.origin.x = 0
                rect.size.width = image.size.width
                
                let heightOfImage = aspectRationImage * image.size.width
                let halfOriginalImage = image.size.height / 2
                let halfNewImage = heightOfImage / 2
                let offsetImageY = halfOriginalImage - halfNewImage
                rect.origin.y = offsetImageY
                rect.size.height = heightOfImage
            }
            
            //Crop image with aspectRation to screen. If it not make then result cropped image will scaled  
            resultImage = image.fixOrientation().croppedImage(rect)
            
            let croppedImage = cropOverlay.cropImageAndUpdateDisplay(resultImage, superview: cameraView)
            sendImageToServer(croppedImage)
        }
    }
    
    func sendImageToServer(image:UIImage) {
        //It's need for disable moved crop box
        self.cropOverlay.userInteractionEnabled = false
        self.cropOverlay.cropControl.userInteractionEnabled = false
        self.cameraView?.userInteractionEnabled = false
        imageService.sendImageToServer(self.uid, image: image) { [weak self] (data, error) in
            //It's need for enable moved crop box
            self?.cropOverlay.userInteractionEnabled = true
            self?.cameraView?.userInteractionEnabled = true
            self?.cropOverlay.cropControl.userInteractionEnabled = true
            
            if let resultError = error {
                if let title = resultError.userInfo["title"] as? String {
                    self?.displayError(title: title, error: resultError.localizedDescription)
                }
            }
            else if let resultData = data {
                self?.delegate?.capturedLatex(resultData)
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func displayError(title title: String, error: String) {
        let alertView = UIAlertView(title: title, message: error, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
        cropOverlay.resetView()
    }
    
}
