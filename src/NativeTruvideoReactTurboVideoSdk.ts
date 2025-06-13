import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  multiply(a: number, b: number): number;
  concatVideos(videoUris: string[], resultPath: string): Promise<string>;
  encodeVideo(
    videoUri: string,
    resultPath: string,
    config: string
  ): Promise<string>;
  getVideoInfo(videoPath: string): Promise<string>;
  compareVideos(videoUris: string[]): Promise<string>;
  mergeVideos(
    videoUris: string[],
    resultPath: string,
    config: string
  ): Promise<string>;
  generateThumbnail(
    videoPath: string,
    resultPath: string,
    position: string,
    width: string,
    height: string
  ): Promise<string>;
  cleanNoise(videoPath: string, resultPath: string): Promise<string>;
  editVideo(videoUri: string, resultPath: string): Promise<string>;
  getResultPath(path: string): Promise<string>;
  getRequestById(id: string): Promise<string>;
  processVideo(id: string): Promise<string>;
  cancelVideo(id: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  'TruvideoReactTurboVideoSdk'
);
