import TruvideoReactTurboVideoSdk from './NativeTruvideoReactTurboVideoSdk';

export function multiply(a: number, b: number): number {
  return TruvideoReactTurboVideoSdk.multiply(a, b);
}

export function concatVideos(
  videoUris: string[],
  resultPath: string
): Promise<string> {
  return TruvideoReactTurboVideoSdk.concatVideos(videoUris, resultPath);
}

export function encodeVideo(
  videoUri: string,
  resultPath: string,
  config: string
): Promise<string> {
  return TruvideoReactTurboVideoSdk.encodeVideo(videoUri, resultPath, config);
}

export function getVideoInfo(videoPath: string): Promise<string> {
  return TruvideoReactTurboVideoSdk.getVideoInfo(videoPath);
}
export function compareVideos(videoPath: string[]): Promise<string> {
  return TruvideoReactTurboVideoSdk.compareVideos(videoPath);
}

export function mergeVideos(
  videoUris: string[],
  resultPath: string,
  config: string
): Promise<string> {
  return TruvideoReactTurboVideoSdk.mergeVideos(videoUris, resultPath, config);
}

export function cleanNoise(
  videoUri: string,
  resultPath: string
): Promise<string> {
  return TruvideoReactTurboVideoSdk.cleanNoise(videoUri, resultPath);
}

export function editVideo(
  videoUri: string,
  resultPath: string
): Promise<string> {
  return TruvideoReactTurboVideoSdk.editVideo(videoUri, resultPath);
}
export function getResultPath(videoPath: string): Promise<string> {
  return TruvideoReactTurboVideoSdk.getResultPath(videoPath);
}

export function generateThumbnail(
  videoPath: string,
  resultPath: string,
  position: string,
  width: string,
  height: string
): Promise<string> {
  return TruvideoReactTurboVideoSdk.generateThumbnail(
    videoPath,
    resultPath,
    position,
    width,
    height
  );
}
