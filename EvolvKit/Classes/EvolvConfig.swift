//
//  EvolvConfig.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

public class EvolvConfig {
  
  static public let DEFAULT_HTTP_SCHEME = "https"
  static public let DEFAULT_DOMAIN = "participants.evolv.ai"
  static public let DEFAULT_API_VERSION = "v1"
  
  private let httpScheme: String
  private let domain: String
  private let version: String
  private let environmentId: String
  private let evolvAllocationStore: AllocationStoreProtocol
  private let httpClient: HttpProtocol
  private let executionQueue = ExecutionQueue.shared
  
  fileprivate static var DEFAULT_ALLOCATION_STORE_SIZE = 1000
  
  init(_ httpScheme: String, _ domain: String, _ version: String,
       _ environmentId: String, _ evolvAllocationStore: AllocationStoreProtocol,
       _ httpClient: HttpProtocol
    ) {
    self.httpScheme = httpScheme
    self.domain = domain
    self.version = version
    self.environmentId = environmentId
    self.evolvAllocationStore = evolvAllocationStore
    self.httpClient = httpClient
  }
  
  static public func builder(environmentId: String, httpClient: HttpProtocol) -> ConfigBuilder {
    return ConfigBuilder(environmentId: environmentId, httpClient: httpClient)
  }
  
  public func getHttpScheme() -> String { return self.httpScheme }
  
  public func getDomain() -> String { return self.domain }
  
  public func getVersion() -> String { return self.version }
  
  public func getEnvironmentId() -> String { return self.environmentId }
  
  public func getEvolvAllocationStore() -> AllocationStoreProtocol {
    return self.evolvAllocationStore
  }
  
  public func getHttpClient() -> HttpProtocol {
    return self.httpClient
  }
  
  public func getExecutionQueue() -> ExecutionQueue { return self.executionQueue }
}


/// Note: Swift builder pattern is implemented with adjacent classes.

public class ConfigBuilder {

  private var allocationStoreSize = EvolvConfig.DEFAULT_ALLOCATION_STORE_SIZE
  private var httpScheme: String = EvolvConfig.DEFAULT_HTTP_SCHEME
  private var domain: String = EvolvConfig.DEFAULT_DOMAIN
  private var version: String = EvolvConfig.DEFAULT_API_VERSION
  private var allocationStore: AllocationStoreProtocol?
  
  private var environmentId: String
  private var httpClient: HttpProtocol
  
  /**
   Responsible for creating an instance of EvolvConfig.
   - Builds an instance of the EvolvConfig. The only required parameter is the
   customer's environment id.
   
   - Parameters:
      - environmentId: Unique id representing a customer's environment.
      - httpClient: You may pass in any http client of your choice, defaults to EvolvHttpClient.
      - allocationStore: You may pass in any LruCache of your choice, defaults to EvolvAllocationStore.
   */
  
  fileprivate init(environmentId: String, httpClient: HttpProtocol = EvolvHttpClient(),
                   allocationStore: AllocationStoreProtocol = DefaultAllocationStore(size: 1000)) {
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
  
  public func setDomain(domain: String) -> ConfigBuilder {
    self.domain = domain
    return self
  }
  
  /**
   Version of the underlying evolvParticipant api.
   - Parameters:
      - version: Representation of the required evolvParticipant api version.
   - Returns: EvolvConfigBuilder class.
   */
  public func setVersion(version: String) -> ConfigBuilder {
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
  
  public func setEvolvAllocationStore(allocationStore: AllocationStoreProtocol) -> ConfigBuilder {
    self.allocationStore = allocationStore
    return self
  }
  
  /**
   - Tells the SDK to use either http or https.
   - Parameters:
   - scheme: either http or https
   - Returns: EvolvConfigBuilder class
   */
  
  public func setHttpScheme(scheme: String) -> ConfigBuilder {
    self.httpScheme = scheme
    return self
  }
  
  /**
   - Sets the DefaultAllocationStores size.
   - Parameters:
   - size: number of entries allowed in the default allocation store
   - Returns: EvolvClientBuilder class
   */
  
  public func setDefaultAllocationStoreSize(size: Int) -> ConfigBuilder {
    self.allocationStoreSize = size
    return self
  }
  
  /**
   - Builds an instance of EvolConfig
   - Returns: an EvolvConfig instance
   */
  
  public func build() -> EvolvConfig {
    var store : AllocationStoreProtocol = DefaultAllocationStore(size: allocationStoreSize)
    if let allocStore = self.allocationStore {
      store = allocStore
    }
    return EvolvConfig(self.httpScheme, self.domain, self.version, self.environmentId, store, self.httpClient)
  }
}
