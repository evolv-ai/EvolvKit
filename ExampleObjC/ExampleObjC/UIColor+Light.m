//
//  UIColor+Light.m
//  ExampleObjC
//
//  Created by divbyzero on 17.12.2019.
//  Copyright © 2019 EvolvKit. All rights reserved.
//

#import "UIColor+Light.h"

@implementation UIColor (Light)

- (BOOL) isLight {
    CGFloat colorBrightness = 0;

    CGColorSpaceRef colorSpace = CGColorGetColorSpace(self.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);

    if(colorSpaceModel == kCGColorSpaceModelRGB){
        const CGFloat *componentColors = CGColorGetComponents(self.CGColor);

        colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    } else {
        [self getWhite:&colorBrightness alpha:0];
    }

    return (colorBrightness >= .5f);
}

@end
