//
//  OverlayView.h
//  MathPix
//
//  Created by Michael Lee on 3/12/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef void(^BoxDisplayCallback)();

@interface OverlayView : UIView

- (void)displayBoxes:(NSArray*)boxes completionCallback:(BoxDisplayCallback)callback;
@end
