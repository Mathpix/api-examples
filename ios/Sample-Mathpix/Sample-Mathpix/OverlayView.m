//
//  OverlayView.m
//  MathPix
//
//  Created by Michael Lee on 3/12/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

#import "OverlayView.h"

#define FadeAnimationDuration 0.2f

@interface OverlayView ()

@property (nonatomic, strong) NSMutableArray *boxViews;

@end

@implementation OverlayView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.boxViews = [NSMutableArray array];
        self.translatesAutoresizingMaskIntoConstraints = false;
    }
    return self;
}


- (void)displayBoxes:(NSArray*)boxes completionCallback:(BoxDisplayCallback)callback{
    
    for (UIView *box in self.boxViews) {
        [self removeBox:box];
    }
    [self.boxViews removeAllObjects];
    
    NSArray *sortedBoxes = [boxes sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"xmax"
                                                                                              ascending:YES]]];
    
    CGFloat delay = 0;
    for (NSDictionary *boxDef in sortedBoxes) {
        NSString *xStart = [boxDef objectForKey:@"xmin"];
        NSString *yStart = [boxDef objectForKey:@"ymin"];
        NSString *xMax = [boxDef objectForKey:@"xmax"];
        NSString *yMax = [boxDef objectForKey:@"ymax"];
        
        NSInteger w = self.frame.size.width;
        NSInteger h = self.frame.size.height;
        
        CGRect drawRect = CGRectMake((xStart.doubleValue * w), (yStart.doubleValue * h), (xMax.doubleValue - xStart.doubleValue) * w, (yMax.doubleValue - yStart.doubleValue) * h);
        
        delay += 0.04;
        [self addBoxWithFrame:drawRect delay:delay];
    }
    
    NSInteger animationDuration = FadeAnimationDuration + delay + 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        callback();
    });
}

- (void)addBoxWithFrame:(CGRect)frame delay:(CGFloat)delay{
    UIView *box = [[UIView alloc] initWithFrame:frame];
    box.backgroundColor = [UIColor clearColor];
    box.layer.borderColor = [UIColor whiteColor].CGColor;
    box.layer.borderWidth = 2;
    [self addSubview:box];
    [self.boxViews addObject:box];
    
    box.alpha = 0;
    box.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:FadeAnimationDuration delay:delay usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        box.alpha = 1;
        box.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {}];
}

- (void)removeBox:(UIView*)box{
    [UIView animateWithDuration:0.075 animations:^{
        box.alpha = 0;
        box.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }completion:^(BOOL finished) {
        [box removeFromSuperview];
    }];
}

@end
