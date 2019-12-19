//
//  UIColor+HexString.h
//  ExampleObjC
//
//  Created by divbyzero on 17.12.2019.
//  Copyright © 2019 EvolvKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HexString)

+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end

NS_ASSUME_NONNULL_END
