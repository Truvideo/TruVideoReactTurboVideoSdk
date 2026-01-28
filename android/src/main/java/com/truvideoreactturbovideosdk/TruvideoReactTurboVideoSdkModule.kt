package com.truvideoreactturbovideosdk

import android.content.Intent
import android.os.Build
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
import com.truvideo.sdk.video.model.TruvideoSdkVideoRequestStatus
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.time.format.DateTimeFormatter

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
      if(videoUris== null || resultPath == null) {
        promise?.resolve("input path or result path not valid")
        return
      }
      val videoUriList = videoUris.toArrayList().map { it.toString() }

      videoUriList.forEach {
        if(it.endsWith(".png") || it.endsWith(".jpg") || it.endsWith(".jpeg")){
          promise?.resolve("input path must be video not image")
          return
        }
      }

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
    if(videoUri.endsWith(".png") || videoUri.endsWith(".jpg") || videoUri.endsWith(".jpeg")){
      promise?.resolve("input path must be video not image")
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
      promise?.resolve("input path is not valid")
      return
    }
    if(videoPath.endsWith(".png") || videoPath.endsWith(".jpg") || videoPath.endsWith(".jpeg")){
      promise?.resolve("video path must be video not image")
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
          videoTrack.put("bitRate",it.bitRate)
          videoTrack.put("frameRate",it.frameRate)
          videoTrack.put("rotation",it.rotation.name)
          videoTrack.put("durationMillis",it.durationMillis)
          videoTracks.put(videoTrack)
        }

        val audioTracks = JSONArray()
        info.audioTracks.forEach {
          val audioTrack = JSONObject()
          audioTrack.put("index",it.index)
          audioTrack.put("bitRate",it.bitRate)
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
      videoUriList.forEach {
        if(it.endsWith(".png") || it.endsWith(".jpg") || it.endsWith(".jpeg")){
          promise?.resolve("input path must be video not image")
          return
        }
      }
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
      videoUriList.forEach {
        if(it.endsWith(".png") || it.endsWith(".jpg") || it.endsWith(".jpeg")){
          promise?.resolve("input path must be video not image")
          return
        }
      }
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

  override fun getAllRequest(status : String,promise: Promise){
    scope.launch {
      val status = when (status) {
          "cancelled" -> {
            TruvideoSdkVideoRequestStatus.CANCELLED
          }
          "processing" -> {
            TruvideoSdkVideoRequestStatus.PROCESSING
          }
          "complete" -> {
            TruvideoSdkVideoRequestStatus.COMPLETE
          }
          "idle" -> {
            TruvideoSdkVideoRequestStatus.IDLE
          }
          "error" -> {
            TruvideoSdkVideoRequestStatus.ERROR
          }
          else -> {
            null
          }
      }
      val request = TruvideoSdkVideo.getAllRequests(status)
      promise.resolve(returnRequests(request))
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
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        put("createdAt", DateTimeFormatter.ISO_INSTANT.format(request.createdAt.toInstant()))
        put("updatedAt", DateTimeFormatter.ISO_INSTANT.format(request.updatedAt.toInstant()))
      }else{
        put("createdAt", request.createdAt)
        put("updatedAt", request.updatedAt)
      }
      put("status", when(request.status){
        TruvideoSdkVideoRequestStatus.IDLE -> "idle"
        TruvideoSdkVideoRequestStatus.PROCESSING -> "processing"
        TruvideoSdkVideoRequestStatus.ERROR -> "error"
        TruvideoSdkVideoRequestStatus.COMPLETE -> "complete"
        TruvideoSdkVideoRequestStatus.CANCELLED -> "cancelled"
      })
      put("type", request.type.name.lowercase())

    }.toString()
  }

  fun returnRequests(requests: List<TruvideoSdkVideoRequest>): String {
    val jsonArray = JSONArray()

    for (request in requests) {
      val jsonString = returnRequest(request)
      try {
        val jsonObject = JSONObject(jsonString)
        jsonArray.put(jsonObject)
      } catch (e: Exception) {
        e.printStackTrace()
      }
    }

    return jsonArray.toString()
  }

    override fun generateThumbnail(
        videoPath: String?,
        resultPath: String?,
        position: String?,
        width: String?,
        height: String?,
        promise: Promise?
    ) {
        if(videoPath == null || resultPath == null){
            promise?.reject("video path error","input path or result path not valid")
            return
        }
        if(videoPath.endsWith(".png") || videoPath.endsWith(".jpg") || videoPath.endsWith(".jpeg")){
            promise?.reject("video path error","video path must be video not image")
            return
        }

        scope.launch {
            try {
                // Get video info first
                val videoInfo = TruvideoSdkVideo.getInfo(videoFile(videoPath))
                val positionLong = position?.toLongOrNull() ?: 0L

                // Validate position is within video duration
                if(positionLong > videoInfo.durationMillis) {
                    promise?.reject(
                        "position error",
                        "Position ($positionLong ms) exceeds video duration (${videoInfo.durationMillis} ms)"
                    )
                    return@launch
                }

                // Create thumbnail
                val result = TruvideoSdkVideo.createThumbnail(
                    videoFile(videoPath),
                    videoFileDescriptor(resultPath),
                    positionLong,
                    width?.toIntOrNull() ?: 0,
                    height?.toIntOrNull() ?: 0
                )

                promise?.resolve(result)

            } catch (e: truvideo.sdk.common.exceptions.TruvideoSdkException) {
                // Specific handling for SDK exceptions
                Log.e(NAME, "TruvideoSdkException in generateThumbnail: ${e.message}", e)
                promise?.reject("TruvideoSdkException", e.message ?: "Unknown SDK error")

            } catch (e: Exception) {
                // Generic exception handling
                Log.e(NAME, "Exception in generateThumbnail: ${e.message}", e)
                promise?.reject("Exception", e.message ?: "Unknown error")
            }
        }
    }

    override fun cleanNoise(videoPath: String?, resultPath: String?, promise: Promise?) {
        if(videoPath == null || resultPath == null){
            promise?.reject("path error", "input path or result path not valid")
            return
        }
        if(videoPath.endsWith(".png") || videoPath.endsWith(".jpg") || videoPath.endsWith(".jpeg")){
            promise?.reject("path error", "video path must be video not image")
            return
        }

        scope.launch {
            try {
                val result = TruvideoSdkVideo.clearNoise(
                    videoFile(videoPath),
                    videoFileDescriptor(resultPath)
                )
                promise?.resolve(result)

            } catch (e: truvideo.sdk.common.exceptions.TruvideoSdkException) {
                Log.e(NAME, "TruvideoSdkException in cleanNoise: ${e.message}", e)
                promise?.reject("TruvideoSdkException", e.message ?: "Unknown SDK error")

            } catch (e: Exception) {
                Log.e(NAME, "Exception in cleanNoise: ${e.message}", e)
                promise?.reject("Exception", e.message ?: "Unknown error")
            }
        }
    }

  override fun editVideo(videoUri: String?, resultPath: String?, promise: Promise?) {
    if(videoUri!!.endsWith(".png") || videoUri.endsWith(".jpg") || videoUri.endsWith(".jpeg")){
      promise?.resolve("video path must be video not image")
      return
    }
    mainPromise = promise
    currentActivity!!.startActivity(Intent(currentActivity, EditScreenActivity::class.java).putExtra("videoUri", videoUri).putExtra("resultPath", resultPath))
  }

  override fun getResultPath(path: String?, promise: Promise?) {
    val basePath  = currentActivity!!.filesDir
    promise?.resolve( File("$basePath/$path").path)
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
