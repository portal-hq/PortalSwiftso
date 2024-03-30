//
//  PortalMpc.swift
//
//  Created by Portal Labs, Inc.
//  Copyright © 2022 Portal Labs, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import Mpc
import Security

/// The main interface with Portal's MPC service.
public class PortalMpc {
  private var address: String? {
    do {
      return try self.keychain.getAddress()
    } catch {
      return nil
    }
  }

  private var signingShare: String? {
    do {
      return try self.keychain.getSigningShare()
    } catch {
      return nil
    }
  }

  private let api: PortalApi
  private let apiHost: String
  private let apiKey: String
  private var backupOptions: [BackupMethods: PortalStorage] = [:]
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  private let featureFlags: FeatureFlags?
  private let host: String
  private let isSimulator: Bool
  private let keychain: PortalKeychain
  private let logger = PortalLogger()
  private let mobile: Mobile
  private let version: String

  private let rsaHeader = "-----BEGIN RSA KEY-----\n"
  private let rsaFooter = "\n-----END RSA KEY-----"
  private var isWalletModificationInProgress: Bool = false
  private var isMock: Bool = false
  private var mpcMetadata: MpcMetadata

  /// Create an instance of Portal's MPC service.
  public init(
    apiKey: String,
    api: PortalApi,
    keychain: PortalKeychain,
    host: String = "mpc.portalhq.io",
    isSimulator: Bool = false,
    version: String = "v6",
    mobile: Mobile,
    apiHost: String = "api.portalhq.io",
    featureFlags: FeatureFlags? = nil
  ) {
    // Basic setup
    self.api = api
    self.apiKey = apiKey
    self.host = host
    self.keychain = keychain
    self.version = version
    self.mobile = mobile
    self.apiHost = apiHost.starts(with: "localhost") ? "http://\(apiHost)" : "https://\(apiHost)"

    // Other stuff
    self.featureFlags = featureFlags
    self.isSimulator = isSimulator
    self.mpcMetadata = MpcMetadata(
      clientPlatform: "NATIVE_IOS",
      isMultiBackupEnabled: featureFlags?.isMultiBackupEnabled,
      mpcServerVersion: self.version,
      optimized: featureFlags?.optimized ?? false
    )
  }

  public func getBinaryVersion() -> String {
    self.mobile.MobileGetVersion()
  }

  /*******************************************
   * Public functions
   *******************************************/

  /// Creates a backup share, encrypts it, and stores the private key in cloud storage.
  /// - Parameters:
  ///   - method: Either gdrive or icloud.
  ///   - completion: The callback which includes the cipherText of the backed up share.
  public func backup(
    _ method: BackupMethods,
    usingProgressCallback: ((MpcStatus) -> Void)? = nil
  ) async throws -> PortalMpcBackupResponse {
    if self.version != "v6" {
      throw MpcError.backupNoLongerSupported("[PortalMpc] Backup is no longer supported for this version of MPC. Please use `version = \"v6\"`.")
    }

    guard !self.isWalletModificationInProgress else {
      throw MpcError.walletModificationAlreadyInProgress
    }

    self.isWalletModificationInProgress = true

    do {
      // Obtain the signing share.
      let shares = try await keychain.getShares()
      usingProgressCallback?(MpcStatus(status: .readingShare, done: false))

      // Derive the storage and throw an error if none was provided.
      guard let storage = self.backupOptions[method] else {
        throw MpcError.unsupportedStorageMethod
      }
      guard try await storage.validateOperations() else {
        throw MpcError.unexpectedErrorOnBackup("Could not validate operations.")
      }

      usingProgressCallback?(MpcStatus(status: MpcStatuses.generatingShare, done: false))
      // Generate both backup shares in parallel
      let generateResponse = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PortalMpcGenerateResponse, Error>) in
        Task {
          var generateResponse: PortalMpcGenerateResponse = [:]

          // Run both backups in parallel
          if let ed25519SigningShare = shares[PortalCurve.ED25519.rawValue] {
            do {
              async let mpcShare = try getBackupShare(.ED25519, withMethod: method, andSigningShare: ed25519SigningShare.share)

              usingProgressCallback?(MpcStatus(status: .parsingShare, done: false))
              let shareData = try encoder.encode(await mpcShare)
              guard let shareString = String(data: shareData, encoding: .utf8) else {
                throw MpcError.unexpectedErrorOnBackup("Unable to stringify ED25519 share.")
              }

              generateResponse["ED25519"] = try await PortalMpcGeneratedShare(
                id: mpcShare.backupSharePairId ?? "",
                share: shareString
              )
            } catch {
              continuation.resume(throwing: error)
              return
            }
          }
          if let secp256k1SigningShare = shares[PortalCurve.SECP256K1.rawValue] {
            do {
              async let mpcShare = try getBackupShare(.SECP256K1, withMethod: method, andSigningShare: secp256k1SigningShare.share)

              usingProgressCallback?(MpcStatus(status: .parsingShare, done: false))
              let shareData = try encoder.encode(await mpcShare)
              guard let shareString = String(data: shareData, encoding: .utf8) else {
                throw MpcError.unexpectedErrorOnBackup("Unable to stringify SECP256K1 share.")
              }

              generateResponse["SECP256K1"] = try await PortalMpcGeneratedShare(
                id: mpcShare.backupSharePairId ?? "",
                share: shareString
              )
            } catch {
              continuation.resume(throwing: error)
            }
          }

          continuation.resume(returning: generateResponse)
        }
      }

      let responseData = try encoder.encode(generateResponse)
      guard let responseString = String(data: responseData, encoding: .utf8) else {
        throw MpcError.unexpectedErrorOnBackup("Unable to stringify into GenerateResponse")
      }

      usingProgressCallback?(MpcStatus(status: .encryptingShare, done: false))
      let encryptResult = try await storage.encrypt(responseString)

      usingProgressCallback?(MpcStatus(status: .storingShare, done: false))
      let success = try await storage.write(encryptResult.key)
      if !success {
        throw MpcError.unexpectedErrorOnBackup("Unable to write encryption key.")
      }

      // Update the share statuses
      let shareIds = generateResponse.values.map { share in
        share.id
      }
      try await self.api.updateShareStatus(.backup, status: .STORED_CLIENT_BACKUP_SHARE_KEY, sharePairIds: shareIds)

      // Refresh the client
      try await self.api.refreshClient()
      try await self.keychain.loadMetadata()

      // Send the last progress update
      usingProgressCallback?(MpcStatus(status: .done, done: true))
      self.isWalletModificationInProgress = false

      // Return the Backup response
      return PortalMpcBackupResponse(cipherText: encryptResult.cipherText, shareIds: shareIds)
    } catch {
      self.isWalletModificationInProgress = false
      throw error
    }
  }

  public func eject(
    _ method: BackupMethods,
    withCipherText: String,
    andOrganizationBackupShare: String,
    usingProgressCallback _: ((MpcStatus) -> Void)? = nil
  ) async throws -> String {
    if self.version != "v6" {
      throw MpcError.backupNoLongerSupported("[PortalMpc] Eject is no longer supported for this version of MPC. Please use `version = \"v6\"`.")
    }

    guard let storage = self.backupOptions[method] else {
      throw MpcError.unexpectedErrorOnEject("Backup method \(method.rawValue) not registered.")
    }

    let decryptionKey = try await storage.read()

    let decryptedString = try await storage.decrypt(withCipherText, withKey: decryptionKey)
    guard let decryptedData = decryptedString.data(using: .utf8) else {
      throw MpcError.unexpectedErrorOnEject("Unable to convert decrypted data.")
    }

    var generateResponse: PortalMpcGenerateResponse = [:]
    do {
      generateResponse = try self.decoder.decode(PortalMpcGenerateResponse.self, from: decryptedData)
    } catch {
      let backupShare = try decoder.decode(MpcShare.self, from: decryptedData)
      generateResponse["SECP256K1"] = PortalMpcGeneratedShare(
        id: backupShare.backupSharePairId ?? "",
        share: decryptedString
      )
    }

    let privateKeys = try await withCheckedThrowingContinuation { continuation in
      let response = generateResponse
      Task {
        do {
          var addresses: [PortalNamespace: String] = [:]

          if let secp256k1Share = response["SECP256K1"] {
            let ejectResponse = self.mobile.MobileEjectWalletAndDiscontinueMPC(secp256k1Share.share, andOrganizationBackupShare)
            guard let jsonData = ejectResponse.data(using: .utf8) else {
              throw JSONParseError.stringToDataConversionFailed
            }

            let ejectResult: EjectResult = try JSONDecoder().decode(EjectResult.self, from: jsonData)
            let privateKey = ejectResult.privateKey

            addresses[.eip155] = privateKey

            _ = try await self.api.eject()

            continuation.resume(returning: addresses)
            return
          }

          continuation.resume(returning: addresses)
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }

    guard let eip155PrivateKey = privateKeys[.eip155] else {
      throw MpcError.unexpectedErrorOnEject("Unable to find address in addresses map.")
    }

    return eip155PrivateKey
  }

  public func generate(withProgressCallback: ((MpcStatus) -> Void)? = nil) async throws -> [PortalNamespace: String?] {
    if self.version != "v6" {
      throw MpcError.backupNoLongerSupported("[PortalMpc] Generate is no longer supported for this version of MPC. Please use `version = \"v6\"`.")
    }

    guard !self.isWalletModificationInProgress else {
      throw MpcError.walletModificationAlreadyInProgress
    }

    self.isWalletModificationInProgress = true

    do {
      // Generate both backup shares in parallel
      let generateResponse = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PortalMpcGenerateResponse, Error>) in
        Task { [self] in
          do {
            withProgressCallback?(MpcStatus(status: .generatingShare, done: false))

            var generateResponse: PortalMpcGenerateResponse = [:]

            async let ed25519Generate = try self.getSigningShare(.ED25519)
            async let secp256k1Generate = try self.getSigningShare(.SECP256K1)

            let (ed25519MpcShare, secp256k1MpcShare) = try await (ed25519Generate, secp256k1Generate)

            withProgressCallback?(MpcStatus(status: .parsingShare, done: false))

            // Parse ED25519 Share
            let ed25519ShareData = try self.encoder.encode(ed25519MpcShare)
            guard let ed25519ShareString = String(data: ed25519ShareData, encoding: .utf8) else {
              throw MpcError.unexpectedErrorOnBackup("Unable to stringify ED25519 share.")
            }
            generateResponse["ED25519"] = PortalMpcGeneratedShare(
              id: ed25519MpcShare.signingSharePairId ?? "",
              share: ed25519ShareString
            )

            // Parse SECP256K1 Share
            let secp256k1ShareData = try self.encoder.encode(secp256k1MpcShare)
            guard let secp256k1ShareString = String(data: secp256k1ShareData, encoding: .utf8) else {
              throw MpcError.unexpectedErrorOnBackup("Unable to stringify ED25519 share.")
            }
            generateResponse["SECP256K1"] = PortalMpcGeneratedShare(
              id: secp256k1MpcShare.signingSharePairId ?? "",
              share: secp256k1ShareString
            )

            continuation.resume(returning: generateResponse)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }

      withProgressCallback?(MpcStatus(status: .storingShare, done: false))
      try await self.keychain.setShares(generateResponse)

      // Update share statuses
      let shareIds: [String] = generateResponse.values.map { share in
        share.id
      }
      try await self.api.updateShareStatus(.signing, status: .STORED_CLIENT, sharePairIds: shareIds)

      // Reset the metadata in the Keychain
      try await self.api.refreshClient()
      try await self.keychain.loadMetadata()

      withProgressCallback?(MpcStatus(status: .done, done: false))
      self.isWalletModificationInProgress = false

      let addresses = try await keychain.getAddresses()

      return addresses
    } catch {
      self.isWalletModificationInProgress = false
      throw error
    }
  }

  public func recover(
    _ method: BackupMethods,
    withCipherText: String,
    usingProgressCallback: ((MpcStatus) -> Void)? = nil
  ) async throws -> [PortalNamespace: String?] {
    if self.version != "v6" {
      throw MpcError.backupNoLongerSupported("[PortalMpc] Backup is no longer supported for this version of MPC. Please use `version = \"v6\"`.")
    }

    guard !self.isWalletModificationInProgress else {
      throw MpcError.walletModificationAlreadyInProgress
    }

    self.isWalletModificationInProgress = true

    guard let storage = self.backupOptions[method] else {
      throw MpcError.unexpectedErrorOnRecover("Storage method \(method.rawValue) not registered.")
    }

    do {
      let recoverResponse = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PortalMpcGenerateResponse, Error>) in
        Task {
          do {
            usingProgressCallback?(MpcStatus(status: .decryptingShare, done: false))
            let decryptionKey = try await storage.read()

            let decryptedString = try await storage.decrypt(withCipherText, withKey: decryptionKey)
            guard let decryptedData = decryptedString.data(using: .utf8) else {
              throw MpcError.unexpectedErrorOnRecover("Unable to parse decrypted data.")
            }
            let backupResponse = try decoder.decode(PortalMpcGenerateResponse.self, from: decryptedData)

            var recoverResponse: PortalMpcGenerateResponse = [:]
            if let ed25519Share = backupResponse[PortalCurve.ED25519.rawValue] {
              //  The share's already been backed up, recover it
              async let ed25519MpcShare = try recoverSigningShare(.ED25519, withMethod: method, andBackupShare: ed25519Share.share)

              let shareData = try encoder.encode(await ed25519MpcShare)
              guard let shareString = String(data: shareData, encoding: .utf8) else {
                throw MpcError.unexpectedErrorOnBackup("Unable to stringify ED25519 share.")
              }

              recoverResponse["ED25519"] = try await PortalMpcGeneratedShare(
                id: ed25519MpcShare.signingSharePairId ?? "",
                share: shareString
              )
            } // In the future, we'll want to figure out if we can generate the other wallet at this point

            if let secp256k1Share = backupResponse[PortalCurve.SECP256K1.rawValue] {
              async let secp256k1MpcShare = try recoverSigningShare(.SECP256K1, withMethod: method, andBackupShare: secp256k1Share.share)

              let shareData = try encoder.encode(await secp256k1MpcShare)
              guard let shareString = String(data: shareData, encoding: .utf8) else {
                throw MpcError.unexpectedErrorOnBackup("Unable to stringify SECP256K1 share.")
              }

              recoverResponse["SECP256K1"] = try await PortalMpcGeneratedShare(
                id: secp256k1MpcShare.signingSharePairId ?? "",
                share: shareString
              )
            }

            continuation.resume(returning: recoverResponse)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }

      usingProgressCallback?(MpcStatus(status: .storingShare, done: false))
      try await self.keychain.setShares(recoverResponse)

      // Update share statuses
      let shareIds: [String] = recoverResponse.values.map { share in
        share.id
      }

      try await self.api.updateShareStatus(.signing, status: .STORED_CLIENT, sharePairIds: shareIds)

      // Reset the metadata in the Keychain
      try await self.api.refreshClient()
      try await self.keychain.loadMetadata()

      usingProgressCallback?(MpcStatus(status: .done, done: false))
      self.isWalletModificationInProgress = false

      let addresses = try await keychain.getAddresses()

      return addresses
    } catch {
      self.isWalletModificationInProgress = false
      throw error
    }
  }

  public func registerBackupMethod(_ method: BackupMethods, withStorage: PortalStorage) {
    var storage = withStorage
    storage.api = self.api

    self.backupOptions[method] = storage
  }

  public func setGDriveConfiguration(clientId: String, folderName: String) throws {
    guard let storage = backupOptions[.GoogleDrive] as? GDriveStorage else {
      throw MpcError.backupMethodNotRegistered("PortalMpc.setGDriveConfig() - Could not find an instance of `GDriveStorage`. Please use `portal.registerBackupMethod()`")
    }

    storage.clientId = clientId
    storage.folder = folderName
  }

  public func setGDriveView(_ view: UIViewController) throws {
    guard let storage = backupOptions[.GoogleDrive] as? GDriveStorage else {
      throw MpcError.backupMethodNotRegistered("PortalMpc.setGDriveView() - Could not find an instance of `GDriveStorage`. Please use `portal.registerBackupMethod()`")
    }

    storage.view = view
  }

  @available(iOS 16, *)
  public func setPasskeyAuthenticationAnchor(_ anchor: ASPresentationAnchor) throws {
    guard let storage = backupOptions[.Passkey] as? PasskeyStorage else {
      throw MpcError.backupMethodNotRegistered("PortalMpc.setPasskeyAuthenticationAnchor() - Could not find an instance of `PasskeyStorage`. Please use `portal.registerBackupMethod()`")
    }

    storage.anchor = anchor
  }

  @available(iOS 16, *)
  public func setPasskeyConfiguration(relyingParty: String, webAuthnHost: String) throws {
    guard let storage = backupOptions[.Passkey] as? PasskeyStorage else {
      throw MpcError.backupMethodNotRegistered("PortalMpc.setPasskeyConfiguration() - Could not find an instance of `PasskeyStorage`. Please use `portal.registerBackupMethod()`")
    }

    storage.relyingParty = relyingParty
    storage.webAuthnHost = webAuthnHost
  }

  public func setPassword(_ value: String) throws {
    guard let storage = backupOptions[.Password] as? PasswordStorage else {
      throw MpcError.backupMethodNotRegistered("Could not find an instance of `PasswordStorage`. Please use `portal.registerBackupMethod()`")
    }

    storage.password = value
  }

  /*******************************************
   * Private functions
   *******************************************/

  private func getBackupShare(
    _ forCurve: PortalCurve,
    withMethod: BackupMethods,
    andSigningShare: String
  ) async throws -> MpcShare {
    let mpcShare = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MpcShare, Error>) in
      do {
        // Stringify the MPC metadata.
        var metadata = self.mpcMetadata
        metadata.curve = forCurve
        metadata.backupMethod = withMethod.rawValue
        let mpcMetadataString = try metadata.jsonString()

        let response = forCurve == .ED25519
          ? self.mobile.MobileBackupEd25519(self.apiKey, self.host, andSigningShare, self.apiHost, mpcMetadataString)
          : self.mobile.MobileBackupSecp256k1(self.apiKey, self.host, andSigningShare, self.apiHost, mpcMetadataString)

        // Parse the backup share.
        let jsonData = response.data(using: .utf8)!
        let rotateResult: RotateResult = try JSONDecoder().decode(RotateResult.self, from: jsonData)

        // Throw if there is an error getting the backup share.
        guard rotateResult.error.code == 0 else {
          continuation.resume(throwing: PortalMpcError(rotateResult.error))
          return
        }

        // Attach the backup share to the signing share JSON.
        let backupShare = rotateResult.data!.share

        continuation.resume(returning: backupShare)
      } catch {
        continuation.resume(throwing: error)
      }
    }

    return mpcShare
  }

  private func getSigningShare(_ forCurve: PortalCurve) async throws -> MpcShare {
    let mpcShare = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MpcShare, Error>) in
      do {
        // Stringify the MPC metadata.
        var metadata = self.mpcMetadata
        metadata.curve = forCurve

        let mpcMetadataString = try metadata.jsonString()
        let response = forCurve == .ED25519
          ? self.mobile.MobileGenerateEd25519(self.apiKey, self.host, self.apiHost, mpcMetadataString)
          : self.mobile.MobileGenerateSecp256k1(self.apiKey, self.host, self.apiHost, mpcMetadataString)

        // Parse the backup share.
        let jsonData = response.data(using: .utf8)!
        let rotateResult: RotateResult = try JSONDecoder().decode(RotateResult.self, from: jsonData)

        // Throw if there is an error getting the backup share.
        guard rotateResult.error.code == 0 else {
          self.logger.error("Error generating \(forCurve.rawValue) share: \(rotateResult.error.message)")
          continuation.resume(throwing: PortalMpcError(rotateResult.error))
          return
        }

        let signingShare = rotateResult.data!.share

        continuation.resume(returning: signingShare)
      } catch {
        self.logger.error("Error generating \(forCurve.rawValue) share: \(error.localizedDescription)")
        continuation.resume(throwing: error)
      }
    }

    return mpcShare
  }

  private func recoverSigningShare(_ forCurve: PortalCurve, withMethod _: BackupMethods, andBackupShare: String) async throws -> MpcShare {
    let mpcShare = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MpcShare, Error>) in
      do {
        // Stringify the MPC metadata.
        var metadata = self.mpcMetadata
        metadata.curve = forCurve
        let mpcMetadataString = try metadata.jsonString()

        let response = forCurve == .ED25519
          ? self.mobile.MobileRecoverSigningEd25519(self.apiKey, self.host, andBackupShare, self.apiHost, mpcMetadataString)
          : self.mobile.MobileRecoverSigningSecp256k1(self.apiKey, self.host, andBackupShare, self.apiHost, mpcMetadataString)

        // Parse the backup share.
        let jsonData = response.data(using: .utf8)!
        let rotateResult: RotateResult = try JSONDecoder().decode(RotateResult.self, from: jsonData)

        // Throw if there is an error getting the backup share.
        guard rotateResult.error.code == 0 else {
          continuation.resume(throwing: PortalMpcError(rotateResult.error))
          return
        }

        let signingShare = rotateResult.data!.share

        continuation.resume(returning: signingShare)
      } catch {
        continuation.resume(throwing: error)
      }
    }

    return mpcShare
  }

  /*******************************************
   * Deprecated functions
   *******************************************/

  /// Creates a backup share, encrypts it, and stores the private key in cloud storage.
  /// - Parameters:
  ///   - method: Either gdrive or icloud.
  ///   - completion: The callback which includes the cipherText of the backed up share.
  @available(*, deprecated, renamed: "backup", message: "Please use the async/await implementation of backup().")
  public func backup(
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    completion: @escaping (Result<String>) -> Void,
    progress: ((MpcStatus) -> Void)? = nil
  ) {
    Task {
      do {
        let backupMethod = BackupMethods(rawValue: method)!
        if backupMethod == .Password, let storage = backupOptions[backupMethod] as? PasswordStorage {
          storage.password = backupConfigs?.passwordStorage?.password
        }

        let response = try await backup(backupMethod, usingProgressCallback: progress)

        completion(Result(data: response.cipherText))
      } catch {
        completion(Result(error: error))
      }
    }
  }

  /// Generates a MPC wallet and signing share for a client.
  /// - Returns: The address of the newly created MPC wallet.
  @available(*, deprecated, renamed: "backup", message: "Please use the async/await implementation of generate().")
  public func generate(completion: @escaping (Result<String>) -> Void, progress: ((MpcStatus) -> Void)? = nil) {
    Task {
      do {
        _ = try await self.generate(withProgressCallback: progress)
        guard let address = try await keychain.getAddress("eip155:1") else {
          throw PortalKeychain.KeychainError.noAddressesFound
        }
        completion(Result(data: address))
      } catch {
        completion(Result(error: error))
      }
    }
  }

  /// Uses the org and client backup shares to return the private key
  ///  - Parameters:
  ///    - cipherText: the cipherText of the client's backup share
  ///    - method: The specific backup storage option.
  ///    - orgShare: the stringified version of the organization's backup share
  @available(*, deprecated, renamed: "ejectPrivateKey", message: "Please use the async/await implementation of ejectPrivateKey().")
  public func ejectPrivateKey(
    clientBackupCiphertext: String,
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    orgBackupShare: String,
    completion: @escaping (Result<String>) -> Void
  ) {
    Task {
      do {
        let backupMethod = BackupMethods(rawValue: method)!
        if backupMethod == .Password, let storage = backupOptions[backupMethod] as? PasswordStorage {
          storage.password = backupConfigs?.passwordStorage?.password
        }
        let address = try await eject(backupMethod, withCipherText: clientBackupCiphertext, andOrganizationBackupShare: orgBackupShare)

        completion(Result(data: address))
      } catch {
        completion(Result(error: error))
      }
    }
  }

  /// Uses the backup share to create a new signing share.
  /// - Parameters:
  ///   - cipherText: the cipherText of the backup share (should be passed in from the custodian).
  ///   - method: The specific backup storage option.
  ///   - completion: The callback which includes the wallet's address.
  @available(*, deprecated, renamed: "recover", message: "Please use the async/await implementation of recover().")
  public func recover(
    cipherText: String,
    method: BackupMethods.RawValue,
    backupConfigs: BackupConfigs? = nil,
    completion: @escaping (Result<String>) -> Void,
    progress: ((MpcStatus) -> Void)? = nil
  ) {
    Task {
      do {
        let backupMethod = BackupMethods(rawValue: method)!
        if backupMethod == .Password, let storage = backupOptions[backupMethod] as? PasswordStorage {
          storage.password = backupConfigs?.passwordStorage?.password
        }

        _ = try await self.recover(backupMethod, withCipherText: cipherText, usingProgressCallback: progress)

        guard let address = try await keychain.getAddress("eip155:1") else {
          throw PortalKeychain.KeychainError.noAddressesFound
        }
        completion(Result(data: address))
      } catch {
        completion(Result(error: error))
      }
    }
  }
}

public enum MpcStatuses: String {
  case decryptingShare = "Decrypting share"
  case done = "Done"
  case encryptingShare = "Encrypting share"
  case generatingShare = "Generating share"
  case parsingShare = "Parsing share"
  case readingShare = "Reading share"
  case recoveringBackupShare = "Recovering backup share"
  case recoveringSigningShare = "Recovering signing share"
  case storingShare = "Storing share"
}

/// A list of errors MPC can throw.
public enum MpcError: Error {
  case addressNotFound(_ message: String)
  case backupMethodNotRegistered(_ message: String)
  case backupNoLongerSupported(_ message: String)
  case failedToEncryptClientBackupShare(_ message: String)
  case failedToGetBackupFromStorage
  case failedToRecoverBackup(_ message: String)
  case failedToStoreClientBackupShareKey(_ message: String)
  case failedToValidateBackupMethod
  case generateNoLongerSupported(_ message: String)
  case noSigningSharePresent
  case recoverNoLongerSupported(_ message: String)
  case signingRecoveryError(_ message: String)
  case unableToAuthenticate
  case unableToDecodeShare
  case unableToEjectWallet(String)
  case unableToRetrieveClient(String)
  case unableToWriteToKeychain
  case unexpectedErrorOnBackup(_ message: String)
  case unexpectedErrorOnDecrypt(_ message: String)
  case unexpectedErrorOnEject(_ message: String)
  case unexpectedErrorOnEncrypt(_ message: String)
  case unexpectedErrorOnGenerate(_ message: String)
  case unexpectedErrorOnRecover(_ message: String)
  case unexpectedErrorOnSign(_ message: String)
  case unsupportedStorageMethod
  case unwrappingAddress
  case walletModificationAlreadyInProgress
}

/// A list of errors RSA can throw.
public enum RsaError: Error {
  case unableToCreatePrivateKey(message: String)
  case incompatibleKeyWithAlgorithm
  case dataIsTooLongForKey
  case unableToGetPublicKey
  case incorrectCipherTextFormat
}

public enum JSONParseError: Error {
  case stringToDataConversionFailed
  case jsonDecodingFailed
}

public enum ReadSigningSharePairIdError: Error {
  case noSigningSharePairIdFound
}
