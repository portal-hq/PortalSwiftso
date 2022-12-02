//
//  MPCSigner.swift
//
//  Created by Portal Labs, Inc.
//  Copyright © 2022 Portal Labs, Inc. All rights reserved.
//

import Foundation
import Mpc

struct Signature: Codable {
  var x: String
  var y: String
}

struct SignerResult: Codable {
  var signature: String?
  var accounts: [String]?
}

class MpcSigner {
  public var address: String?
  public var keychain: PortalKeychain

  private var mpcUrl: String

  init (
    keychain: PortalKeychain,
    mpcUrl: String = "mpc.portalhq.io"
  ) {
    self.keychain = keychain
    self.mpcUrl = mpcUrl
  }

  public func sign(
    payload: ETHRequestPayload,
    provider: PortalProvider
  ) throws -> Any {
    let address = try keychain.getAddress()

    switch (payload.method) {
    case ETHRequestMethods.RequestAccounts.rawValue:
      return SignerResult(accounts: [address])
    case ETHRequestMethods.Accounts.rawValue:
      return SignerResult(accounts: [address])
    default :
      let signingShare = try keychain.getSigningShare()
      let formattedParams = try formatParams(payload: payload)
      print("What are the params:", formattedParams)
      let clientSignResult = ClientSign(
        provider.getApiKey(),
        mpcUrl,
        signingShare,
        payload.method,
        formattedParams,
        provider.gatewayUrl,
        String(provider.chainId)
      )

      let jsonData = clientSignResult.data(using: .utf8)!
      let signResult: SignResult = try JSONDecoder().decode(SignResult.self, from: jsonData)
      guard signResult.error == "" else {
        throw MpcError.unexpectedErrorOnSign(message: signResult.error!)
      }

      return SignerResult(signature: signResult.data!)
    }
  }

  public func sign(
    payload: ETHTransactionPayload,
    provider: PortalProvider
  ) throws -> SignerResult {
    let signingShare = try keychain.getSigningShare()
    let formattedParams = try formatParams(payload: payload)
    let clientSignResult = ClientSign(
      provider.getApiKey(),
      mpcUrl,
      signingShare,
      payload.method,
      formattedParams,
      provider.gatewayUrl,
      String(provider.chainId)
    )

    let jsonData = clientSignResult.data(using: .utf8)!
    let signResult: SignResult = try JSONDecoder().decode(SignResult.self, from: jsonData)
    guard signResult.error == "" else {
      throw MpcError.unexpectedErrorOnSign(message: signResult.error!)
    }

    return SignerResult(signature: signResult.data!)
  }

  private func formatParams(payload: ETHRequestPayload) throws -> String {
    var json: Data

    if payload.params.count == 0 {
      return ""
    } else {
      json = try JSONSerialization.data(withJSONObject: payload.params, options: .prettyPrinted)
    }

    return String(data: json, encoding: .utf8)!
  }

  private func formatParams(payload: ETHTransactionPayload) throws -> String {
    var json: Data

    if payload.params.count == 0 {
      return ""
    } else {
      let formattedPayload = payload.params.first!
      json = try JSONEncoder().encode(formattedPayload)
    }

    return String(data: json, encoding: .utf8)!
  }
}
