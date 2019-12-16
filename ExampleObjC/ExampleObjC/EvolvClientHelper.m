//
//  EvolvClientHelper.m
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

#import "EvolvClientHelper.h"
#import "CustomAllocationStore.h"

@interface EvolvClientHelper ()
@property (strong, nonatomic) id<EvolvHttpClient> httpClient;
@property (strong, nonatomic) id<EvolvAllocationStore> store;
@end

@implementation EvolvClientHelper

+ (instancetype)shared {
    static EvolvClientHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        /*
         When you receive the fetched json from the participants API, it will be as type String.
         If you use the DefaultEvolvHttpClient, the string will be parsed to EvolvRawAllocation array
         (required data type for EvolvAllocationStore).
         
         This example shows how the data can be structured in your view controllers,
         your implementation can work directly with the raw string and serialize into EvolvRawAllocation.
         */
        _httpClient = [[DefaultEvolvHttpClient alloc] init];
        _store = [[CustomAllocationStore alloc] init];
        
        /// Build config with custom timeout and custom allocation store
        /// Set client to any one of your environmentIds. sandbox is an example id.
        EvolvConfig *config = [[[EvolvConfig builderWithEnvironmentId:@"a0cf1cfaab" httpClient:_httpClient] setWithAllocationStore:_store] build];
        
        // set error or debug logLevel for debugging
        [config setWithLogLevel:EvolvLogLevelDebug];
        
        /// Initialize the client with a stored user
        /// fetches allocations from Evolv, and stores them in a custom store
        _client = [EvolvClientFactory createClientWithConfig:config
                                                 participant:[[[EvolvParticipant builder] setWithUserId:@"sandbox_user"] build]
                                                    delegate:self];
        
        /// - Initialize the client with a new user
        /// - Uncomment this line if you prefer this initialization.
        // _client = [EvolvClientFactory createClientWithConfig:config participant:nil delegate:nil];
    }
    
    return self;
}

- (void)didChangeClientStatus:(enum EvolvClientStatus)status {
    self.didChangeClientStatus(status);
}

@end
