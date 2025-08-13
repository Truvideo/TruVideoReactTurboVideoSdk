package com.truvideoreactturbovideosdk

import android.content.Intent
import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.truvideo.sdk.video.TruvideoSdkVideo
import com.truvideo.sdk.video.model.TruvideoSdkVideoFile
import com.truvideo.sdk.video.model.TruvideoSdkVideoFileDescriptor
import com.truvideo.sdk.video.model.TruvideoSdkVideoFrameRate
import com.truvideo.sdk.video.model.TruvideoSdkVideoRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

@ReactModule(name = TruvideoReactTurboVideoSdkModule.NAME)
class TruvideoReactTurboVideoSdkModule(reactContext: ReactApplicationContext) :
  NativeTruvideoReactTurboVideoSdkSpec(reactContext) {
  val scope = CoroutineScope(Dispatchers.Main)

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

        promise!!.resolve(returnRequest(request))
      }
      // Handle result
      // the concat video its on 'resultVideoPath'
    } catch (exception: Exception) {
      // Handle error
      promise?.reject("Exception",exception.message!!)
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
    val configuration = JSONObject(config!!)
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
    try{
      scope.launch{
        val request = result.build()
        promise?.resolve(returnRequest(request))
      }
    }catch (e: Exception){
      promise?.reject("Exception",e.message.toString())
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

        val videoTracks = JSONArray()
        info.videoTracks.forEach {
          val videoTrack = JSONObject()
          videoTrack.put("index",it.index)
          videoTrack.put("width",it.width)
          videoTrack.put("height",it.height)
          videoTrack.put("rotatedWidth",it.rotatedWidth)
          videoTrack.put("rotatedHeight",it.rotatedHeight)
          videoTrack.put("codec",it.codec)
          videoTrack.put("codecTag",it.codecTag)
          videoTrack.put("pixelFormat",it.pixelFormat)
          videoTrack.put("bitrate",it.bitrate)
          videoTrack.put("frameRate",it.frameRate)
          videoTrack.put("rotation",it.rotation.name)
          videoTrack.put("durationMillis",it.durationMillis)
          videoTracks.put(videoTrack)
        }

        val audioTracks = JSONArray()
        info.audioTracks.forEach {
          val audioTrack = JSONObject()
          audioTrack.put("index",it.index)
          audioTrack.put("bitrate",it.bitrate)
          audioTrack.put("sampleRate",it.sampleRate)
          audioTrack.put("channels",it.channels)
          audioTrack.put("codec",it.codec)
          audioTrack.put("codecTag",it.codecTag)
          audioTrack.put("durationMillis",it.durationMillis)
          audioTrack.put("channelLayout",it.channelLayout)
          audioTrack.put("sampleFormat",it.sampleFormat)
          audioTracks.put(audioTrack)
        }

        val mainResponse = JSONObject().apply {
          put("path",info.path)
          put("size",info.size)
          put("durationMillis",info.durationMillis)
          put("format",info.format)
          put("videoTracks",videoTracks)
          put("audioTracks",audioTracks)
        }
        promise?.resolve(mainResponse.toString())
      }
    } catch (exception: Exception) {
      exception.printStackTrace()
      promise?.reject("Exception",exception.message.toString())
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
      promise?.reject("Exception",exception.message.toString())
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
      val configuration = JSONObject(config!!)
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
//          "libX264" -> builder.videoCodec = TruvideoSdkVideoVideoCodec.libX264
//          else -> builder.videoCodec = TruvideoSdkVideoVideoCodec.defaultCodec
//        }
//      }
      scope.launch {
        val request = builder.build()
        promise?.resolve(returnRequest(request))
      }
      // Handle result
      // the merged video its on 'resultVideoPath'
    }catch (exception:Exception){
      //Handle error
      promise?.reject(exception.message.toString(),exception)
      exception.printStackTrace()
    }
  }

  override fun getRequestById(id : String,promise: Promise){
    try{
      scope.launch {
        val request  = TruvideoSdkVideo.getRequestById(id)
        promise.resolve(returnRequest(request!!))
      }
    }catch (e: Exception){
      promise.reject("Exception",e.message)
    }
  }

  override fun processVideo(id : String,promise: Promise){
    try{
      scope.launch {
        val request = TruvideoSdkVideo.getRequestById(id)
        request!!.process()
        promise.resolve(returnRequest(request))
      }
    }catch (e: Exception){
      promise.reject("Exception",e.message)
    }
  }

  fun delete(id : String,promise: Promise){
    try{
      scope.launch {
        val request = TruvideoSdkVideo.getRequestById(id)
        request!!.delete()
        promise.resolve(returnRequest(request))
      }
    }catch (e: Exception){
      promise.reject("Exception",e.message)
    }
  }

  override fun cancelVideo(id : String,promise: Promise){
    try{
      scope.launch {
        val request = TruvideoSdkVideo.getRequestById(id)
        request!!.cancel()
        promise.resolve(returnRequest(request))
      }
    }catch (e: Exception){
      promise.reject("Exception",e.message)
    }
  }

  fun returnRequest(request : TruvideoSdkVideoRequest) : String{
    return JSONObject().apply{
      put("id",request.id)
      put("createdAt", request.createdAt)
      put("status", request.status.name)
      put("type", request.type.name)
      put("updatedAt", request.updatedAt)
    }.toString()
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
          try{position!!.toLong()}catch (e : Exception){
            Log.d("TAG", "position not valid: $e")
            "0".toLong() },
          try{width!!.toInt()}catch (e : Exception){
            Log.d("TAG", "width not valid: $e")
            "0".toInt()}, // or null
          try{height!!.toInt()}catch (e:Exception){
            Log.d("TAG", "height not valid: $e")
            "0".toInt()} // or null
        )
        promise?.resolve(result)
      }
    } catch (exception: Exception) {
      // Handle error
      promise?.reject("Exception",exception.message.toString())
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
        promise?.resolve(result)
      }
      // Handle result
      // the cleaned video will be stored in resultVideoPath
    }catch (exception:Exception){
      // Handle error
      promise?.reject("Exception",exception.message.toString())
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
