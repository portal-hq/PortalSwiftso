//
//  MockMpcMobile.swift
//  PortalSwift
//
//  Created by Rami Shahatit on 8/2/23.
//

import Foundation

enum MockMobileWrapperError: Error {
  case unableToEncodeData
}

class MockMobileWrapper: Mobile {
  func MobileGenerateEd25519(_: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileGenerateSecp256k1(_: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileBackupEd25519(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileBackupSecp256k1(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileRecoverSigningEd25519(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileRecoverSigningSecp256k1(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileGenerate(_: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileBackup(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileRecoverSigning(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileRecoverBackup(_: String, _: String, _: String, _: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      do {
        try continuation.resume(returning: MockConstants.mockRotateResult)
      } catch {
        continuation.resume(returning: "")
      }
    }
    return result
  }

  func MobileEncryptWithPassword(data _: String, password _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      continuation.resume(returning: MockConstants.mockEncryptWithPasswordResult)
    }
    return result
  }

  func MobileDecryptWithPassword(_: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      continuation.resume(returning: MockConstants.mockDecryptResult)
    }
    return result
  }

  func MobileDecrypt(_: String, _: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      continuation.resume(returning: MockConstants.mockDecryptResult)
    }
    return result
  }

  func MobileEncrypt(_: String) async -> String {
    let result = await withCheckedContinuation { continuation in
      continuation.resume(returning: MockConstants.mockEncryptResult)
    }
    return result
  }

  func MobileGetMe(_: String, _: String) -> String {
    do {
      let clientResponse = MockConstants.mockClient
      let clientResponseData = try JSONEncoder().encode(clientResponse)
      guard let clientResponseString = String(data: clientResponseData, encoding: .utf8) else {
        throw MockMobileWrapperError.unableToEncodeData
      }

      return clientResponseString
    } catch {
      return ""
    }
  }

  func MobileGetVersion() -> String {
    return "4.0.1"
  }

  func MobileSign(_: String?, _: String?, _: String?, _ method: String?, _: String?, _: String?, _: String?, _: String?) -> String {
    if method == PortalRequestMethod.eth_sendTransaction.rawValue {
      return MockConstants.mockTransactionHashResponse
    }
    return MockConstants.mockSignatureResponse
  }

  func MobileEjectWalletAndDiscontinueMPC(_: String, _: String) -> String {
    return MockConstants.mockEip155EjectResponse
  }
}
