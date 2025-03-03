package com.truvideoreactturbovideosdk

import android.content.Intent
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.google.gson.Gson
import com.truvideo.sdk.video.TruvideoSdkVideo
import com.truvideo.sdk.video.model.TruvideoSdkVideoFile
import com.truvideo.sdk.video.model.TruvideoSdkVideoFileDescriptor
import com.truvideo.sdk.video.model.TruvideoSdkVideoFrameRate
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.File

@ReactModule(name = TruvideoReactTurboVideoSdkModule.NAME)
class TruvideoReactTurboVideoSdkModule(reactContext: ReactApplicationContext) :
  NativeTruvideoReactTurboVideoSdkSpec(reactContext) {
  val scope = CoroutineScope(Dispatchers.Main)
  val gson = Gson()

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
      if(videoUris== null || resultPath == null){
        promise?.resolve("input path or result path not valid")
        return
      }
      val videoUriList = videoUris.toArrayList().map { it.toString() }

      val builder = TruvideoSdkVideo.ConcatBuilder(
        listVideoFile(videoUriList),
        videoFileDescriptor(resultPath)
      )
      scope.launch {
        val request = builder.build()
        request.process()
        promise!!.resolve("concat successfully")
      }
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
// Change encoding of video and save to resultPath
    // Build the encode builder
    if(videoUri== null || resultPath == null){
      promise?.resolve("input path or result path not valid")
      return
    }
    val result = TruvideoSdkVideo.EncodeBuilder(
      videoFile(videoUri),
      videoFileDescriptor(resultPath))
    val configuration = JSONObject(config)
    if(configuration.has("height")){
      result.height = configuration.getInt("height")
    }
    if(configuration.has("width")){
      result.width = configuration.getInt("width")
    }
    if(configuration.has("framesRate")){
      when(configuration.getString("framesRate")){
        "twentyFourFps" -> result.framesRate = TruvideoSdkVideoFrameRate.twentyFourFps
        "twentyFiveFps" -> result.framesRate = TruvideoSdkVideoFrameRate.twentyFiveFps
        "thirtyFps" -> result.framesRate = TruvideoSdkVideoFrameRate.thirtyFps
        "fiftyFps" -> result.framesRate = TruvideoSdkVideoFrameRate.fiftyFps
        "sixtyFps" -> result.framesRate = TruvideoSdkVideoFrameRate.sixtyFps
        else -> result.framesRate = TruvideoSdkVideoFrameRate.defaultFrameRate
      }
    }
//    if(configuration.has("videoCodec")){
//      when(configuration.getString("videoCodec")){
//        "h264" -> result.videoCodec = TruvideoSdkVideoVideoCodec.h264
//        "h265" -> result.videoCodec = TruvideoSdkVideoVideoCodec.h265
//        "libx264" -> result.videoCodec = TruvideoSdkVideoVideoCodec.libx264
//        else -> result.videoCodec = TruvideoSdkVideoVideoCodec.defaultCodec
//      }
//    }
    // Process the encode builder
    scope.launch{
      result.build().process()
      promise?.resolve("encode success")
    }
  }

  override fun getVideoInfo(videoPath: String?, promise: Promise?) {
    if(videoPath== null ){
      promise?.resolve("input path or result path not valid")
      return
    }
    try {
      scope.launch {
        val info = TruvideoSdkVideo.getInfo(videoFile(videoPath))
        promise?.resolve(gson.toJson(info))
      }
    } catch (exception: Exception) {
      exception.printStackTrace()
      promise?.reject(exception.message.toString())
      // Handle error
    }
  }

  override fun compareVideos(videoUris: ReadableArray?, promise: Promise?) {
    if(videoUris== null ){
      promise?.resolve("input path or result path not valid")
      return
    }
    try {
      val videoUriList = videoUris.toArrayList().map { it.toString() }
      scope.launch {
        val result = TruvideoSdkVideo.compare(listVideoFile(videoUriList))
        promise?.resolve(result)
      }
    } catch (exception: Exception) {
      // Handle error
      promise?.reject(exception.message.toString())
      exception.printStackTrace()
    }

  }

  override fun mergeVideos(
    videoUris: ReadableArray?,
    resultPath: String?,
    config: String?,
    promise: Promise?
  ) {
    if(videoUris== null || resultPath == null){
      promise?.resolve("input path or result path not valid")
      return
    }
    try{
      val videoUriList = videoUris.toArrayList().map { it.toString() }
      val builder = TruvideoSdkVideo.MergeBuilder(listVideoFile(videoUriList), videoFileDescriptor(resultPath))
      val configuration = JSONObject(config)
      if(configuration.has("height")){
        builder.height = configuration.getInt("height")
      }
      if(configuration.has("width")){
        builder.width = configuration.getInt("width")
      }
      if(configuration.has("framesRate")){
        when(configuration.getString("framesRate")){
          "twentyFourFps" -> builder.framesRate = TruvideoSdkVideoFrameRate.twentyFourFps
          "twentyFiveFps" -> builder.framesRate = TruvideoSdkVideoFrameRate.twentyFiveFps
          "thirtyFps" -> builder.framesRate = TruvideoSdkVideoFrameRate.thirtyFps
          "fiftyFps" -> builder.framesRate = TruvideoSdkVideoFrameRate.fiftyFps
          "sixtyFps" -> builder.framesRate = TruvideoSdkVideoFrameRate.sixtyFps
          else -> builder.framesRate = TruvideoSdkVideoFrameRate.defaultFrameRate
        }
      }
//      if(configuration.has("videoCodec")){
//        when(configuration.getString("videoCodec")){
//          "h264" -> builder.videoCodec = TruvideoSdkVideoVideoCodec.h264
//          "h265" -> builder.videoCodec = TruvideoSdkVideoVideoCodec.h265
//          "libx264" -> builder.videoCodec = TruvideoSdkVideoVideoCodec.libx264
//          else -> builder.videoCodec = TruvideoSdkVideoVideoCodec.defaultCodec
//        }
//      }
      scope.launch {
        val request = builder.build()
        request.process()
        promise?.resolve("Merge Successful")
      }
      // Handle result
      // the merged video its on 'resultVideoPath'
    }catch (exception:Exception){
      //Handle error
      promise?.reject(exception.message.toString())
      exception.printStackTrace()
    }
  }

  override fun generateThumbnail(
    videoPath: String?,
    resultPath: String?,
    position: String?,
    width: String?,
    height: String?,
    promise: Promise?
  ) {
    if(videoPath== null || resultPath == null){
      promise?.resolve("input path or result path not valid")
      return
    }
    try {
      scope.launch {
        val result = TruvideoSdkVideo.createThumbnail(
          videoFile(videoPath),
          videoFileDescriptor(resultPath),
          try{position!!.toLong()}catch (e : Exception){"0".toLong()},
          try{width!!.toInt()}catch (e : Exception){"0".toInt()}, // or null
          try{height!!.toInt()}catch (e:Exception){"0".toInt()} // or null
        )
        promise?.resolve(result)
      }
//      setThumbnail(context,videoPath,resultPath)

      // Handle result
      // the thumbnail image is stored in resultImagePath
    } catch (exception: Exception) {
      // Handle error
      promise?.reject(exception.message.toString())
      exception.printStackTrace()
    }
  }

  override fun cleanNoise(videoPath: String?, resultPath: String?, promise: Promise?) {
    if(videoPath== null || resultPath == null){
      promise?.resolve("input path or result path not valid")
      return
    }
    try{
      scope.launch {
        val result = TruvideoSdkVideo.clearNoise(videoFile(videoPath), videoFileDescriptor(resultPath))
        promise?.resolve("Clean Noise Successful")
      }
      // Handle result
      // the cleaned video will be stored in resultVideoPath
    }catch (exception:Exception){
      // Handle error
      promise?.reject(exception.message.toString())
      exception.printStackTrace()
    }
  }

  override fun editVideo(videoUri: String?, resultPath: String?, promise: Promise?) {
    mainPromise = promise
    currentActivity!!.startActivity(Intent(currentActivity, EditScreenActivity::class.java).putExtra("videoUri", videoUri).putExtra("resultPath", resultPath))
  }

  override fun getResultPath(path: String?, promise: Promise?) {
    val basePath  = currentActivity!!.filesDir
    promise?.resolve( File("$basePath/camera/$path").path)
  }

  companion object {
    const val NAME = "TruvideoReactTurboVideoSdk"
    var mainPromise : Promise? = null
    var promise2 : Promise?  = null
  }

  fun videoFile(inputPath : String): TruvideoSdkVideoFile {
    return TruvideoSdkVideoFile.custom(inputPath)
  }
  fun videoFileDescriptor(outputPath : String): TruvideoSdkVideoFileDescriptor {
    return TruvideoSdkVideoFileDescriptor.custom(outputPath)
  }
  fun listVideoFile(list : List<String>): List<TruvideoSdkVideoFile>{
    val listVideo = ArrayList<TruvideoSdkVideoFile>()
    list.forEach {
      listVideo.add(videoFile(it))
    }
    return listVideo
  }

}
