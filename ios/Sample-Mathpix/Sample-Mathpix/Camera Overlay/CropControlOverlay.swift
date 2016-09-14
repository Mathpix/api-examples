//
//  CropControl.swift
//  SliderTest
//
//  Created by Gilbert Jolly on 30/04/2016.
//  Copyright © 2016 Gilbert Jolly. All rights reserved.
//

import PureLayout
import Foundation


class CropControlOverlay: UIView {
    let cropControl = CropControl()
    let statusLabel = UILabel()
    var wasUsedToTakeImage: Bool = false
    var regionSelectedCallback: (()->())?
    var draggingBeganCallback: (()->())?
    
    init() {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        
        addSubview(cropControl)
        cropControl.autoCenterInSuperview()
        cropControl.panStateCallback = { [unowned self] state in
            if state == .Began {
//                self.statusLabel.text = "Release to take photo"
                self.draggingBeganCallback?()
            }
            if state == .Ended {
                self.wasUsedToTakeImage = true
                self.statusLabel.text = "Click on capture button when ready"
                self.regionSelectedCallback?()
            }
        }
        
        addSubview(statusLabel)
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: cropControl, withOffset: 10)
        statusLabel.autoAlignAxis(.Vertical, toSameAxisOfView: cropControl)
        resetView()
    }
    
    
    func resetView(){
        statusLabel.text = "Drag box around equation"
        wasUsedToTakeImage = false
        cropControl.resetView()
    }
    
    func cropImageAndUpdateDisplay(image: UIImage, superview: UIView) -> UIImage{
        let croppedImage = cropImage(image, superview: superview)
        displayCroppedImage(croppedImage)
        return croppedImage
    }
    
    func cropImage(image: UIImage, superview: UIView) -> UIImage{
        let cropRect = cropControl.convertRect(cropControl.bounds, toView: superview)
        
        let imageSize = image.size
        let xScale = imageSize.width / superview.bounds.size.width
        let yScale = imageSize.height / superview.bounds.size.height
        
        let cropX = cropRect.origin.x * xScale
        let cropWidth = cropRect.width * xScale
        let cropY = cropRect.origin.y * yScale
        let cropHeight = cropRect.height * yScale
        
        let scaledCropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight)
        
        return image.fixOrientation().croppedImage(scaledCropRect)
    }
    
    func displayCroppedImage(image: UIImage){
        wasUsedToTakeImage = false
        cropControl.imageOverlay.image = image
        statusLabel.text = "Thinking..."
    }
    
    //We only want to allow the cropView to get hit events,
    //this view should let them fall through to buttons below
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let cropViewPoint = cropControl.convertPoint(point, fromView: self)
        return cropControl.hitTest(cropViewPoint, withEvent: event)
    }
    
    //Swift... ¯\_(ツ)_/¯
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}