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
    
    [self.evolvClient subscribeForKey:@"ui.layout" defaultValue:[[EvolvRawAllocationNode alloc] init:@"#000000"] closure:^(EvolvRawAllocationNode * _Nonnull node) {
        __block ViewControllerObjC *safeSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSString *colorString = [node stringValue];
            
            if ([colorString isEqualToString:@"option_1"]) {
                [safeSelf.view setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.5 alpha:1.0]];
            } else if ([colorString isEqualToString:@"option_2"]) {
                [safeSelf.view setBackgroundColor:[UIColor colorWithRed:0.6 green:0.9 blue:0.5 alpha:1.0]];
            } else if ([colorString isEqualToString:@"option_3"]) {
                [safeSelf.view setBackgroundColor:[UIColor colorWithRed:32 / 255 green:79 / 255 blue:79 / 255 alpha:1.0]];
            } else if ([colorString isEqualToString:@"option_4"]) {
                [safeSelf.view setBackgroundColor:[UIColor colorWithRed:1.0 green:176 / 255 blue:198 / 255 alpha:1.0]];
            } else {
                [safeSelf.view setBackgroundColor:[UIColor blackColor]];
            }
        });
    }];
    [self.evolvClient subscribeForKey:@"ui.buttons.checkout.text" defaultValue:[[EvolvRawAllocationNode alloc] init:@"BUY STUFF"] closure:^(EvolvRawAllocationNode * _Nonnull node) {
        __block ViewControllerObjC *safeSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [safeSelf.checkoutButton setTitle:[node stringValue] forState:UIControlStateNormal];
            [safeSelf.checkoutButton titleLabel].font = [UIFont systemFontOfSize:24];
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
