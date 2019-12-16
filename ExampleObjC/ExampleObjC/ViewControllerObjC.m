//
//  ViewControllerObjC.m
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ViewControllerObjC.h"
#import "EvolvKit-Swift.h"
#import "EvolvClientHelper.h"
#import "UIColor+HexString.h"
#import "UIColor+Light.h"

@interface ViewControllerObjC ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
- (IBAction)didPressCheckOut:(id)sender;
- (IBAction)didPressProductInfo:(id)sender;
@end

@implementation ViewControllerObjC

- (id<EvolvClient>)evolvClient {
    return [EvolvClientHelper shared].client;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    [_checkoutButton titleLabel].font = [UIFont systemFontOfSize:24];
    
    [self.evolvClient subscribeForKey:@"checkout.button.background.color" defaultValue:[[EvolvRawAllocationNode alloc] init:@"#000000"] closure:^(EvolvRawAllocationNode * _Nonnull node) {
        __block ViewControllerObjC *safeSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSString *colorString = [node stringValue];
            UIColor *backgroundColor = [UIColor colorWithHexString:colorString];
            
            [safeSelf.checkoutButton setBackgroundColor:backgroundColor];
            
            if ([backgroundColor isLight]) {
                [safeSelf.checkoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            } else {
                [safeSelf.checkoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        });
    }];
    [self.evolvClient subscribeForKey:@"checkout.button.text" defaultValue:[[EvolvRawAllocationNode alloc] init:@"BUY STUFF"] closure:^(EvolvRawAllocationNode * _Nonnull node) {
        __block ViewControllerObjC *safeSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [safeSelf.checkoutButton setTitle:[node stringValue] forState:UIControlStateNormal];
        });
    }];
    
    [self.evolvClient confirm];
    
}

- (IBAction)didPressCheckOut:(id)sender {
    [self.evolvClient emitEventForKey:@"conversion"];
    _textLabel.text = @"Conversion!";
}

- (IBAction)didPressProductInfo:(id)sender {
    _textLabel.text = @"Some really cool product info";
}

@end
