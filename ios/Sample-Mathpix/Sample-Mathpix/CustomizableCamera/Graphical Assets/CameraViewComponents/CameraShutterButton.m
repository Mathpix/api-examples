//
//  CameraShutterButton.m
//  CameraWithAVFoundation
//
//  Created by Gabriel Alvarado on 1/24/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

#import "CameraShutterButton.h"
#import "CameraStyleKitClass.h"

@implementation CameraShutterButton

- (void)drawRect:(CGRect)rect {
	if (self.isBlue) {
		[CameraStyleKitClass drawCameraShutterWithFrame:self.bounds style:true];
	}
	else {
		[CameraStyleKitClass drawCameraShutterWithFrame:self.bounds style:false];
	}
}

@end
