// Objective-C API for talking to github.com/portal-hq/mpc/client Go package.
//   gobind -lang=objc github.com/portal-hq/mpc/client
//
// File is generated by gobind. Do not edit.

#ifndef __Client_H__
#define __Client_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class ClientDecryptData;
@class ClientDecryptResult;
@class ClientEncryptData;
@class ClientEncryptResult;
@class ClientGenerateData;
@class ClientGenerateResult;
@class ClientMessage;
@class ClientReshareData;
@class ClientReshareResult;
@class ClientShare;
@class ClientSignature;
@class ClientSigningRequest;
@class ClientSigningResult;

@interface ClientDecryptData : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull plaintext;
@end

@interface ClientDecryptResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field DecryptResult.Data with unsupported type: github.com/portal-hq/mpc/client.DecryptData

// skipped field DecryptResult.Error with unsupported type: *github.com/portal-hq/mpc/crypto/utils.PortalError

@end

@interface ClientEncryptData : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull key;
@property (nonatomic) NSString* _Nonnull cipherText;
@end

@interface ClientEncryptResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field EncryptResult.Data with unsupported type: github.com/portal-hq/mpc/client.EncryptData

// skipped field EncryptResult.Error with unsupported type: *github.com/portal-hq/mpc/crypto/utils.PortalError

@end

@interface ClientGenerateData : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field GenerateData.DkgResult with unsupported type: github.com/portal-hq/mpc/shared/cggmp/mpcHelpers.AuxInfo

@property (nonatomic) NSString* _Nonnull address;
@end

@interface ClientGenerateResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field GenerateResult.Data with unsupported type: github.com/portal-hq/mpc/client.GenerateData

// skipped field GenerateResult.Error with unsupported type: *github.com/portal-hq/mpc/crypto/utils.PortalError

@end

@interface ClientMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull message;
@end

@interface ClientReshareData : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field ReshareData.DkgResult with unsupported type: github.com/portal-hq/mpc/shared/cggmp/mpcHelpers.AuxInfo

@property (nonatomic) NSString* _Nonnull address;
@end

@interface ClientReshareResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field ReshareResult.Data with unsupported type: github.com/portal-hq/mpc/client.ReshareData

// skipped field ReshareResult.Error with unsupported type: *github.com/portal-hq/mpc/crypto/utils.PortalError

@end

@interface ClientShare : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull share;
@end

@interface ClientSignature : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull r;
@property (nonatomic) NSString* _Nonnull s;
@end

@interface ClientSigningRequest : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull hash;
@end

@interface ClientSigningResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull data;
// skipped field SigningResult.Error with unsupported type: *github.com/portal-hq/mpc/crypto/utils.PortalError

@end

FOUNDATION_EXPORT NSString* _Nonnull ClientBackup(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable version);

FOUNDATION_EXPORT NSString* _Nonnull ClientDecrypt(NSString* _Nullable key, NSString* _Nullable dkgCipherText);

FOUNDATION_EXPORT NSString* _Nonnull ClientEncrypt(NSString* _Nullable rawData);

FOUNDATION_EXPORT NSString* _Nonnull ClientGenerate(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable version);

FOUNDATION_EXPORT NSString* _Nonnull ClientRecoverBackup(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable version);

FOUNDATION_EXPORT NSString* _Nonnull ClientRecoverSigning(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable version);

FOUNDATION_EXPORT NSString* _Nonnull ClientSign(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable method, NSString* _Nullable params, NSString* _Nullable rpcURL, NSString* _Nullable chainId, NSString* _Nullable version);

#endif
