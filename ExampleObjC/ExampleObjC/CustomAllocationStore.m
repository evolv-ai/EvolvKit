//
//  CustomAllocationStore.m
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

#import "CustomAllocationStore.h"

@interface CustomAllocationStore ()
@property (strong, nonatomic) NSMutableDictionary *allocations;
@end

@implementation CustomAllocationStore
    
- (instancetype)init
{
    if (self = [super init]) {
        _allocations = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}   
    
- (NSArray<EvolvRawAllocation *> * _Nonnull)get:(NSString * _Nonnull)participantId {
    if ([_allocations objectForKey:participantId]) {
        return _allocations[participantId];
    }
    
    return @[];
}
    
- (void)put:(NSString * _Nonnull)participantId :(NSArray<EvolvRawAllocation *> * _Nonnull)rawAllocations {
    _allocations[participantId] = rawAllocations;
}
    
@end
