package com.truvideoreactturbovideosdk

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.truvideo.sdk.video.TruvideoSdkVideo

@ReactModule(name = TruvideoReactTurboVideoSdkModule.NAME)
class TruvideoReactTurboVideoSdkModule(reactContext: ReactApplicationContext) :
  NativeTruvideoReactTurboVideoSdkSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  override fun concatVideos(videoUris: ReadableArray?, resultPath: String?, promise: Promise?) {
    try {
      val videoUriList = videoUris?.toArrayList()?.map { it.toString() }
//      val builder = TruvideoSdkVideo.ConcatBuilder(
//        listVideoFile(videoUriList),
//        videoFileDescriptor(resultPath)
//      )
//      scope.launch {
//        val request = builder.build()
//        request.process()
//        promise.resolve("concat successfully")
//      }
      // Handle result
      // the concated video its on 'resultVideoPath'
    } catch (exception: Exception) {
      // Handle error
      promise?.reject(exception.message!!)
      exception.printStackTrace()
    }
  }

  override fun encodeVideo(
    videoUri: String?,
    resultPath: String?,
    config: String?,
    promise: Promise?
  ) {

  }

  override fun getVideoInfo(videoPath: String?, promise: Promise?) {

  }

  override fun compareVideos(videoUris: ReadableArray?, promise: Promise?) {

  }

  override fun mergeVideos(
    videoUris: ReadableArray?,
    resultPath: String?,
    config: String?,
    promise: Promise?
  ) {

  }

  override fun generateThumbnail(
    videoPath: String?,
    resultPath: String?,
    position: String?,
    width: String?,
    height: String?,
    promise: Promise?
  ) {

  }

  override fun cleanNoise(videoPath: String?, resultPath: String?, promise: Promise?) {

  }

  override fun editVideo(videoUri: String?, resultPath: String?, promise: Promise?) {

  }

  override fun getResultPath(path: String?, promise: Promise?) {

  }

  companion object {
    const val NAME = "TruvideoReactTurboVideoSdk"
  }
}
