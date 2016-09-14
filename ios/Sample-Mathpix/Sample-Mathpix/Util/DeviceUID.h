//
//  DeviceUID.h
//  MathPix
//
//  Created by Tomer Gafner on 1/27/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUID : NSObject

+ (DeviceUID*)instance;
- (NSString*) uid;

@end
