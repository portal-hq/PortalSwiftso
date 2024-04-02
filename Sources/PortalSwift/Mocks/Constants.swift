//
//  Constants.swift
//  PortalSwift
//
//  Created by Portal Labs, Inc.
//  Copyright © 2022 Portal Labs, Inc. All rights reserved.
//

import Foundation
import GoogleSignIn

enum MockConstantsError: Error {
  case unableToEncodeMockValue
}

public enum MockConstants {
  public static let backupProgressCallbacks: Set<MpcStatuses> = [
    .readingShare,
    .generatingShare,
    .parsingShare,
    .encryptingShare,
    .storingShare,
    .done,
  ]
  public static let generateProgressCallbacks: Set<MpcStatuses> = [
    .generatingShare,
    .parsingShare,
    .storingShare,
    .done,
  ]
  public static let recoverProgressCallbacks: Set<MpcStatuses> = [
    .readingShare,
    .decryptingShare,
    .parsingShare,
    .generatingShare,
    .parsingShare,
    .storingShare,
    .done,
  ]

  public static let mockApiKey = "test-api-key"
  public static let mockBackupPath = "test-backup-path"
  public static let mockCiphertext = "test-cipher-text"
  public static let mockClientId = "test-client-id"
  public static let mockCloudBackupPath = "test-cloud-backup-path"
  public static let mockCreatedAt = "test-created-at"
  public static let mockCustodian = ClientResponseCustodian(
    id: "test-custodian-id",
    name: "test-custodian-name"
  )
  public static let mockDecryptResult = "{\"data\":{\"plaintext\":\"\(mockDecryptedShare)\"},\"error\":{\"code\":0,\"message\":\"\"}}"
  public static let mockDecryptedShare = "test-decrypted-share"
  public static let mockED25519KeychainWallet = PortalKeychainClientMetadataWallet(
    id: mockMpcShareId,
    curve: .ED25519,
    publicKey: mockPublicKey,
    backupShares: [mockKeychainBackupShare],
    signingShares: [mockKeychainShare]
  )
  public static let mockED25519Wallet = ClientResponseWallet(
    id: mockWalletId,
    createdAt: mockCreatedAt,
    backupSharePairs: [mockWalletBackupShare],
    curve: .ED25519,
    publicKey: mockPublicKey,
    signingSharePairs: [mockWalletSigningShare]
  )
  public static let mockEip155Address = "0x73574d235573574d235573574d235573574d2355"
  public static let mockEip155EjectResponse = "{\"privateKey\":\"\(mockEip155EjectedPrivateKey)\",\"error\":{\"code\":0,\"message\":\"\"}}"
  public static let mockEip155EjectedPrivateKey = "099cabf8c65c81e629d59e72f04a549aafa531329e25685a5b8762b926597209"
  public static let mockEip155Transaction = [
    "from": mockEip155Address,
    "to": "0xd46e8dd67c5d32be8058bb8eb970870f07244567",
    "value": "0x9184e72a",
    "data": "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675",
  ]
  public static let mockEjectResponse = "test-eject-response"
  public static let mockEncryptData = EncryptData(key: mockEncryptionKey, cipherText: mockCiphertext)
  public static let mockEncryptResult = "{\"data\":{\"key\":\"\(mockEncryptionKey)\",\"cipherText\":\"\(mockCiphertext)\"},\"error\":{\"code\":0,\"message\":\"\"}}"

  public static let mockEncryptWithPasswordResult = "{\"data\":{\"cipherText\":\"\(mockCiphertext)\"},\"error\":{\"code\":0,\"message\":\"\"}}"
  public static let mockEncryptionKey = "test-encryption-key"
  public static let mockedFetchedBalance = FetchedBalance(contractAddress: mockEip155Address, balance: "test-balance")
  public static let mockFetchedNFT = FetchedNFT(
    contract: FetchedNFTContract(address: mockEip155Address),
    id: FetchedNFTTokenId(tokenId: "test-token-id", tokenMetadata: FetchedNFTTokenMetadata(tokenType: "test-token-type")),
    balance: "test-nft-balance",
    title: "test-nft-title",
    description: "test-nft-description",
    tokenUri: FetchedNFTTokenUri(gateway: "test-nft-gateway", raw: "test-nft-token-uri-raw"),
    media: [FetchedNFTMedia(
      gateway: "test-nft-gateway",
      thumbnail: "test-nft-thumbnail",
      raw: "test-nft-media-raw",
      format: "test-nft-formal",
      bytes: 0
    )],
    metadata: FetchedNFTMetadata(
      name: "test-nft-name",
      description: "test-nft-description",
      image: "test-nft-image",
      external_url: "test-nft-external-url"
    ),
    timeLastUpdated: "test-nft-last-updated",
    contractMetadata: FetchedNFTContractMetadata(
      name: "test-nft-contract-name",
      symbol: "test-nft-symbol",
      tokenType: "test-nft-token-type",
      contractDeployer: "test-nft-contract-deployer",
      deployedBlockNumber: 0
    )
  )
  public static let mockFetchedShairPair = FetchedSharePair(
    id: mockMpcShareId,
    createdAt: mockCreatedAt,
    status: .completed
  )
  public static let mockFetchedTransaction = FetchedTransaction(
    blockNum: "test-block-number",
    uniqueId: "test-unique-id",
    hash: mockTransactionHash,
    from: mockEip155Address,
    to: mockEip155Address,
    value: 0.1,
    asset: "test-transaction-asset",
    category: "test-transaction-category",
    rawContract: FetchedTransactionRawContract(value: "test-value", address: mockEip155Address, decimal: "test-decimal"),
    metadata: FetchedTransaction.FetchedTransactionMetadata(blockTimestamp: "test-block-timestamp"),
    chainId: 11_155_111
  )
  public static let mockGDriveClientId = "test-mock-gdrive-client-id"
  public static let mockGDriveFile = GDriveFile(
    kind: "test-gdrive-file-kind",
    id: mockGDriveFileId,
    name: mockGDriveFileName,
    mimeType: "test-gdrive-mime-type"
  )
  public static let mockGDriveFileContents = "test-gdrive-private-key"
  public static let mockGDriveFileId = "test-gdrive-file-id"
  public static let mockGDriveFileName = "test-gdrive-file-name"
  public static let mockGDriveFolderId = "test-gdrive-folder-id"
  public static let mockGoogleAccessToken = "test-google-access-token"
  public static let mockGoogleUserId = "test-google-user-id"
  public static let mockHost = "example.com"
  public static let mockICloudHash = ICloudStorage.hash("\(mockClient.custodian.id)\(mockClient.id)")
  public static let mockKeychainBackupShare = PortalKeychainClientMetadataWalletBackupShare(
    backupMethod: .Password,
    createdAt: mockCreatedAt,
    id: mockMpcShareId,
    status: .completed
  )
  public static let mockKeychainClientMetadata = PortalKeychainClientMetadata(
    id: MockConstants.mockClientId,
    addresses: [
      .eip155: mockEip155Address,
      .solana: mockSolanaAddress,
    ],
    custodian: mockCustodian,
    wallets: [
      .ED25519: mockED25519KeychainWallet,
      .SECP256K1: mockED25519KeychainWallet,
    ]
  )
  public static let mockKeychainShare = PortalKeychainClientMetadataWalletShare(
    createdAt: mockCreatedAt,
    id: mockMpcShareId,
    status: .completed
  )
  public static let mockMetricsResponse = MetricsResponse(status: true)
  public static let mockMpcShare = MpcShare(
    allY: mockMpcSharePartialPublicKey,
    backupSharePairId: mockMpcShareId,
    bks: mockMpcShareBks,
    clientId: mockClientId,
    p: mockMpcShareP,
    pederson: mockMpcSharePederssens,
    pubkey: mockMpcSharePublicKey,
    q: mockMpcShareQ,
    share: mockMpcShareShare,
    signingSharePairId: mockMpcShareId,
    ssid: mocMpcShareSsid
  )
  public static let mockMpcShareBerkhoff = Berkhoff(X: "test-berkhoff-x", Rank: 0)
  public static let mockMpcShareBks = Berkhoffs(
    client: mockMpcShareBerkhoff,
    server: mockMpcShareBerkhoff
  )
  public static let mockMpcShareId = "test-share-id"
  public static let mockMpcSharePartialPublicKey = PartialPublicKey(
    client: mockMpcSharePublicKey,
    server: mockMpcSharePublicKey
  )
  public static let mockMpcSharePederssen = Pederssen(n: "mock-pederssen-n", s: "mock-pederssen-s", t: "mock-pederssen-t")
  public static let mockMpcSharePederssens = Pederssens(
    client: mockMpcSharePederssen,
    server: mockMpcSharePederssen
  )
  public static let mockMpcSharePublicKey = PublicKey(X: "test-public-key-x", Y: "test-public-key-y")
  public static let mockMpcShareShare = "test-mpc-share-share"
  public static let mocMpcShareSsid = "test-mpc-share-ssid"
  public static let mockMpcShareP = "test-mpc-share-p"
  public static let mockMpcShareQ = "test-mpc-share-q"
  public static let mockPasskeyAssertion = "test-passkey-assertion"
  public static let mockPasskeyAttestation = "test-passkey-attestation"
  public static let mockPasskeyAuthenticationOptions = WebAuthnAuthenticationOption(
    options: AuthenticationOptions(
      publicKey: AuthenticationOptions.PublicKey(
        challenge: "test-authentication-challenge",
        timeout: 999_999,
        rpId: "test-relying-party-id",
        allowCredentials: [AuthenticationOptions.Credential(
          type: "test-authentication-credential-type",
          id: "test-authentication-credential-id"
        )],
        userVerification: "test-user-verification"
      )
    ),
    sessionId: "test-session-id"
  )
  public static let mockPasskeyReadResponse = PasskeyLoginReadResponse(encryptionKey: mockEncryptionKey)
  public static let mockPasskeyRegistrationOptions = WebAuthnRegistrationOptions(
    options: RegistrationOptions(
      publicKey: PublicKeyOptions(
        rp: RelyingParty(name: "test-relying-party-name", id: "test-relying-party-id"),
        user: User(name: "test-user-name", displayName: "test-user-display-name", id: "test-user-id"),
        challenge: "test-registration-challenge",
        pubKeyCredParams: [CredentialParameter(type: "test-credential-parameter", alg: 99)],
        timeout: 999_999,
        authenticatorSelection: nil,
        attestation: mockPasskeyAttestation
      )
    ),
    sessionId: "test-session-id"
  )
  public static let mockPasskeyStatus = PasskeyStatusResponse(status: .RegisteredWithCredential)
  public static let mockProviderRequestId = "test-provider-request-id"
  public static let mockPublicKey = "{\"X\":\"test-public-key-x\",\"Y\":\"test-public-key-y\"}"
  public static let mockRpcResponse = PortalProviderRpcResponse(jsonrpc: "2.0", id: 0, result: "test")
  public static let mockSECP256K1KeychainWallet = PortalKeychainClientMetadataWallet(
    id: mockMpcShareId,
    curve: .SECP256K1,
    publicKey: mockPublicKey,
    backupShares: [mockKeychainBackupShare],
    signingShares: [mockKeychainShare]
  )
  public static let mockSECP256K1Wallet = ClientResponseWallet(
    id: mockWalletId,
    createdAt: mockCreatedAt,
    backupSharePairs: [mockWalletBackupShare],
    curve: .SECP256K1,
    publicKey: mockPublicKey,
    signingSharePairs: [mockWalletSigningShare]
  )
  public static let mockSignResult = "{\"data\":\"\(mockSignature)\",\"error\":{\"code\":0,\"message\":\"\"}}"
  public static let mockSignResultWithError = "{\"data\":\"\",\"error\":{\"code\":108,\"message\":\"This error is thrown if there is an issue completing the signing process.\"}}"
  public static let mockSignTypedDataMessage =
    "{\"types\":{\"PermitSingle\":[{\"name\":\"details\",\"type\":\"PermitDetails\"},{\"name\":\"spender\",\"type\":\"address\"},{\"name\":\"sigDeadline\",\"type\":\"uint256\"}],\"PermitDetails\":[{\"name\":\"token\",\"type\":\"address\"},{\"name\":\"amount\",\"type\":\"uint160\"},{\"name\":\"expiration\",\"type\":\"uint48\"},{\"name\":\"nonce\",\"type\":\"uint48\"}],\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}]},\"domain\":{\"name\":\"Permit2\",\"chainId\":\"5\",\"verifyingContract\":\"0x000000000022d473030f116ddee9f6b43ac78ba3\"},\"primaryType\":\"PermitSingle\",\"message\":{\"details\":{\"token\":\"0x1f9840a85d5af5bf1d1762f925bdaddc4201f984\",\"amount\":\"1461501637330902918203684832716283019655932542975\",\"expiration\":\"1685053478\",\"nonce\":\"0\"},\"spender\":\"0x4648a43b2c14da09fdf82b161150d3f634f40491\",\"sigDeadline\":\"1682463278\"}}"
  public static let mockSignature = "54cdc8c44437159f524268bdf257d88743eb550def55171f9418c5abd9a994467aa000b3213e6cc1ae950b31631450faffbac7319c7ec096898314d1f289646900"
  public static let mockSignatureResponse = "{\"data\":\"\(mockSignature)\",\"error\":{\"code\":0,\"message\":\"\"}}"
  public static let mockSimulatedTransaction = SimulatedTransaction(
    changes: []
  )
  public static let mockSolanaAddress = "6LmSRCiu3z6NCSpF19oz1pHXkYkN4jWbj9K1nVELpDkT"
  public static let mockTransactionHash = "0x926c5168c5646425d5dcf8e3dac7359ddb77e9ff95884393a6a9a8e3de066fc1"
  public static let mockTransactionHashResponse = "{\"data\":\"\(mockTransactionHash)\",\"error\":{\"code\":0,\"message\":\"\"}}"
  public static let mockWalletBackupShare = ClientResponseBackupSharePair(
    backupMethod: .Password,
    createdAt: mockCreatedAt,
    id: mockMpcShareId,
    status: .completed
  )
  public static let mockWalletId = "test-wallet-id"
  public static let mockWalletSigningShare = ClientResponseSharePair(
    id: mockMpcShareId,
    createdAt: mockCreatedAt,
    status: .completed
  )

  // Dynamically generated constants
  public static var mockClient: ClientResponse {
    return ClientResponse(
      id: mockClientId,
      custodian: mockCustodian,
      createdAt: mockCreatedAt,
      environment: ClientResponseEnvironment(
        id: "test-environment-id",
        name: "test-environment-name"
      ),
      ejectedAt: "test-ejected-at",
      isAccountAbstracted: false,
      metadata: ClientResponseMetadata(
        namespaces: ClientResponseMetadataNamespaces(
          eip155: ClientResponseNamespaceMetadataItem(
            address: mockEip155Address,
            curve: .SECP256K1
          ),
          solana: nil
        )
      ),
      wallets: [
        mockED25519Wallet,
        mockSECP256K1Wallet,
      ]
    )
  }

  public static var mockClientResponseString: String {
    get async throws {
      let mockClient = mockClient
      let mockClientData = try JSONEncoder().encode(mockClient)
      guard let mockClientResponseString = String(data: mockClientData, encoding: .utf8) else {
        throw MockConstantsError.unableToEncodeMockValue
      }

      return mockClientResponseString
    }
  }

  public static var mockGeneratedShare: PortalMpcGeneratedShare {
    get throws {
      let mockMpcShareData = try JSONEncoder().encode(mockMpcShare)
      guard let mockMpcShareString = String(data: mockMpcShareData, encoding: .utf8) else {
        throw MockConstantsError.unableToEncodeMockValue
      }

      return PortalMpcGeneratedShare(
        id: mockMpcShareId,
        share: mockMpcShareString
      )
    }
  }

  public static var mockGenerateResponse: PortalMpcGenerateResponse {
    get throws {
      let mockGeneratedShare = try mockGeneratedShare

      let mockGenerateResponse: PortalMpcGenerateResponse = [
        "ED25519": mockGeneratedShare,
        "SECP256K1": mockGeneratedShare,
      ]

      return mockGenerateResponse
    }
  }

  public static var mockRotateResult: String {
    get throws {
      let rotateResult = RotateResult(
        data: RotateData(share: mockMpcShare),
        error: PortalError(code: 0, message: "")
      )
      let rotateResultData = try JSONEncoder().encode(rotateResult)
      guard let result = String(data: rotateResultData, encoding: .utf8) else {
        throw MockConstantsError.unableToEncodeMockValue
      }

      return result
    }
  }

  public static var mockCreateWalletResponse: PortalCreateWalletResponse {
    let mockCreateWalletResponse: PortalCreateWalletResponse = (
      ethereum: mockEip155Address,
      solana: mockSolanaAddress
    )

    return mockCreateWalletResponse
  }

  public static var mockMpcShareString: String {
    get throws {
      let mockMpcShareData = try JSONEncoder().encode(mockMpcShare)
      guard let mockMpcShareString = String(data: mockMpcShareData, encoding: .utf8) else {
        throw MockConstantsError.unableToEncodeMockValue
      }

      return mockMpcShareString
    }
  }
}
