// Objective-C API for talking to github.com/portal-hq/mpc/client/mobile Go package.
//   gobind -lang=objc github.com/portal-hq/mpc/client/mobile
//
// File is generated by gobind. Do not edit.

#ifndef __Mobile_H__
#define __Mobile_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class MobileCustodian;
@class MobileGetMeErrorType;
@class MobileGetMeResponse;
@class MobileGetMeResult;

@interface MobileCustodian : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull id_;
@property (nonatomic) NSString* _Nonnull name;
@end

@interface MobileGetMeErrorType : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field GetMeErrorType.Code with unsupported type: uint16

@property (nonatomic) NSString* _Nonnull message;
@end

@interface MobileGetMeResponse : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull id_;
@property (nonatomic) NSString* _Nonnull address;
@property (nonatomic) NSString* _Nonnull clientAPIKey;
// skipped field GetMeResponse.Custodian with unsupported type: github.com/portal-hq/mpc/client/mobile.Custodian

@property (nonatomic) NSString* _Nonnull signingStatus;
@end

@interface MobileGetMeResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field GetMeResult.Data with unsupported type: github.com/portal-hq/mpc/client/mobile.GetMeResponse

// skipped field GetMeResult.Error with unsupported type: github.com/portal-hq/mpc/client/mobile.GetMeErrorType

@end

FOUNDATION_EXPORT NSString* _Nonnull MobileBackup(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable apiAddr, NSString* _Nullable metadataStr);

FOUNDATION_EXPORT NSString* _Nonnull MobileDecrypt(NSString* _Nullable key, NSString* _Nullable dkgCipherText);

FOUNDATION_EXPORT NSString* _Nonnull MobileEncrypt(NSString* _Nullable value);

FOUNDATION_EXPORT NSString* _Nonnull MobileGenerate(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable apiAddr, NSString* _Nullable metadataStr);

FOUNDATION_EXPORT NSString* _Nonnull MobileGetMe(NSString* _Nullable url, NSString* _Nullable token);

FOUNDATION_EXPORT NSString* _Nonnull MobileGetVersion(void);

FOUNDATION_EXPORT NSString* _Nonnull MobileRecoverBackup(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable apiAddr, NSString* _Nullable metadataStr);

FOUNDATION_EXPORT NSString* _Nonnull MobileRecoverSigning(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable apiAddr, NSString* _Nullable metadataStr);

FOUNDATION_EXPORT NSString* _Nonnull MobileSign(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable method, NSString* _Nullable params, NSString* _Nullable rpcURL, NSString* _Nullable chainId, NSString* _Nullable metadataStr);

#endif
