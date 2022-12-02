// Objective-C API for talking to github.com/portal-hq/mpc/client Go package.
//   gobind -lang=objc github.com/portal-hq/mpc/client
//
// File is generated by gobind. Do not edit.

#ifndef __Client_H__
#define __Client_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class ClientGenerateData;
@class ClientGenerateResult;
@class ClientMessage;
@class ClientReshareResult;
@class ClientShare;
@class ClientSignature;
@class ClientSigningRequest;
@class ClientSigningResult;

@interface ClientGenerateData : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field GenerateData.DkgResult with unsupported type: github.com/portal-hq/mpc/shared/dkg.DkgResult

@property (nonatomic) NSString* _Nonnull address;
@end

@interface ClientGenerateResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field GenerateResult.Data with unsupported type: github.com/portal-hq/mpc/client.GenerateData

@property (nonatomic) NSString* _Nonnull error;
@end

@interface ClientMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull message;
@end

@interface ClientReshareResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field ReshareResult.Data with unsupported type: github.com/portal-hq/mpc/client.Share

@property (nonatomic) NSString* _Nonnull error;
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
@property (nonatomic) NSString* _Nonnull error;
@end

FOUNDATION_EXPORT NSString* _Nonnull ClientBackup(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult);

FOUNDATION_EXPORT NSString* _Nonnull ClientGenerate(NSString* _Nullable clientAPIKey, NSString* _Nullable addr);

FOUNDATION_EXPORT NSString* _Nonnull ClientRecoverBackup(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult);

FOUNDATION_EXPORT NSString* _Nonnull ClientRecoverSigning(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult);

FOUNDATION_EXPORT NSString* _Nonnull ClientSign(NSString* _Nullable clientAPIKey, NSString* _Nullable addr, NSString* _Nullable dkgResult, NSString* _Nullable method, NSString* _Nullable params, NSString* _Nullable rpcURL, NSString* _Nullable chainId);

#endif
