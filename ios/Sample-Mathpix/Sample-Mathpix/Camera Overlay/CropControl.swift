//
//  CropControl.swift
//  SliderTest
//
//  Created by Gilbert Jolly on 30/04/2016.
//  Copyright © 2016 Gilbert Jolly. All rights reserved.
//
import PureLayout
import UIKit

class CropControl: UIView {
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var initialTouchOffset = CGPointZero
    var panStateCallback: ((state: UIGestureRecognizerState) -> ())?
    let imageOverlay = UIImageView()
    var boxOverlay : OverlayView?
    
    //The length of each line from the corner (each corner control is double this size)
    let cornerLength :CGFloat = 40
    
    init(){
        super.init(frame: CGRectZero)
        setupView()
        setupCorners()
        setupSizeConstraints()
    }
    
    func setupView(){
        backgroundColor = UIColor.clearColor()
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        addSubview(imageOverlay)
        imageOverlay.autoPinEdgesToSuperviewEdges()
        imageOverlay.userInteractionEnabled = false
    }
    
    func setupSizeConstraints() {
        widthConstraint = autoSetDimension(.Width, toSize: 200)
        widthConstraint?.priority = UILayoutPriorityDefaultHigh
        heightConstraint = autoSetDimension(.Height, toSize: 100)
        heightConstraint?.priority = UILayoutPriorityDefaultHigh
        
        autoSetDimension(.Width, toSize: cornerLength * 1.5, relation: .GreaterThanOrEqual)
        autoSetDimension(.Height, toSize: cornerLength * 1.5, relation: .GreaterThanOrEqual)
    }
    
    func resetView(){
        imageOverlay.image = nil
        widthConstraint?.constant = 250
        heightConstraint?.constant = 100
        
        boxOverlay?.removeFromSuperview()
    }
    
    func displayBoxes(boxes: [AnyObject], callback: () -> ()){
        self.boxOverlay?.removeFromSuperview()
        
        let boxOverlay = OverlayView()
        addSubview(boxOverlay)
        boxOverlay.autoPinEdgesToSuperviewEdges()
        layoutIfNeeded()
        
        boxOverlay.backgroundColor = UIColor.clearColor()
        boxOverlay.userInteractionEnabled = false
        boxOverlay.displayBoxes(boxes, completionCallback: callback)
        boxOverlay.hidden = false
        boxOverlay.setNeedsDisplay()
        
        self.boxOverlay = boxOverlay
    }
    
    func setupCorners(){
        
        //Create corner views, defined by the edges they stick to, and the direction of the lines
        let topLeft = addControlToCornerWithEdges([.Top, .Left], lineDirections: [.Down, .Right])
        let topRight = addControlToCornerWithEdges([.Top, .Right], lineDirections: [.Down, .Left])
        let bottomLeft = addControlToCornerWithEdges([.Bottom, .Left], lineDirections: [.Up, .Right])
        let bottomRight = addControlToCornerWithEdges([.Bottom, .Right], lineDirections: [.Up, .Left])
        
        let corners = [topLeft, topRight, bottomLeft, bottomRight]
        for corner in corners {
            handleMovementForCorner(corner)
        }
    }
    
    //Stick the corner to the edges in pinEdges, tell the corners how to draw themselves
    func addControlToCornerWithEdges(pinEdges: [ALEdge], lineDirections: [LineDirection]) -> CropControlCorner {
        
        let controlCorner = CropControlCorner(lineDirections: lineDirections)
        addSubview(controlCorner)
        for edge in pinEdges {
            controlCorner.autoPinEdgeToSuperviewEdge(edge, withInset: -cornerLength)
        }
        //We double the corner length for the width, as the corner view is a box surrounding the corner
        controlCorner.autoSetDimensionsToSize(CGSize(width: cornerLength * 2, height: cornerLength * 2))
        
        return controlCorner
    }
    
    func handleMovementForCorner(corner: CropControlCorner) {
        let rec = UIPanGestureRecognizer()
        rec.addTarget(self, action: #selector(cornerMoved))
        corner.addGestureRecognizer(rec)
    }

    func cornerMoved(gestureRecogniser: UIPanGestureRecognizer){
        if let corner = gestureRecogniser.view as? CropControlCorner {
            let viewCenter = CGPoint(x: frame.width/2, y: frame.height/2)
            let touchCenter = gestureRecogniser.locationInView(self)
            
            
            //Store the initial offset of the touch, so we can get delta's later
            if gestureRecogniser.state == .Began {
                let offsetX = corner.center.x - touchCenter.x
                let offsetY = corner.center.y - touchCenter.y
                initialTouchOffset = CGPoint(x: offsetX, y: offsetY)
                
                resetView()
            }

            //Set the width + height of the view based on the distance of the corner from the center
            widthConstraint?.constant = 2 * abs(touchCenter.x - viewCenter.x + initialTouchOffset.x)
            heightConstraint?.constant = 2 * abs(touchCenter.y - viewCenter.y + initialTouchOffset.y)
            
            //Let the owner know something happened
            self.panStateCallback?(state: gestureRecogniser.state)
        }
    } 
    
    
    //Much of the corner control view is outside the bounds of this view,
    //We override hitTest to allow all of the view to recieve touches
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for subView in subviews {
            let subViewPoint = subView.convertPoint(point, fromView: self)
            if subView.pointInside(subViewPoint, withEvent: event) && subView.userInteractionEnabled {
                return subView.hitTest(subViewPoint, withEvent: event)
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CropControl: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.userInteractionEnabled
    }
}
