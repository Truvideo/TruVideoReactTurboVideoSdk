import TruvideoReactTurboVideoSdk from './NativeTruvideoReactTurboVideoSdk';

// Define a class for the VideoTrack
export interface VideoTrack {
  index : string;
  width : string;
  height : string;
  rotatedWidth : string;
  rotatedHeight : string;
  codec : string;
  codecTag : string;
  pixelFormat : string;
  bitrate : string;
  frameRate : string;
  rotation : string;
  durationMillis : string;
}

// Define a class for the AudioTrack
export interface AudioTrack {
  index: string;
  bitrate: string;
  sampleRate: string;
  channels: string;
  codec: string;
  codecTag: string;
  durationMillis: string;
  channelLayout: string;
  sampleFormat: string;
}

// Define a class for the main response data
export interface MediaInfo {
  path : string;
  size : number;
  durationMillis : number;
  format : string;
  videoTracks : VideoTrack[];
  audioTracks : AudioTrack[];
}

export function getVideoInfo(videoPath: string): Promise<MediaInfo | null> {
  return TruvideoReactTurboVideoSdk.getVideoInfo(videoPath).then((response: string) => {
      try {
        const parsed: MediaInfo = JSON.parse(response);
        return parsed;
      } catch (e) {
        console.error("Failed to parse MediaData JSON:", e);
        return null;
      }
    });
}
export async function compareVideos(videoPath: string[]): Promise<Boolean> {
  return TruvideoReactTurboVideoSdk.compareVideos(videoPath).then((response: string) => {
      try {
        const parsed: Boolean = JSON.parse(response);
        return parsed;
      } catch (e) {
        console.error("Failed to parse MediaData JSON:", e);
        return false;
      }
    });
}

export async function getAllRequest(status: string): Promise<BuilderResponse[] | null> {
  return TruvideoReactTurboVideoSdk.getAllRequest(status).then((response: string) => {
      try {
        const parsed: BuilderResponse[] = JSON.parse(response);
        return parsed;
      } catch (e) {
        console.error("Failed to parse MediaData JSON:", e);
        return null;
      }
    });;
}

export async function getRequestById(id: string): Promise<BuilderResponse | null> {
  return TruvideoReactTurboVideoSdk.getRequestById(id).then((response: string) => {
      try {
        const parsed: BuilderResponse = JSON.parse(response);
        return parsed;
      } catch (e) {
        console.error("Failed to parse MediaData JSON:", e);
        return null;
      }
    });;
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

export enum FrameRate {
  twentyFourFps = 'twentyFourFps',
  twentyFiveFps = 'twentyFiveFps',
  thirtyFps = 'thirtyFps',
  fiftyFps = 'fiftyFps',
  sixtyFps = 'sixtyFps',
}

export interface BuilderResponse {
  id: string;
  createdAt: string;
  status: string;
  type: string;
  updatedAt: string;
}

export class MergeBuilder {
  private _filePath: string[];
  private resultPath: string;
  private height: string = '';
  private width: string = '';
  private frameRate: string = '';
  private mergeData: BuilderResponse | undefined;

  constructor(filePaths: string[], resultPath: string) {
    if (!filePaths) {
      throw new Error('filePath is required for MediaBuilder.');
    }
    if (!resultPath) {
      throw new Error('resultPath is required for MediaBuilder.');
    }
    this._filePath = filePaths;
    this.resultPath = resultPath;
  }

  setHeight(height: number): MergeBuilder {
    this.height = '' + height;
    return this;
  }

  setWigth(width: number): MergeBuilder {
    this.width = '' + width;
    return this;
  }

  setFrameRate(frameRate: FrameRate) {
    if (frameRate == FrameRate.fiftyFps) {
      this.frameRate = 'fiftyFps';
    } else if (frameRate == FrameRate.sixtyFps) {
      this.frameRate = 'sixtyFps';
    } else if (frameRate == FrameRate.twentyFourFps) {
      this.frameRate = 'twentyFourFps';
    } else if (frameRate == FrameRate.twentyFiveFps) {
      this.frameRate = 'twentyFiveFps';
    } else if (frameRate == FrameRate.thirtyFps) {
      this.frameRate = 'thirtyFps';
    } else {
      this.frameRate = 'fiftyFps';
    }
  }

  async build(): Promise<MergeBuilder> {
    const config = {
      height: this.height,
      width: this.width,
      framesRate: this.frameRate,
    };

    var response = await TruvideoReactTurboVideoSdk.mergeVideos(
      this._filePath,
      this.resultPath,
      JSON.stringify(config)
    );
    this.mergeData = JSON.parse(response);
    return this;
  }

  async process(): Promise<BuilderResponse> {
    if (!this.mergeData?.id) {
      throw new Error(
        'Call build() and ensure it succeeds before calling process().'
      );
    }
    var response = await TruvideoReactTurboVideoSdk.processVideo(
      this.mergeData.id
    );
    this.mergeData = JSON.parse(response) as BuilderResponse;
    return this.mergeData;
  }

  async cancel(): Promise<BuilderResponse> {
    if (!this.mergeData?.id) {
      throw new Error(
        'Call build() and ensure it succeeds before calling cancel().'
      );
    }
    var response = await TruvideoReactTurboVideoSdk.cancelVideo(
      this.mergeData.id
    );
    this.mergeData = JSON.parse(response) as BuilderResponse;
    return this.mergeData;
  }
}

export class ConcatBuilder {
  private _filePath: string[];
  private resultPath: string;
  private concatData: BuilderResponse | undefined;

  constructor(filePaths: string[], resultPath: string) {
    if (!filePaths) {
      throw new Error('filePath is required for ConcatBuilder.');
    }
    if (!resultPath) {
      throw new Error('resultPath is required for ConcatBuilder.');
    }
    this._filePath = filePaths;
    this.resultPath = resultPath;
  }

  async build(): Promise<ConcatBuilder> {
    var response = await TruvideoReactTurboVideoSdk.concatVideos(
      this._filePath,
      this.resultPath
    );
    this.concatData = JSON.parse(response);
    return this;
  }

  async process(): Promise<BuilderResponse> {
    if (!this.concatData?.id) {
      throw new Error(
        'concatData.id is undefined. Call build() and ensure it succeeds before calling process().'
      );
    }
    var response = await TruvideoReactTurboVideoSdk.processVideo(
      this.concatData.id
    );
    this.concatData = JSON.parse(response) as BuilderResponse;
    return this.concatData;
  }

  async cancel(): Promise<BuilderResponse> {
    if (!this.concatData?.id) {
      throw new Error(
        'concatData.id is undefined. Call build() and ensure it succeeds before calling cancel().'
      );
    }
    var response = await TruvideoReactTurboVideoSdk.cancelVideo(
      this.concatData.id
    );
    this.concatData = JSON.parse(response) as BuilderResponse;
    return this.concatData;
  }
}

export class EncodeBuilder {
  private _filePath: string;
  private resultPath: string;
  private height: string = '';
  private width: string = '';
  private frameRate: string = '';
  private mergeData: BuilderResponse | undefined;

  constructor(filePaths: string, resultPath: string) {
    if (!filePaths) {
      throw new Error('filePath is required for EncodeBuilder.');
    }
    if (!resultPath) {
      throw new Error('resultPath is required for EncodeBuilder.');
    }
    this._filePath = filePaths;
    this.resultPath = resultPath;
  }

  setHeight(height: number): EncodeBuilder {
    this.height = '' + height;
    return this;
  }

  setWidth(width: number): EncodeBuilder {
    this.width = '' + width;
    return this;
  }

  setFrameRate(frameRate: FrameRate) {
    if (frameRate == FrameRate.fiftyFps) {
      this.frameRate = 'fiftyFps';
    } else if (frameRate == FrameRate.sixtyFps) {
      this.frameRate = 'sixtyFps';
    } else if (frameRate == FrameRate.twentyFourFps) {
      this.frameRate = 'twentyFourFps';
    } else if (frameRate == FrameRate.twentyFiveFps) {
      this.frameRate = 'twentyFiveFps';
    } else if (frameRate == FrameRate.thirtyFps) {
      this.frameRate = 'thirtyFps';
    } else {
      this.frameRate = 'fiftyFps';
    }
  }

  async build(): Promise<EncodeBuilder> {
    const config = {
      height: this.height,
      width: this.width,
      framesRate: this.frameRate,
    };

    var response = await TruvideoReactTurboVideoSdk.encodeVideo(
      this._filePath,
      this.resultPath,
      JSON.stringify(config)
    );
    this.mergeData = JSON.parse(response);
    return this;
  }

  async process(): Promise<BuilderResponse> {
    if (!this.mergeData?.id) {
      throw new Error(
        'Call build() and ensure it succeeds before calling process().'
      );
    }
    // process video
    var response = await TruvideoReactTurboVideoSdk.processVideo(
      this.mergeData.id
    );
    this.mergeData = JSON.parse(response) as BuilderResponse;
    return this.mergeData;
  }

  async cancel(): Promise<BuilderResponse> {
    if (!this.mergeData?.id) {
      throw new Error(
        'Call build() and ensure it succeeds before calling cancel().'
      );
    }
    // cancel video
    var response = await TruvideoReactTurboVideoSdk.cancelVideo(
      this.mergeData.id
    );

    this.mergeData = JSON.parse(response) as BuilderResponse;
    return this.mergeData;
  }
}
