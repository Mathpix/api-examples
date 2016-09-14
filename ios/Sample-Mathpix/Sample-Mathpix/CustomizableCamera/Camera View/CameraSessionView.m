//
//  CACameraSessionDelegate.h
//
//  Created by Christopher Cohen & Gabriel Alvarado on 1/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

#import "CameraSessionView.h"
#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

//Custom UI classes
#import "CameraShutterButton.h"
#import "CameraToggleButton.h"
#import "CameraFlashButton.h"
#import "CameraDismissButton.h"
#import "CameraFocalReticule.h"
#import "Constants.h"


@interface CameraSessionView () <CaptureSessionManagerDelegate>
{
    //Size of the UI elements variables
    CGSize shutterButtonSize;
    CGSize topBarSize;
    CGSize barButtonItemSize;
    
    //Variable vith the current camera being used (Rear/Front)
    CameraType cameraBeingUsed;
}

//Primative Properties
@property (readwrite) BOOL animationInProgress;

//Object References
@property (nonatomic, strong) CaptureSessionManager *captureManager;
@property (nonatomic, strong) CameraShutterButton *cameraShutter;
@property (nonatomic, strong) CameraToggleButton *cameraToggle;
@property (nonatomic, strong) CameraFlashButton *cameraFlash;
@property (nonatomic, strong) CameraDismissButton *cameraDismiss;
@property (nonatomic, strong) CameraFocalReticule *focalReticule;
@property (nonatomic, strong) UIView *topBarView;


//Temporary/Diagnostic properties
@property (nonatomic, strong) UILabel *ISOLabel, *apertureLabel, *shutterSpeedLabel;

@end

@implementation CameraSessionView
-(void)drawRect:(CGRect)rect {
    if (self) {
        _animationInProgress = NO;
        [self setupCaptureManager:RearFacingCamera];
        cameraBeingUsed = RearFacingCamera;
        [self composeInterface];
                [_captureManager.captureSession startRunning];
    }
  
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

#pragma mark - Setup

-(void)setupCaptureManager:(CameraType)camera {
    
    // remove existing input
    AVCaptureInput* currentCameraInput = (self.captureManager.captureSession.inputs)[0];
    [self.captureManager.captureSession removeInput:currentCameraInput];
    
    
    
    _captureManager = nil;
    
    //Create and configure 'CaptureSessionManager' object
    _captureManager = [CaptureSessionManager new];
    
    // indicate that some changes will be made to the session
    [self.captureManager.captureSession beginConfiguration];
    
    if (_captureManager) {
        
        //Configure
        _captureManager.delegate = self;
        [_captureManager initiateCaptureSessionForCamera:camera];
        [_captureManager addStillImageOutput];
        [_captureManager addVideoPreviewLayer];
        [self.captureManager.captureSession commitConfiguration];
        
        //Preview Layer setup
        CGRect layerRect = self.layer.bounds;
        (_captureManager.previewLayer).bounds = layerRect;
        (_captureManager.previewLayer).position = CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect));
        
        //Apply animation effect to the camera's preview layer
        CATransition *applicationLoadViewIn =[CATransition animation];
        applicationLoadViewIn.duration = 0.6;
        applicationLoadViewIn.type = kCATransitionReveal;
        applicationLoadViewIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [_captureManager.previewLayer addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
      

        //Add to self.view's layer
      [self.layer addSublayer:_captureManager.previewLayer];
    }
}

-(void)composeInterface {
    
    
    //Adding notifier for orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    //Define adaptable sizing variables for UI elements to the right device family (iPhone or iPad)
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Declare the sizing of the UI elements for iPad
        shutterButtonSize = CGSizeMake(self.bounds.size.width * 0.1, self.bounds.size.width * 0.1);
        topBarSize        = CGSizeMake(self.frame.size.width, self.frame.size.height * 0.1);
        barButtonItemSize = CGSizeMake([UIScreen mainScreen].bounds.size.height * 0.04, [UIScreen mainScreen].bounds.size.height * 0.08);
    } else
    {
        //Declare the sizing of the UI elements for iPhone
        shutterButtonSize = CGSizeMake(self.bounds.size.width * 0.2, self.bounds.size.width * 0.2);
        topBarSize        = CGSizeMake(self.frame.size.width, 34);
        barButtonItemSize = CGSizeMake(50, 50);
    }
    
    
    //Create shutter button
     _cameraShutter = [CameraShutterButton new];
	   _cameraShutter.isBlue = false;

	
    if (_captureManager) {
        
        //Button Visual attribution
        _cameraShutter.frame = (CGRect){0,0, shutterButtonSize};
        _cameraShutter.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - 60);
        _cameraShutter.tag = ShutterButtonTag;
        _cameraShutter.backgroundColor = [UIColor clearColor];
        
        //Button target
        [_cameraShutter addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraShutter];
    }
    
    //Create the top bar and add the buttons to it
          //Add the flash button
#warning Flash button don't create
//        _cameraFlash = [CameraFlashButton new];
        if (_cameraFlash) {
            _cameraFlash.frame = (CGRect){0,0, barButtonItemSize};
            _cameraFlash.center = CGPointMake((self.frame.size.width*.15), self.frame.size.height - 60);
            _cameraFlash.tag = FlashButtonTag;
          _cameraFlash.backgroundColor = [UIColor clearColor];
          [_cameraFlash addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_cameraFlash];
        }
        //Add the camera toggle button
        _cameraToggle = [CameraToggleButton new];
        if (_cameraToggle) {
            _cameraToggle.frame = (CGRect){0,0, barButtonItemSize};
            _cameraToggle.center = CGPointMake(_topBarView.center.x * 1.20, _topBarView.center.y);
            _cameraToggle.tag = ToggleButtonTag;
						//[_topBarView addSubview:_cameraToggle];
        }
        
        //Add the camera dismiss button
        _cameraDismiss = [CameraDismissButton new];
        if (_cameraDismiss) {
            _cameraDismiss.frame = (CGRect){0,0, barButtonItemSize};
            _cameraDismiss.center = CGPointMake(20, _topBarView.center.y);
            _cameraDismiss.tag = DismissButtonTag;
						//  [_topBarView addSubview:_cameraDismiss];
        }
				//ADD TITLE LABEL
        //Attribute and configure all buttons in the bar's subview
        for (UIButton *button in _topBarView.subviews) {
					if(button.tag != 10){
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
					}
        }
    
    //Create the focus reticule UIView
    _focalReticule = [CameraFocalReticule new];
    
    if (_focalReticule) {
        
        _focalReticule.frame = (CGRect){0,0, 60, 60};
        _focalReticule.backgroundColor = [UIColor clearColor];
        _focalReticule.hidden = YES;
        [self addSubview:_focalReticule];
    }   
    
    //Create the gesture recognizer for the focus tap
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    if (singleTapGestureRecognizer) [self addGestureRecognizer:singleTapGestureRecognizer];
    
    
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([cameraDevice respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)] && cameraDevice.autoFocusRangeRestrictionSupported) {
        // If we are on an iOS version that supports AutoFocusRangeRestriction and the device supports it
        // Set the focus range to "near"
        if ([cameraDevice lockForConfiguration:nil]) {
            cameraDevice.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
            [cameraDevice unlockForConfiguration];
        }
    }
}


- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self focusAtPoint:self.center completionHandler:^{}];
}
#pragma mark - User Interaction

//This is pretty strange, I'd just use addTarget:selector,
//then use "if (_animationInProgress) return;" in each method
//feels pretty obfuscated
-(void)inputManager:(id)sender {
    
    //If animation is in progress, ignore input
    if (_animationInProgress) return;
    
    //If sender does not inherit from 'UIButton', return
    if (![sender isKindOfClass:[UIButton class]]) return;
    
    //Input manager switch
    switch (((UIButton *)sender).tag) {
        case ShutterButtonTag:  [self onTapShutterButton];  return;
        case ToggleButtonTag:   [self onTapToggleButton];   return;
        case FlashButtonTag:    [self onTapFlashButton];    return;
        case DismissButtonTag:  [self onTapDismissButton];  return;
    }
}

- (void)onTapShutterButton {
    
    //Animate shutter release
    [self animateShutterRelease];
    
    //Capture image from camera
    [_captureManager captureStillImage];
}

- (void)onTapFlashButton {
    BOOL enable = !self.captureManager.isTorchEnabled;
    self.captureManager.enableTorch = enable;
}

- (void)onTapToggleButton {
    if (cameraBeingUsed == RearFacingCamera) {
        [self setupCaptureManager:FrontFacingCamera];
        cameraBeingUsed = FrontFacingCamera;
        [self composeInterface];
        [_captureManager.captureSession startRunning];
        _cameraFlash.hidden = YES;
    } else {
        [self setupCaptureManager:RearFacingCamera];
        cameraBeingUsed = RearFacingCamera;
        [self composeInterface];
        [_captureManager.captureSession startRunning];
        _cameraFlash.hidden = NO;
    }
}

- (void)onTapDismissButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y*3);
    } completion:^(BOOL finished) {
        [_captureManager stop];
        [self removeFromSuperview];
    }];
}

- (void)focusGesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateRecognized) {
            CGPoint location = [sender locationInView:self];
            
            [self focusAtPoint:location completionHandler:^{
                 [self animateFocusReticuleToPoint:location];
             }];
        }
    }
}

#pragma mark - Animation

- (void)animateShutterRelease {
    
    _animationInProgress = YES; //Disables input manager
    
    [UIView animateWithDuration:.05 animations:^{
        _cameraShutter.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.05 animations:^{
            _cameraShutter.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            
            _animationInProgress = NO; //Enables input manager
        }];
    }];
}

- (void)animateFocusReticuleToPoint:(CGPoint)targetPoint
{
    _animationInProgress = YES; //Disables input manager
    
    (self.focalReticule).center = targetPoint;
    self.focalReticule.alpha = 0.0;
    self.focalReticule.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
         self.focalReticule.alpha = 1.0;
     } completion:^(BOOL finished) {
         [UIView animateWithDuration:0.4 animations:^{
              self.focalReticule.alpha = 0.0;
          }completion:^(BOOL finished) {
              
              _animationInProgress = NO; //Enables input manager
          }];
     }];
}


- (void)orientationChanged:(NSNotification *)notification{
    [_captureManager updateOrientation];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _captureManager.previewLayer.frame = self.layer.bounds;
    _cameraShutter.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - 60);
}

#pragma mark - Camera Session Manager Delegate Methods

-(void)cameraSessionManagerDidCaptureImage
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(didCaptureImage:)])
            [self.delegate didCaptureImage:self.captureManager.stillImage];
        
        if ([self.delegate respondsToSelector:@selector(didCaptureImageWithData:)])
            [self.delegate didCaptureImageWithData:self.captureManager.stillImageData];
    }
}

-(void)cameraSessionManagerFailedToCaptureImage {
}

-(void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType {
}

-(void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics {
}

#pragma mark - Helper Methods

- (void)refocus{
    [self focusAtPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) completionHandler:^{}];
}

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if (device.focusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        //Lock camera for configuration if possible
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
            }
            
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                device.focusPointOfInterest = pointOfInterest;
                device.focusMode = AVCaptureFocusModeAutoFocus;
            }
            
            if(device.exposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                device.exposurePointOfInterest = pointOfInterest;
                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            
            [device unlockForConfiguration];
            
            completionHandler();
        }
    }
    else { completionHandler(); }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)takeImage{
    [self.captureManager captureStillImage];
}

#pragma mark - API Functions

- (void)setTopBarColor:(UIColor *)topBarColor
{
    _topBarView.backgroundColor = topBarColor;
}

- (void)hideFlashButton
{
    _cameraFlash.hidden = YES;
}

- (void)hideCameraToogleButton
{
    _cameraToggle.hidden = YES;
}

- (void)hideDismissButton
{
    _cameraDismiss.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
