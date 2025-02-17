#import "TruvideoReactTurboVideoSdk.h"

@implementation TruvideoReactTurboVideoSdk
RCT_EXPORT_MODULE()

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
}

- (void)cleanNoise:(nonnull NSString *)videoPath resultPath:(nonnull NSString *)resultPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo cleanNoise:videoPath resultPath:resultPath resolve:resolve reject:reject];
}


- (void)compareVideos:(nonnull NSArray *)videoUris resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo compareVideos:videoUris resolve:resolve reject:reject];
}


- (void)concatVideos:(nonnull NSArray *)videoUris resultPath:(nonnull NSString *)resultPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo concatVideos:videoUris resultPath:resultPath resolve:resolve reject:reject];
}


- (void)editVideo:(nonnull NSString *)videoUri resultPath:(nonnull NSString *)resultPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo editVideo:videoUri resultPath:resultPath resolve:resolve reject:reject];
}


- (void)encodeVideo:(nonnull NSString *)videoUri resultPath:(nonnull NSString *)resultPath config:(nonnull NSString *)config resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo encodeVideo:videoUri resultPath:resultPath config:config resolve:resolve reject:reject];
}


- (void)generateThumbnail:(nonnull NSString *)videoPath resultPath:(nonnull NSString *)resultPath position:(nonnull NSString *)position width:(nonnull NSString *)width height:(nonnull NSString *)height resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo generateThumbnail:videoPath resultPath:resultPath position:position width:width height:height resolve:resolve reject:reject];
}


- (void)getResultPath:(nonnull NSString *)path resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo getResultPath:path resolve:resolve reject:reject];
}


- (void)getVideoInfo:(nonnull NSString *)videoPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo getVideoInfo:videoPath resolve:resolve reject:reject];
}


- (void)mergeVideos:(nonnull NSArray *)videoUris resultPath:(nonnull NSString *)resultPath config:(nonnull NSString *)config resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruvideoReactTurboVideoSdk *truvideo = [[TruvideoReactTurboVideoSdk alloc] init];
  [truvideo mergeVideos:videoUris resultPath:resultPath config:config resolve:resolve reject:reject];
}


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTruvideoReactTurboVideoSdkSpecJSI>(params);
}

@end
