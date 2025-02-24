#import "TruvideoReactTurboVideoSdk.h"
#import "truvideo_react_turbo_video_sdk-Swift.h"

@implementation TruvideoReactTurboVideoSdk
RCT_EXPORT_MODULE()

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
}

- (void)cleanNoise:(nonnull NSString *)videoPath resultPath:(nonnull NSString *)resultPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo cleanNoiseWithVideo:videoPath output:resultPath resolve:resolve reject:reject];
}


- (void)compareVideos:(nonnull NSArray *)videoUris resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo compareVideosWithVideos:videoUris resolve:resolve reject:reject];
}


- (void)concatVideos:(nonnull NSArray *)videoUris resultPath:(nonnull NSString *)resultPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo concatVideosWithVideos:videoUris output:resultPath resolve:resolve reject:reject];
}


- (void)editVideo:(nonnull NSString *)videoUri resultPath:(nonnull NSString *)resultPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo editVideoWithVideo:videoUri output:resultPath resolve:resolve reject:reject];
}


- (void)encodeVideo:(nonnull NSString *)videoUri resultPath:(nonnull NSString *)resultPath config:(nonnull NSString *)config resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo changeEncodingWithVideo:videoUri output:resultPath config:config resolve:resolve reject:reject];
}


- (void)generateThumbnail:(nonnull NSString *)videoPath resultPath:(nonnull NSString *)resultPath position:(nonnull NSString *)position width:(nonnull NSString *)width height:(nonnull NSString *)height resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo generateThumbnailWithVideoURL:videoPath outputURL:resultPath position:position width:width height:height resolve:resolve reject:reject];
}


- (void)getResultPath:(nonnull NSString *)path resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo getResultPathWithPath:path resolve:resolve reject:reject];
}


- (void)getVideoInfo:(nonnull NSString *)videoPath resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo getVideoInfoWithVideos:videoPath resolve:resolve reject:reject];
}


- (void)mergeVideos:(nonnull NSArray *)videoUris resultPath:(nonnull NSString *)resultPath config:(nonnull NSString *)config resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  TruVideoReactVideoSdkClass *truvideo = [[TruVideoReactVideoSdkClass alloc] init];
  [truvideo mergeVideosWithVideos:videoUris output:resultPath config:config resolve:resolve reject:reject];
}


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTruvideoReactTurboVideoSdkSpecJSI>(params);
}

@end
