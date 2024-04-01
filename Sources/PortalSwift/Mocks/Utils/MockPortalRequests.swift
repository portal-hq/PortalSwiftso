//
//  File.swift
//
//
//  Created by Blake Williams on 3/30/24.
//

import Foundation

public enum MockPortalRequests {
  private static let encoder = JSONEncoder()

  public static func delete(_ url: URL, withBearerToken _: String? = nil) async throws -> Data {
    switch url.path {
    default:
      guard let mockNullData = "null".data(using: .utf8) else {
        throw PortalRequestsError.couldNotParseHttpResponse
      }
      return mockNullData
    }
  }

  public static func get(_ url: URL, withBearerToken _: String? = nil) async throws -> Data {
    switch url.path {
    case "/api/v3/clients/me":
      let mockClientData = try encoder.encode(MockConstants.mockClient)
      return mockClientData
    case "/api/v3/clients/me/balances":
      let mockBalancesData = try encoder.encode([MockConstants.mockedFetchedBalance])
      return mockBalancesData
    case "/api/v3/clients/me/nfts":
      let mockNFTData = try encoder.encode([MockConstants.mockFetchedNFT])
      return mockNFTData
    case "/api/v3/clients/me/transactions":
      let mockTransactionData = try encoder.encode([MockConstants.mockFetchedTransaction])
      return mockTransactionData
    case "/api/v3/clients/me/wallets/\(MockConstants.mockWalletId)/backup-share-pairs", "/api/v3/clients/me/wallets/\(MockConstants.mockWalletId)/signing-share-pairs":
      let mockSigningSharePairsData = try encoder.encode([MockConstants.mockFetchedShairPair])
      return mockSigningSharePairsData
    case "/drive/v3/files":
      let mockFilesListResponse = GDriveFilesListResponse(
        kind: "test-gdrive-file-kind",
        incompleteSearch: false,
        files: [MockConstants.mockGDriveFile]
      )
      let filesData = try encoder.encode(mockFilesListResponse)
      return filesData
    case "/drive/v3/files/\(MockConstants.mockGDriveFileId)":
      guard let contentsData = MockConstants.mockEncryptionKey.data(using: .utf8) else {
        throw PortalRequestsError.couldNotParseHttpResponse
      }
      return contentsData
    case "/passkeys/status":
      let statusData = try encoder.encode(MockConstants.mockPasskeyStatus)
      return statusData
    default:
      guard let mockNullData = "null".data(using: .utf8) else {
        throw PortalRequestsError.couldNotParseHttpResponse
      }
      return mockNullData
    }
  }

  public static func patch(_ url: URL, withBearerToken _: String? = nil, andPayload _: Encodable) async throws -> Data {
    switch url.path {
    case "/api/v3/clients/me/backup-share-pairs/", "/api/v3/clients/me/signing-share-pairs/":
      guard let mockTrueData = "true".data(using: .utf8) else {
        throw PortalRequestsError.couldNotParseHttpResponse
      }
      return mockTrueData
    default:
      guard let mockNullData = "null".data(using: .utf8) else {
        throw PortalRequestsError.couldNotParseHttpResponse
      }
      return mockNullData
    }
  }

  public static func post(_ url: URL, withBearerToken _: String? = nil, andPayload _: Encodable? = nil) async throws -> Data {
    switch url.path {
    case "/api/v1/analytics/identify", "/api/v1/analytics/track":
      let mockMetricsResponseData = try encoder.encode(MockConstants.mockMetricsResponse)
      return mockMetricsResponseData
    case "/api/v3/clients/me/eject":
      let mockEjectData = try encoder.encode(MockConstants.mockEjectResponse)
      return mockEjectData
    case "/api/v3/clients/me/simulate-transaction":
      let mockSimulateTransactionData = try encoder.encode(MockConstants.mockSimulatedTransaction)
      return mockSimulateTransactionData
    case "/drive/v3/files":
      let mockFilesListResponse = GDriveFilesListResponse(
        kind: "test-gdrive-file-kind",
        incompleteSearch: false,
        files: [MockConstants.mockGDriveFile]
      )
      let filesData = try encoder.encode(mockFilesListResponse)
      return filesData
    case "/passkeys/begin-login":
      let mockAuthenticationData = try encoder.encode(MockConstants.mockPasskeyAuthenticationOptions)
      return mockAuthenticationData
    case "/passkeys/begin-registration":
      let mockRegistrationData = try encoder.encode(MockConstants.mockPasskeyRegistrationOptions)
      return mockRegistrationData
    case "/passkeys/finish-login/read":
      let mockReadData = try encoder.encode(MockConstants.mockPasskeyReadResponse)
      return mockReadData
    default:
      guard let mockNullData = "null".data(using: .utf8) else {
        throw PortalRequestsError.couldNotParseHttpResponse
      }
      return mockNullData
    }
  }

  public static func postMultiPartData(
    _: URL,
    withBearerToken _: String,
    andPayload _: String,
    usingBoundary _: String
  ) async throws -> Data {
    let gDriveFileData = try JSONEncoder().encode(MockConstants.mockGDriveFile)
    return gDriveFileData
  }
}
