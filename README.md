# TruVideoReactTurboVideoSdk
Video Module
## truvideo-react-turbo-video-sdk

none

## Installation

```sh
npm install https://github.com/Truvideo/TruVideoReactTurboVideoSdk.git
```

## Usage


```js
import { generateThumbnail,cleanNoise,editVideo,getResultPath,concatVideos,encodeVideo,getVideoInfo,compareVideos,mergeVideos } from 'truvideo-react-turbo-video-sdk';

// ...

generateThumbnail(videoPath: string, resultPath: string,position: string,width: string,height: string)
      .then((result) => {
        console.log('result', result);
      })
      .catch((error) => {
        console.log('error', error);
      });

cleanNoise(videoPath: string,resultPath: string)
      .then((result) => {
              console.log('result', result);
            })
            .catch((error) => {
              console.log('error', error);
            });

editVideo(videoPath: string,resultPath: string)
      .then((result) => {
              console.log('result', result);
            })
            .catch((error) => {
              console.log('error', error);
            });

getResultPath(videoPath: string)
      .then((result) => {
              console.log('result', result);
            })
            .catch((error) => {
              console.log('error', error);
            });

// Concat
try {
    const resultPath = await getResultPath(`${Date.now()}-concatVideo`);
    const request = new ConcatBuilder(selectedItems, resultPath);
    const result = request.build();
    (await result).process;
    console.log('Video concatenated successfully:', result);
} catch (error) {
    console.error('Error concatenating videos:', error);
}

// Encode 
try {
    const resultPath = await getResultPath(`${Date.now()}-encodedVideo`);
    const request = new EncodeBuilder(selectedItems[0], resultPath);
    request.setHeight(640);
    request.setWigth(480);
    request.setFrameRate(FrameRate.fiftyFps);
    const result = request.build();
    (await result).process();
    console.log('Video encoded successfully:', result);
} catch (error) {
    console.error('Error encoding video:', error);
}

getVideoInfo(videoPath: string)
      .then((result) => {
              console.log('result', result);
            })
            .catch((error) => {
              console.log('error', error);
            });

compareVideos(videoUris: string[])
      .then((result) => {
              console.log('result', result);
            })
            .catch((error) => {
              console.log('error', error);
            });

// Merge
try {
    const resultPath = await getResultPath(`${Date.now()}-mergedVideo`);
    const request = new MergeBuilder(selectedItems, resultPath);
    request.setHeight(640);
    request.setWigth(480);
    request.setFrameRate(FrameRate.fiftyFps);
    
    const result = await request.build();

    const video = await request.process();
    // process the video
    //(await result).process
    console.log('Videos merged successfully:', video);
} catch (error) {
    console.error('Error merging videos:', error);
}

```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)