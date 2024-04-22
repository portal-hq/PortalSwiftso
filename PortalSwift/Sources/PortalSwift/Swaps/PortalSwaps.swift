//
//  PortalSwaps.swift
//  PortalSwift
//
//  Created by Blake Williams on 5/8/23.
//

import AnyCodable
import Foundation

public struct Quote: Codable {
  var allowanceTarget: String
  var cost: Double
  var transaction: ETHTransactionParam
}

public struct QuoteArgs: Codable {
  // Required
  var buyToken: String
  var sellToken: String

  // One of these two is required
  var sellAmount: Double?
  var buyAmount: Double?

  // Optional
  var affiliateAddress: String?
  var buyTokenPercentageFee: Double?
  var enableSlippageProtection: Bool?
  var excludedSources: String?
  var feeRecipient: String?
  var gasPrice: Double?
  var includedSources: String?
  var intentOnFilling: Bool?
  var priceImpactProtectionPercentage: Double?
  var skipValidation: Bool?
  var slippagePercentage: Double?
  var takerAddress: String?

  init(buyToken: String, sellToken: String, buyAmount: Double) {
    self.buyToken = buyToken
    self.sellToken = sellToken
    self.buyAmount = buyAmount
  }

  init(buyToken: String, sellToken: String, sellAmount: Double) {
    self.buyToken = buyToken
    self.sellToken = sellToken
    self.sellAmount = sellAmount
  }

  public func toDictionary() -> [String: AnyCodable] {
    var dictionary: [String: AnyCodable] = [
      // Always required
      "buyToken": AnyCodable(buyToken),
      "sellToken": AnyCodable(sellToken),
    ]

    // Either buyAmount or sellAmount MUST be set for the quote to return a usable value
    if self.buyAmount != nil {
      dictionary["buyAmount"] = AnyCodable(self.buyAmount)
    }

    if self.sellAmount != nil {
      dictionary["sellAmount"] = AnyCodable(self.sellAmount)
    }

    // The rest of these are truly optional
    if self.affiliateAddress != nil {
      dictionary["affiliateAddress"] = AnyCodable(self.affiliateAddress)
    }
    if self.buyTokenPercentageFee != nil {
      dictionary["buyTokenPercentageFee"] = AnyCodable(self.buyTokenPercentageFee)
    }
    if self.enableSlippageProtection != nil {
      dictionary["enableSlippageProtection"] = AnyCodable(self.enableSlippageProtection)
    }
    if self.excludedSources != nil {
      dictionary["excludedSources"] = AnyCodable(self.excludedSources)
    }
    if self.feeRecipient != nil {
      dictionary["feeRecipient"] = AnyCodable(self.feeRecipient)
    }
    if self.gasPrice != nil {
      dictionary["gasPrice"] = AnyCodable(self.gasPrice)
    }
    if self.includedSources != nil {
      dictionary["includedSources"] = AnyCodable(self.includedSources)
    }
    if self.intentOnFilling != nil {
      dictionary["intentOnFilling"] = AnyCodable(self.intentOnFilling)
    }
    if self.priceImpactProtectionPercentage != nil {
      dictionary["priceImpactProtectionPercentage"] = AnyCodable(self.priceImpactProtectionPercentage)
    }
    if self.skipValidation != nil {
      dictionary["skipValidation"] = AnyCodable(self.skipValidation)
    }
    if self.slippagePercentage != nil {
      dictionary["slippagePercentage"] = AnyCodable(self.slippagePercentage)
    }
    if self.takerAddress != nil {
      dictionary["takerAddress"] = AnyCodable(self.takerAddress)
    }

    return dictionary
  }
}

public class PortalSwaps {
  private var apiKey: String
  private var portal: Portal

  init(apiKey: String, portal: Portal) {
    self.apiKey = apiKey
    self.portal = portal
  }

  public func getQuote(args: QuoteArgs, completion: @escaping (Result<Quote>) -> Void) {
    do {
      try self.portal.api.getQuote(self.apiKey, args) { result in
        completion(result)
      }
    } catch {
      completion(Result(error: error))
    }
  }

  public func getSources(completion: @escaping (Result<[String: String]>) -> Void) {
    do {
      try self.portal.api.getSources(swapsApiKey: self.apiKey) { result in
        completion(result)
      }
    } catch {
      completion(Result(error: error))
    }
  }
}
