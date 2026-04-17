//
//  TruvideoReactTurboVideo.swift
//  truvideo-react-turbo-video-sdk
//
//  Created by mac on 10/02/2025.
//

import Foundation
import TruvideoSdkVideo
import Foundation
import UIKit
import React
import Combine


@objc public class TruVideoReactVideoSdkClass: NSObject {
    
  
  @objc public func getResultPath(path: String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let fileManager = FileManager.default

        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let outputFolderURL = documentsURL.appendingPathComponent("output")
            if !fileManager.fileExists(atPath: outputFolderURL.path) {
                try fileManager.createDirectory(at: outputFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            let resultPath = outputFolderURL.appendingPathComponent(path).path
            resolve(resultPath)
        } catch {
            let error = NSError(domain: "com.yourdomain.yourapp", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get document directory path"])
            reject("no_path", "There is no result path", error)
        }
    }

    
   
  @objc public func compareVideos(videos:[String],resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let urlArray: [URL] = createUrlArray(videos: videos)
        Task{
            do {
                var inputUrl : [TruvideoSdkVideoFile] = []
                for url in urlArray {
                    inputUrl.append(.init(url: url))
                }
                
                // Check if the videos can be concatenated using TruvideoSdkVideo
                let isConcat = try await TruvideoSdkVideo.canConcat(input: inputUrl)
                resolve(isConcat)
            } catch {
                // If an error occurs, return false indicating concatenation is not possible
                reject("json_error", "Error parsing JSON", error)
            }
        }
    }
    
  @objc public func getVideoInfo(videos: String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
      Task {
        do {
          let urlArray: URL = convertStringToURL(videos)
          var inputUrl : TruvideoSdkVideoFile = .init(url: urlArray)
          let videoInfo = try await TruvideoSdkVideo.getVideoInformation(input: inputUrl)
          
          
          let dictionaryResult : [String : Any] = [
                      "path": convertStringToURL(videoInfo.path).path,
                      "size": videoInfo.size,
                      "durationMillis": videoInfo.durationMillis,
                      "format": videoInfo.format,
                      "videoTracks": videoInfo.videoTracks.map { video in
                          return [
                              "index": video.index,
                              "width": video.width,
                              "height": video.height,
                              "rotatedWidth": video.rotatedWidth,
                              "rotatedHeight": video.rotatedHeight,
                              "codec": video.codec,
                              "codecTag": video.codecTag,
                              "pixelFormat": video.pixelFormat,
                              "bitRate": video.bitRate,
                              "frameRate": video.frameRate,
                              "rotation": video.rotation,
                              "durationMillis": video.durationMillis
                          ] as [String: Any]
                      },
                      "audioTracks": videoInfo.audioTracks.map { audio in
                        return [
                          "index": audio.index,
                          "codec": audio.codec,
                          "codecTag": audio.codecTag,
                          "sampleFormat": audio.sampleFormat,
                          "bitRate": audio.bitRate,
                          "sampleRate": audio.sampleRate,
                          "channels": audio.channels,
                          "channelLayout": audio.channelLayout,
                          "durationMillis": audio.durationMillis
                        ] as [String: Any]
                      }
                    ]
          do{
            let jsonData = try JSONSerialization.data(withJSONObject: dictionaryResult, options: [])
              if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("json",jsonString)
                resolve(jsonString)
              }else{
                resolve("{}")
              }
            }
          } catch {
              reject("SDK_Error", "get_Video_Info_Failed", error)
          }
      }
  }
    
    func convertStringToURL(_ urlString: String) -> URL{
        guard let url = URL(string: "file://\(urlString)") else {
            return  URL(string: urlString)!
        }
        return url
    }
    func convertURLToString(_ url: URL) -> String {
        if url.isFileURL {
            return url.path  // returns the local file system path
        } else {
            return url.absoluteString // returns the full URL string
        }
    }

    func createUrlArray(videos : [String]) -> [URL]{
        var urlArray: [URL] = []
        for item in videos {
            urlArray.append(convertStringToURL(item))
        }
        return urlArray
    }
    
    
  @objc public func generateThumbnail(videoURL: String,outputURL: String,position: String,width: String,height: String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock)  {
        if let positionTime = Double(position){
            Task{
                do {
                    let videoUrl = self.convertStringToURL(videoURL)
                    let inputPath : TruvideoSdkVideoFile = try .init(url: videoUrl)
                    let outputUrl = self.convertStringToURL(outputURL)
                    let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)
                    // Generate a thumbnail for the provided video using TruvideoSdkVideo's thumbnailGenerator
                    let thumbnail = try await TruvideoSdkVideo.generateThumbnail(input: inputPath, output: outputPath, position: positionTime, width: Int(width), height: Int(height))
                    resolve(thumbnail.generatedThumbnailURL.path)
                    // Handle result - thumbnail.generatedThumbnailURL
                } catch {
                    reject("json_error", "Error parsing JSON", error)
                    // Handle any errors that occur during the thumbnail generation process
                }
            }
        }
        
    }
    
    
    
  @objc public func cleanNoise(video: String, output: String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock)  {
        let videoUrl = convertStringToURL(video)
        let outputUrl = convertStringToURL(output)
        Task{
            do {
                let inputPath : TruvideoSdkVideoFile = .init(url: videoUrl)
                let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)
                // Attempt to clean noise from the input video file using TruvideoSdkVideo's engine
                let result = try await TruvideoSdkVideo.engine.clearNoiseForFile(input: inputPath, output: outputPath)
                resolve(result.fileURL.path)
            } catch {
                reject("json_error", "Error parsing JSON", error)
                // Handle any errors that occur during the noise cleaning process
            }
        }
        
    }

  @objc public func concatVideos(videos: [String], output: String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task{
            do {
                let videoUrl = createUrlArray(videos: videos)
                let outputUrl = convertStringToURL(output)
                print(outputUrl)
                print(videoUrl)
                var inputUrl : [TruvideoSdkVideoFile] = []
                for url in videoUrl {
                    inputUrl.append(.init(url: url))
                }
                let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)

                // Concatenate the videos using ConcatBuilder
                let builder = TruvideoSdkVideo.ConcatBuilder(input: inputUrl, output: outputPath)
                // Print the output path of the concatenated video
                let result = try builder.build()
                
                resolve(sendRequest(videoRequest: result))
                print("Successfully concatenated", result.id)
                
                
            }catch{
              reject("Exception", error.localizedDescription, error)
            }
        }
        
    }
    
  @objc public func mergeVideos(videos: [String], output: String,config : String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Create a MergeBuilder instance with specified parameters
        Task{
            let videoUrl = self.createUrlArray(videos: videos)
            let outputUrl = self.convertStringToURL(output)
            guard let data = config.data(using: .utf8) else {
                print("Invalid JSON string")
                reject("json_error", "Invalid JSON string", nil)
                return
            }
            do {
                if let configuration = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(configuration)
                    
                    // Parse width and height from strings
                    guard let widthStr = configuration["width"] as? String, let width = CGFloat(Double(widthStr) ?? 0) as? CGFloat else {
                        print("Width is not a valid string or missing")
                        return
                    }
                    
                    guard let heightStr = configuration["height"] as? String, let height = CGFloat(Double(heightStr) ?? 0) as? CGFloat else {
                        print("Height is not a valid string or missing")
                        return
                    }
                    // Parse frameRate and videoCodec as strings
                    guard let frameRateStr = configuration["framesRate"] as? String else {
                        print("framesRate or videoCodec are not valid strings or missing")
                        return
                    }
                    var inputUrl : [TruvideoSdkVideoFile] = []
                    for url in videoUrl {
                        inputUrl.append(.init(url: url))
                    }
                    let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)
                    let builder = TruvideoSdkVideo.MergeBuilder(input: inputUrl, output: outputPath)
                    builder.width = width
                    builder.height = height
                    builder.framesRate = frameRate(frameRateStr)
                  
                
                    let result = try builder.build()
                    resolve(sendRequest(videoRequest: result))
                    print("Successfully merge", result.id)
                      
                } else {
                    print("Invalid JSON format")
                    reject("json_error", "Invalid JSON format", nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                reject("json_error", "JSON parsing error: \(error.localizedDescription)", error)
            }
            
            
            
        }
        // Print the output path of the merged video
    }
    
    func frameRate(_ frameRateStr: String ) -> TruvideoSdkVideo.TruvideoSdkVideoFrameRate{
        return switch frameRateStr {
        case "twentyFourFps":
                .twentyFourFps
        case "twentyFiveFps":
                .twentyFiveFps
        case "thirtyFps":
                .thirtyFps
        case "fiftyFps":
                .fiftyFps
        case "sixtyFps":
                .sixtyFps
        default :
                .fiftyFps
        }
    }

  @objc public func changeEncoding(video: String,output: String,config :String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // Create a EncodingBuilder instance with specified parameters
        Task{
            let videoUrl = self.convertStringToURL(video)
            let outputUrl = convertStringToURL(output)
            guard let data = config.data(using: .utf8) else {
                print("Invalid JSON string")
                reject("json_error", "Invalid JSON string", nil)
                return
            }
            do {
                if let configuration = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(configuration)
                    guard let widthStr = configuration["width"] as? String, let width = CGFloat(Double(widthStr) ?? 0) as? CGFloat else {
                        print("Width is not a valid string or missing")
                        return
                    }
                    
                    guard let heightStr = configuration["height"] as? String, let height = CGFloat(Double(heightStr) ?? 0) as? CGFloat else {
                        print("Height is not a valid string or missing")
                        return
                    }
                    
                    if let frameRateStr = configuration["framesRate"] as? String{
                        let inputPath : TruvideoSdkVideoFile = .init(url: videoUrl)
                        let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)
                        let builder = TruvideoSdkVideo.EncodingBuilder(input: inputPath, output: outputPath)
                        builder.height = height
                        builder.width = width
                        builder.framesRate = frameRate(frameRateStr)
                        let result = builder.build()
                        
                      resolve(sendRequest(videoRequest: result))
                      print("Successfully concatenated", result.id)
                        
                    } else {
                        print("Invalid JSON format")
                        reject("json_error", "Invalid JSON format", nil)
                    }
                }
            }catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                reject("json_error", "Error parsing JSON", error)
            }
            
        }
    }
  
  func sendRequests(videoRequests: [TruvideoSdkVideo.TruvideoSdkVideoRequest]) -> String {
      var responseArray: [[String: Any]] = []

      for request in videoRequests {
          let jsonString = sendRequest(videoRequest: request)
          if let data = jsonString.data(using: .utf8),
             let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
              responseArray.append(dict)
          }
      }

      do {
          let jsonData = try JSONSerialization.data(withJSONObject: responseArray, options: [])
          if let finalJsonString = String(data: jsonData, encoding: .utf8) {
              print("json array", finalJsonString)
              return finalJsonString
          }
      } catch {
          print("Error serializing requests: \(error)")
      }

      return "[]"
  }


  func sendRequest(videoRequest : TruvideoSdkVideo.TruvideoSdkVideoRequest) -> String{
    let dateFormatter = ISO8601DateFormatter()
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss 'GMT'Z yyyy"
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    var type = videoRequest.type
    var typeString = ""
    if(type == .merge){
      typeString = "merge"
    }else if(type == .concat){
      typeString = "concat"
    }else {
      typeString = "encode"
    }
    var status : String =  switch videoRequest.status {
      case .idle : "idle"
      case .error: "error"
      case .complete: "complete"
      case .processing: "processing"
      case .cancelled: "cancelled"
      default:""
    }
    let mainResponse: [String: Any] = [
      "id": videoRequest.id.uuidString,
      "createdAt" : dateFormatter.string(from: videoRequest.createdAt),
      "status" : status,
      "type" : typeString,
      "updatedAt" : dateFormatter.string(from: videoRequest.updatedAt),
      "outputPath": videoRequest.outputPath?.path as Any,
      "errorMessage": videoRequest.errorMessage as Any
    ]
    print("Received request:", videoRequest)
    do{
      let jsonData = try JSONSerialization.data(withJSONObject: mainResponse, options: [])
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print("json",jsonString)
        return jsonString
      }else{
        return "{}"
      }
    }catch{
      return "{}"
    }
  }
  
    @objc public func getAllRequest(
      status: String,
      resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) {
      var cancellable: AnyCancellable?
      var didFinish = false

      let statusData: TruvideoSdkVideoRequest.Status? = {
        switch status {
        case "idle": return .idle
        case "cancelled": return .cancelled
        case "complete": return .complete
        case "error": return .error
        case "processing": return .processing
        default: return nil
        }
      }()
      
      do {
          // If the SDK supports passing nil to get all, use statusData directly.
          // If not, you may need a separate non-filtered API.
          if(statusData == nil){
              let requests = try TruvideoSdkVideo.getRequests(withStatus: .idle)
              let cancelled = try TruvideoSdkVideo.getRequests(withStatus: .cancelled)
              let complete = try TruvideoSdkVideo.getRequests(withStatus: .complete)
              let errorRequest = try TruvideoSdkVideo.getRequests(withStatus: .error)
              let processingRequest = try TruvideoSdkVideo.getRequests(withStatus: .processing)
              let requestsTotal: [TruvideoSdkVideoRequest] = requests + complete + errorRequest + processingRequest + cancelled 
              let json = self.sendRequests(videoRequests: requestsTotal)
              resolve(json)
          }else{
              let requests = try TruvideoSdkVideo.getRequests(withStatus: statusData ?? .idle)
              let json = self.sendRequests(videoRequests: requests)
              resolve(json)
          }
      } catch {
          reject("GET_REQUESTS_ERROR", "Failed to get requests", error)
      }

//      do {
//        let publisher = TruvideoSdkVideo.streamRequests(withStatus: statusData)
//
//        cancellable = publisher
//          .first() // ⭐ CRITICAL
//          .sink(
//            receiveCompletion: { completion in
//              if didFinish { return }
//              if case .failure(let error) = completion {
//                didFinish = true
//                reject("STREAM_ERROR", error.localizedDescription, error)
//                cancellable = nil
//              }
//            },
//            receiveValue: { videoRequests in
//              if didFinish { return }
//              didFinish = true
//              resolve(self.sendRequests(videoRequests: videoRequests))
//              cancellable = nil
//            }
//          )
//
//      } catch {
//        reject("INIT_ERROR", error.localizedDescription, error)
//      }
    }

  
    @objc public func getRequestById(
      id: String,
      resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) {
      guard let uuid = UUID(uuidString: id) else {
        reject("INVALID_ID", "Invalid UUID", nil)
        return
      }

      var cancellable: AnyCancellable?
      var didFinish = false

      do {
        let publisher = try TruvideoSdkVideo.streamRequest(withId: uuid)

        cancellable = publisher
          .first() // ⭐ REQUIRED
          .sink(
            receiveCompletion: { completion in
              if didFinish { return }
              if case .failure(let error) = completion {
                didFinish = true
                reject("STREAM_ERROR", error.localizedDescription, error)
                cancellable = nil
              }
            },
            receiveValue: { videoRequest in
              if didFinish { return }
              didFinish = true
              resolve(self.sendRequest(videoRequest: videoRequest))
              cancellable = nil
            }
          )

      } catch {
        reject("INIT_ERROR", error.localizedDescription, error)
      }
    }

  
  @objc public func cancel(id : String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
    var cancellables = Set<AnyCancellable>()
    do {
      let publisher = try TruvideoSdkVideo.streamRequest(withId: UUID(uuidString :id) ?? UUID())
        publisher
            .sink { videoRequest in
                // Handle each emitted TruvideoSdkVideoRequest
              do {
                try videoRequest.cancel()
                resolve(self.sendRequest(videoRequest: videoRequest))
                cancellables.removeAll()
              }catch{
                reject("","",nil)
              }
            }
            .store(in: &cancellables)
    } catch {
        // Handle thrown error from streamRequest
        print("Failed to create publisher:", error)
    }
  }
  
//  @objc public func process(id : String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
//    var cancellables = Set<AnyCancellable>()
//    do {
//      let publisher = try TruvideoSdkVideo.streamRequest(withId: UUID(uuidString :id) ?? UUID())
//        publisher
//            .sink { videoRequest in
//                // Handle each emitted TruvideoSdkVideoRequest
//              Task{
//                do {
//                  var data = try await videoRequest.process()
//                  resolve(self.sendRequest(videoRequest: videoRequest))
//                  cancellables.removeAll()
//                }catch{
//                  
//                }
//              }
//            }
//            .store(in: &cancellables)
//    } catch {
//        // Handle thrown error from streamRequest
//        print("Failed to create publisher:", error)
//    }
//  }
    @objc public func process(
      id: String,
      resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) {
      // BREAKPOINT 1: Entry point
      print("🔵 [STEP 1] Starting process for ID: \(id)")
      
      guard let uuid = UUID(uuidString: id) else {
        print("🔴 [ERROR] Invalid UUID: \(id)")
        reject("INVALID_ID", "Invalid UUID", nil)
        return
      }
      
      print("🔵 [STEP 2] UUID validated: \(uuid)")
      
      do {
        let publisher = try TruvideoSdkVideo.streamRequest(withId: uuid)
        print("🔵 [STEP 3] Publisher created successfully")
        
        publisher
          .first()
          .sink(
            receiveCompletion: { completion in
              // BREAKPOINT 2: Completion handler
              print("🔵 [STEP 4] Publisher completion: \(completion)")
              if case .failure(let error) = completion {
                print("🔴 [ERROR] Publisher failed: \(error.localizedDescription)")
                reject("STREAM_ERROR", error.localizedDescription, error)
              }
            },
            receiveValue: { videoRequest in
              // BREAKPOINT 3: Received video request
              print("🔵 [STEP 5] Received video request")
              print("   - ID: \(videoRequest.id)")
              print("   - Status: \(videoRequest.status)")
              print("   - Type: \(videoRequest.type)")
              print("   - Created: \(videoRequest.createdAt)")
              print("   - Updated: \(videoRequest.updatedAt)")
              
              Task {
                do {
                  // BREAKPOINT 4: Before processing
                  print("🔵 [STEP 6] Calling videoRequest.process()...")
                  let processStartTime = Date()
                  
                  try await videoRequest.process()
                  
                  // BREAKPOINT 5: After processing
                  let processDuration = Date().timeIntervalSince(processStartTime)
                  print("🔵 [STEP 7] videoRequest.process() completed in \(processDuration) seconds")
                  
                  // BREAKPOINT 6: Fetching updated status
                  print("🔵 [STEP 8] Fetching updated request status...")
                  let updatedPublisher = try TruvideoSdkVideo.streamRequest(withId: uuid)
                  
                  var cancellable: AnyCancellable?
                  cancellable = updatedPublisher
                    .first()
                    .sink(
                      receiveCompletion: { innerCompletion in
                        print("🔵 [STEP 9] Updated publisher completion: \(innerCompletion)")
                        cancellable = nil
                      },
                      receiveValue: { updatedRequest in
                        // BREAKPOINT 7: Received updated request
                        print("🔵 [STEP 10] Received updated request")
                        print("   - Status after processing: \(updatedRequest.status)")
                        print("   - Updated at: \(updatedRequest.updatedAt)")
                        
                        // BREAKPOINT 8: Converting to JSON
                        print("🔵 [STEP 11] Converting request to JSON response...")
                        let response = self.convertRequestToJSON(videoRequest: updatedRequest)
                        print("🔵 [STEP 12] JSON response: \(response)")
                        
                        // BREAKPOINT 9: Status check
                        switch updatedRequest.status {
                        case .complete:
                          print("✅ [SUCCESS] Video processing completed successfully")
                          resolve(response)
                          
                        case .error:
                          print("🔴 [ERROR] Video processing failed with error status")
                          reject("PROCESS_ERROR", "Video processing failed", nil)
                          
                        case .processing:
                          print("⚠️ [WARNING] Video still processing after process() returned")
                          reject("PROCESS_ERROR", "Video processing incomplete: still processing", nil)
                          
                        case .idle:
                          print("⚠️ [WARNING] Video status is still idle after process()")
                          reject("PROCESS_ERROR", "Video processing incomplete: idle", nil)
                          
                        case .cancelled:
                          print("⚠️ [WARNING] Video processing was cancelled")
                          reject("PROCESS_ERROR", "Video processing was cancelled", nil)
                          
                        @unknown default:
                          print("⚠️ [WARNING] Unknown video status: \(updatedRequest.status)")
                          reject("PROCESS_ERROR", "Video processing incomplete: unknown status", nil)
                        }
                        
                        cancellable = nil
                      }
                    )
                  
                } catch {
                  // BREAKPOINT 10: Catch error
                  print("🔴 [ERROR] Processing exception caught")
                  print("   - Error: \(error)")
                  print("   - Localized: \(error.localizedDescription)")
                  if let nsError = error as NSError? {
                    print("   - Domain: \(nsError.domain)")
                    print("   - Code: \(nsError.code)")
                    print("   - UserInfo: \(nsError.userInfo)")
                  }
                  reject("PROCESS_ERROR", error.localizedDescription, error)
                }
              }
            }
          )
          .store(in: &requestCancellables)
        
      } catch {
        // BREAKPOINT 11: Initial catch
        print("🔴 [ERROR] Failed to create publisher")
        print("   - Error: \(error)")
        print("   - Localized: \(error.localizedDescription)")
        reject("INIT_ERROR", error.localizedDescription, error)
      }
    }
 
    private var requestCancellables = Set<AnyCancellable>()
 
  // MARK: - Helper Method
    private func convertRequestToJSON(videoRequest: TruvideoSdkVideo.TruvideoSdkVideoRequest) -> String {
      print("🔵 [JSON] Converting request to JSON...")
      
      let dateFormatter = ISO8601DateFormatter()
      
      // Convert type enum to string
      let typeString: String
      switch videoRequest.type {
      case .merge:
        typeString = "merge"
      case .concat:
        typeString = "concat"
      default:
        typeString = "encode"
      }
      print("🔵 [JSON] Type: \(typeString)")
      
      // Convert status enum to string
      let statusString: String
      switch videoRequest.status {
      case .idle:
        statusString = "idle"
      case .error:
        statusString = "error"
      case .complete:
        statusString = "complete"
      case .processing:
        statusString = "processing"
      case .cancelled:
        statusString = "cancelled"
      default:
        statusString = ""
      }
      print("🔵 [JSON] Status: \(statusString)")
      
      // Build response dictionary
      let mainResponse: [String: Any] = [
        "id": videoRequest.id.uuidString,
        "createdAt": dateFormatter.string(from: videoRequest.createdAt),
        "status": statusString,
        "type": typeString,
        "updatedAt": dateFormatter.string(from: videoRequest.updatedAt),
        "outputPath": videoRequest.outputPath?.path as Any,
        "errorMessage": videoRequest.errorMessage as Any
      ]
      
      print("🔵 [JSON] Response dictionary: \(mainResponse)")
      
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: mainResponse, options: [])
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
          print("🔵 [JSON] Successfully created JSON string: \(jsonString)")
          return jsonString
        } else {
          print("🔴 [JSON ERROR] Failed to convert data to string")
          return "{}"
        }
        
      } catch {
        print("🔴 [JSON ERROR] JSONSerialization failed: \(error)")
        return "{}"
      }
    }
 
  
  @objc public func editVideo(video : String,output : String,resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        DispatchQueue.main.async{
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
                return
            }
            let videoUrl = self.convertStringToURL(video)
            let outputUrl = self.convertStringToURL(output)
            let inputPath : TruvideoSdkVideoFile = .init(url: videoUrl)
            let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)
            rootViewController.presentTruvideoSdkVideoEditorView(input: inputPath, output: outputPath, onComplete: {editionResult in
              if(editionResult.editedVideoURL != nil){
                resolve(editionResult.editedVideoURL?.path)
                print("Successfully edited", editionResult.editedVideoURL?.path)
              }else{
                resolve("")
                print("Successfully edited", "")
              }
                
            })
        }
    }
}
