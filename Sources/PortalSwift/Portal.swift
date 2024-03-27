//
//  Portal.swift
//
//  Created by Portal Labs, Inc.
//  Copyright © 2022 Portal Labs, Inc. All rights reserved.
//

import Foundation
import Mpc

/// The main Portal class.
public class Portal {
  public var address: String? {
    do {
      return try self.keychain.getAddress()
    } catch {
      return nil
    }
  }

  public var chainId: Int {
    self.provider.chainId
  }

  public let apiKey: String
  public let autoApprove: Bool
  public let backup: BackupOptions
  public var client: Client?
  public let gatewayConfig: [Int: String]
  public let isMocked: Bool
  public let keychain: PortalKeychain
  public let api: PortalApi
  public let mpc: PortalMpc
  private let binary: Mobile
  private let featureFlags: FeatureFlags?

  public let provider: PortalProvider

  private let apiHost: String
  private let mpcHost: String
  private let version: String

  /// Create a Portal instance.
  /// - Parameters:
  ///   - apiKey: The Client API key. You can obtain this through Portal's REST API.
  ///   - backup: The backup options to use.
  ///   - chainId: The chainId you want the provider to use.
  ///   - keychain: An instance of PortalKeychain.
  ///   - gatewayConfig: A dictionary of chainIds (keys) and gateway URLs (values).
  ///   - isSimulator: (optional) Whether you are testing on the iOS simulator or not.
  ///   - address: (optional) An address.
  ///   - apiHost: (optional) Portal's API host.
  ///   - autoApprove: (optional) Auto-approve transactions.
  ///   - mpcHost: (optional) Portal's MPC API host.
  public init(
    apiKey: String,
    backup: BackupOptions,
    chainId: Int,
    keychain: PortalKeychain,
    gatewayConfig: [Int: String],
    // Optional
    isSimulator: Bool = false,
    version: String = "v6",
    autoApprove: Bool = false,
    apiHost: String = "api.portalhq.io",
    mpcHost: String = "mpc.portalhq.io",
    featureFlags: FeatureFlags? = nil,
    isMocked: Bool = false
  ) throws {
    // Basic setup
    self.binary = isMocked ? MockMobileWrapper() : MobileWrapper()
    self.apiHost = apiHost
    self.apiKey = apiKey
    self.autoApprove = autoApprove
    self.backup = backup
    self.gatewayConfig = gatewayConfig
    self.client = try Portal.getClient(apiHost, apiKey, self.binary, isMocked: isMocked)
    keychain.clientId = self.client?.id
    self.isMocked = isMocked
    self.keychain = keychain
    self.mpcHost = mpcHost
    self.version = version
    self.featureFlags = featureFlags

    if version != "v6" {
      throw PortalArgumentError.versionNoLongerSupported(message: "MPC Version is not supported. Only version 'v6' is currently supported.")
    }

    // Initialize the PortalProvider
    self.provider = try PortalProvider(
      apiKey: apiKey,
      chainId: chainId,
      gatewayConfig: gatewayConfig,
      keychain: keychain,
      autoApprove: autoApprove,
      apiHost: apiHost,
      mpcHost: mpcHost,
      version: version,
      featureFlags: featureFlags
    )

    // Initialize the Portal API
    self.api = PortalApi(apiKey: apiKey, apiHost: apiHost, provider: self.provider, featureFlags: self.featureFlags)

    // Ensure storage adapters have access to the Portal API
    if backup.gdrive != nil {
      backup.gdrive?.api = self.api
    }
    if backup.icloud != nil {
      backup.icloud?.api = self.api
    }

    if #available(iOS 16, *) {
      if backup.passkeyStorage != nil {
        backup.passkeyStorage?.portalApi = self.api
        backup.passkeyStorage?.apiKey = self.apiKey
      }
    }

    // Initialize Mpc
    self.mpc = PortalMpc(
      apiKey: apiKey,
      api: self.api,
      keychain: keychain,
      storage: backup,
      isSimulator: isSimulator,
      host: mpcHost,
      version: version,
      mobile: self.binary,
      apiHost: self.apiHost,
      featureFlags: self.featureFlags
    )

    // Capture analytics.
    do {
      try self.api.identify { _ in }
      self.api.track(event: MetricsEvents.portalInitialized.rawValue, properties: [:])
    } catch {
      // Do nothing.
    }
  }

  /// Create a Portal instance. This initializer is used by unit tests and mocks.
  /// - Parameters:
  ///   - apiKey: The Client API key. You can obtain this through Portal's REST API.
  ///   - backup: The backup options to use.
  ///   - chainId: The chainId you want the provider to use.
  ///   - keychain: An instance of PortalKeychain.
  ///   - gatewayConfig: A dictionary of chainIds (keys) and gateway URLs (values).
  ///   - mpc:  Portal's mpc class
  ///   - api:  Portal's api class
  ///   - binary: Portal's mpc binary class
  ///   - isSimulator: (optional) Whether you are testing on the iOS simulator or not.
  ///   - address: (optional) An address.
  ///   - apiHost: (optional) Portal's API host.
  ///   - autoApprove: (optional) Auto-approve transactions.
  ///   - mpcHost: (optional) Portal's MPC API host.

  public init(
    apiKey: String,
    backup: BackupOptions,
    chainId: Int,
    keychain: PortalKeychain,
    gatewayConfig: [Int: String],
    // Optional
    isSimulator: Bool = false,
    version: String = "v6",
    autoApprove: Bool = false,
    apiHost: String = "api.portalhq.io",
    mpcHost: String = "mpc.portalhq.io",
    mpc: PortalMpc?,
    api: PortalApi?,
    binary: Mobile?,
    featureFlags: FeatureFlags? = nil,
    isMocked: Bool = false
  ) throws {
    // Basic setup
    self.apiHost = apiHost
    self.apiKey = apiKey
    self.autoApprove = autoApprove
    self.backup = backup
    self.gatewayConfig = gatewayConfig
    self.binary = binary ?? MobileWrapper()
    self.client = try Portal.getClient(apiHost, apiKey, self.binary, isMocked: isMocked)
    keychain.clientId = self.client?.id
    self.isMocked = isMocked
    self.keychain = keychain
    self.mpcHost = mpcHost
    self.version = version
    self.featureFlags = featureFlags

    if version != "v6" {
      throw PortalArgumentError.versionNoLongerSupported(message: "MPC Version is not supported. Only version 'v6' is currently supported.")
    }

    // Initialize the PortalProvider
    self.provider = isMocked
      ? try MockPortalProvider(
        apiKey: apiKey,
        chainId: chainId,
        gatewayConfig: gatewayConfig,
        keychain: keychain,
        autoApprove: autoApprove,
        apiHost: apiHost,
        mpcHost: mpcHost,
        version: version,
        featureFlags: featureFlags
      )
      : try PortalProvider(
        apiKey: apiKey,
        chainId: chainId,
        gatewayConfig: gatewayConfig,
        keychain: keychain,
        autoApprove: autoApprove,
        apiHost: apiHost,
        mpcHost: mpcHost,
        version: version,
        featureFlags: featureFlags
      )

    // Initialize the Portal API
    self.api = api ?? PortalApi(apiKey: apiKey, apiHost: apiHost, provider: self.provider)

    // Ensure storage adapters have access to the Portal API
    if backup.gdrive != nil {
      backup.gdrive?.api = api
    }
    if backup.icloud != nil {
      backup.icloud?.api = api
    }

    if #available(iOS 16, *) {
      if backup.passkeyStorage != nil {
        backup.passkeyStorage?.portalApi = self.api
        backup.passkeyStorage?.apiKey = self.apiKey
      }
    }

    // Initialize Mpc
    self.mpc = mpc ?? PortalMpc(
      apiKey: apiKey,
      api: self.api,
      keychain: keychain,
      storage: backup,
      isSimulator: isSimulator,
      host: mpcHost,
      version: version,
      mobile: self.binary
    )

    // Capture analytics.
    do {
      try self.api.identify { _ in }
      self.api.track(event: MetricsEvents.portalInitialized.rawValue, properties: [:])
    } catch {
      // Do nothing.
    }
  }

  /**********************************
   * Wallet Helper Methods
   **********************************/

  public func backupWallet(
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    completion: @escaping (Result<String>) -> Void,
    progress: ((MpcStatus) -> Void)? = nil
  ) {
    self.mpc.backup(method: method, backupConfigs: backupConfigs, completion: completion, progress: progress)
  }

  public func createWallet(
    completion: @escaping (Result<String>) -> Void,
    progress: ((MpcStatus) -> Void)? = nil
  ) {
    self.mpc.generate(completion: completion, progress: progress)
  }

  public func recoverWallet(
    cipherText: String,
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    completion: @escaping (Result<String>) -> Void,
    progress: ((MpcStatus) -> Void)? = nil
  ) {
    self.mpc.recover(cipherText: cipherText, method: method, backupConfigs: backupConfigs, completion: completion, progress: progress)
  }

  public func ejectPrivateKey(
    clientBackupCiphertext: String,
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    orgBackupShare: String,
    completion: @escaping (Result<String>) -> Void
  ) {
    self.mpc.ejectPrivateKey(clientBackupCiphertext: clientBackupCiphertext, method: method, backupConfigs: backupConfigs, orgBackupShare: orgBackupShare, completion: completion)
  }

  public func provisionWallet(
    cipherText: String,
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    completion: @escaping (Result<String>) -> Void,
    progress: ((MpcStatus) -> Void)? = nil
  ) {
    self.recoverWallet(cipherText: cipherText, method: method, backupConfigs: backupConfigs, completion: completion, progress: progress)
  }

  /**********************************
   * Provider Helper Methods
   **********************************/

  public func emit(_ event: Events.RawValue, data: Any) {
    _ = self.provider.emit(event: event, data: data)
  }

  public func ethEstimateGas(
    transaction: ETHTransactionParam,
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.EstimateGas.rawValue,
      params: [transaction]
    ), completion: completion)
  }

  public func ethGasPrice(
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.GasPrice.rawValue,
      params: []
    ), completion: completion)
  }

  public func ethGetBalance(
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    guard let address = provider.address else {
      completion(Result(error: PortalProviderError.noAddress))
      return
    }
    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.GetBalance.rawValue,
      params: [address, "latest"]
    ), completion: completion)
  }

  public func ethSendTransaction(
    transaction: ETHTransactionParam,
    completion: @escaping (Result<TransactionCompletionResult>) -> Void
  ) {
    self.provider.request(payload: ETHTransactionPayload(
      method: ETHRequestMethods.SendTransaction.rawValue,
      params: [transaction]
    ), completion: completion)
  }

  public func ethSign(message: String, completion: @escaping (Result<RequestCompletionResult>) -> Void) {
    guard let address = provider.address else {
      completion(Result(error: PortalProviderError.noAddress))
      return
    }

    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.Sign.rawValue,
      params: [
        address,
        message,
      ]
    ), completion: completion)
  }

  public func ethSignTransaction(
    transaction: ETHTransactionParam,
    completion: @escaping (Result<TransactionCompletionResult>) -> Void
  ) {
    self.provider.request(payload: ETHTransactionPayload(
      method: ETHRequestMethods.SignTransaction.rawValue,
      params: [transaction]
    ), completion: completion)
  }

  public func ethSignTypedDataV3(
    message: String,
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    guard let address = provider.address else {
      completion(Result(error: PortalProviderError.noAddress))
      return
    }

    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.SignTypedDataV3.rawValue,
      params: [address, message]
    ), completion: completion)
  }

  public func ethSignTypedData(
    message: String,
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    guard let address = provider.address else {
      completion(Result(error: PortalProviderError.noAddress))
      return
    }

    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.SignTypedDataV4.rawValue,
      params: [address, message]
    ), completion: completion)
  }

  public func on(event: Events.RawValue, callback: @escaping (Any) -> Void) {
    _ = self.provider.on(event: event, callback: callback)
  }

  public func once(event: Events.RawValue, callback: @escaping (Any) -> Void) {
    _ = self.provider.once(event: event, callback: callback)
  }

  public func personalSign(
    message: String,
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    guard let address = provider.address else {
      completion(Result(error: PortalProviderError.noAddress))
      return
    }

    self.provider.request(payload: ETHRequestPayload(
      method: ETHRequestMethods.PersonalSign.rawValue,
      params: [
        message,
        address,
      ]
    ), completion: completion)
  }

  public func request(
    method: ETHRequestMethods.RawValue,
    params: [Any],
    completion: @escaping (Result<RequestCompletionResult>) -> Void
  ) {
    self.provider.request(payload: ETHRequestPayload(
      method: method,
      params: params
    ), completion: completion)
  }

  /// Set the chainId on the instance and update MPC and Provider chainId
  /// - Parameters:
  ///   - to: The chainId to use for processing wallet transactions
  /// - Returns: Void
  public func setChainId(to: Int) throws {
    _ = try self.provider.setChainId(value: to)
  }

  /****************************************
   * Keychain Helper Methods
   ****************************************/

  public func deleteAddress() throws {
    try self.keychain.deleteAddress()
  }

  public func deleteSigningShare() throws {
    try self.keychain.deleteSigningShare()
  }

  /****************************************
   * Portal Connect Helper Methods
   ****************************************/

  public func createPortalConnectInstance(
    webSocketServer: String = "connect.portalhq.io"
  ) throws -> PortalConnect {
    try PortalConnect(
      self.apiKey,
      self.provider.chainId,
      self.keychain,
      self.gatewayConfig,
      webSocketServer,
      self.autoApprove,
      self.apiHost,
      self.mpcHost,
      self.version
    )
  }

  /****************************************
   * Private Methods
   ****************************************/

  private static func getClient(_ apiHost: String, _ apiKey: String, _ mobile: Mobile, isMocked: Bool) throws -> Client {
    // Create URL.
    let apiUrl = apiHost.starts(with: "localhost") ? "http://\(apiHost)" : "https://\(apiHost)"

    // Call the MPC service to retrieve the client.
    let response = isMocked ? mockClientResult : mobile.MobileGetMe("\(apiUrl)/api/v1/clients/me", apiKey)

    // Parse the client.
    let jsonData = response.data(using: .utf8)!
    let clientResult: ClientResult = try JSONDecoder().decode(ClientResult.self, from: jsonData)

    guard clientResult.error.code == 0 else {
      throw PortalMpcError(clientResult.error)
    }

    guard let client = clientResult.data else {
      throw PortalArgumentError.unableToGetClient
    }

    return client
  }
}

/*****************************************
 * Supporting Enums & Structs
 *****************************************/

enum PortalProviderError: Error, Equatable {
  case invalidChainId(_ message: String)
  case invalidRpcResponse
  case noAddress
  case noRpcUrlFoundForChainId(_ message: String)
  case unsupportedRequestMethod(_ message: String)
}

/// The list of backup methods for PortalSwift.
public enum BackupMethods: String {
  case GoogleDrive = "GDRIVE"
  case iCloud = "ICLOUD"
  case local = "CUSTOM"
  case Password = "PASSWORD"
  case Passkey = "PASSKEY"
  case Unknown = "UNKNOWN"

  init?(fromString: String) {
    self.init(rawValue: fromString)
  }
}

/// Gateway URL errors.
public enum PortalArgumentError: Error {
  case invalidGatewayConfig
  case noGatewayConfigForChain(chainId: Int)
  case versionNoLongerSupported(message: String)
  case unableToGetClient
}

public enum PortalCurve: String, Codable {
  case ED25519
  case SECP256K1

  init?(fromString: String) {
    self.init(rawValue: fromString)
  }
}

public enum PortalNamespace: String, Codable {
  case eip155
  case solana
}

public enum PortalSharePairStatus: String, Codable {
  case complete
  case incomplete

  init?(fromString: String) {
    self.init(rawValue: fromString)
  }
}

public enum PortalSharePairType: String, Codable {
  case backup
  case signing

  init?(fromString: String) {
    self.init(rawValue: fromString)
  }
}
