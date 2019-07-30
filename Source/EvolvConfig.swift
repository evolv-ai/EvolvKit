//
//  EvolvConfig.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

public class EvolvConfig {
    
    public enum Default {
        public static let httpScheme: String = "https"
        public static let domain: String = "participants.evolv.ai"
        public static let apiVersion: String = "v1"
        static let allocationStoreSize: Int = 1000
    }
    
    let httpScheme: String
    let domain: String
    let version: String
    let environmentId: String
    let allocationStore: EvolvAllocationStore
    let httpClient: EvolvHttpClient
    let executionQueue = EvolvExecutionQueue.shared
    
    init(httpScheme: String,
         domain: String,
         version: String,
         environmentId: String,
         evolvAllocationStore: EvolvAllocationStore,
         httpClient: EvolvHttpClient
        ) {
        self.httpScheme = httpScheme
        self.domain = domain
        self.version = version
        self.environmentId = environmentId
        self.allocationStore = evolvAllocationStore
        self.httpClient = httpClient
    }
    
    static public func builder(environmentId: String, httpClient: EvolvHttpClient) -> EvolvConfigBuilder {
        return EvolvConfigBuilder(environmentId: environmentId, httpClient: httpClient)
    }
    
}

public class EvolvConfigBuilder {
    
    private var allocationStoreSize = EvolvConfig.Default.allocationStoreSize
    private var httpScheme: String = EvolvConfig.Default.httpScheme
    private var domain: String = EvolvConfig.Default.domain
    private var version: String = EvolvConfig.Default.apiVersion
    private var allocationStore: EvolvAllocationStore?
    
    private var environmentId: String
    private var httpClient: EvolvHttpClient
    
    /**
     Responsible for creating an instance of EvolvConfig.
     - Builds an instance of the EvolvConfig. The only required parameter is the
     customer's environment id.
     
     - Parameters:
     - environmentId: Unique id representing a customer's environment.
     - httpClient: You may pass in any http client of your choice, defaults to EvolvHttpClient.
     - allocationStore: You may pass in any LruCache of your choice, defaults to EvolvAllocationStore.
     */
    init(environmentId: String,
         httpClient: EvolvHttpClient = DefaultEvolvHttpClient(),
         allocationStore: EvolvAllocationStore = DefaultEvolvAllocationStore(size: 1000)) {
        self.environmentId = environmentId
        self.httpClient = httpClient
        self.allocationStore = allocationStore
    }
    
    /**
     - Sets the domain of the underlying evolvParticipant api.
     - Parameters:
     - domain: The domain of the evolvParticipant api.
     - Returns: EvolvConfigBuilder class
     */
    public func set(domain: String) -> EvolvConfigBuilder {
        self.domain = domain
        return self
    }
    
    /**
     Version of the underlying evolvParticipant api.
     - Parameters:
     - version: Representation of the required evolvParticipant api version.
     - Returns: EvolvConfigBuilder class.
     */
    public func set(version: String) -> EvolvConfigBuilder {
        self.version = version
        return self
    }
    
    /**
     EvolvAllocationStore interface.
     - Sets up a custom EvolvAllocationStore. Store needs to implement the
     - Parameters:
     - allocationStore: A custom built allocation store.
     - Returns: EvolvConfigBuilder class
     */
    public func set(allocationStore: EvolvAllocationStore) -> EvolvConfigBuilder {
        self.allocationStore = allocationStore
        return self
    }
    
    /**
     - Tells the SDK to use either http or https.
     - Parameters:
     - scheme: either http or https
     - Returns: EvolvConfigBuilder class
     */
    public func set(httpScheme: String) -> EvolvConfigBuilder {
        self.httpScheme = httpScheme
        return self
    }
    
    /**
     - Sets the DefaultAllocationStores size.
     - Parameters:
     - allocationStoreSize: number of entries allowed in the default allocation store
     - Returns: EvolvClientBuilder class
     */
    public func set(allocationStoreSize: Int) -> EvolvConfigBuilder {
        self.allocationStoreSize = allocationStoreSize
        return self
    }
    
    /**
     - Builds an instance of EvolConfig
     - Returns: an EvolvConfig instance
     */
    public func build() -> EvolvConfig {
        var store: EvolvAllocationStore = DefaultEvolvAllocationStore(size: allocationStoreSize)
        
        if let allocationStore = allocationStore {
            store = allocationStore
        }
        
        return EvolvConfig(httpScheme: httpScheme,
                           domain: domain,
                           version: version,
                           environmentId: environmentId,
                           evolvAllocationStore: store,
                           httpClient: httpClient)
    }
    
}
