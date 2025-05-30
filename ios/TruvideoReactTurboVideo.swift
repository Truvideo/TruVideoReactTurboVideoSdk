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
              let urlArray: [URL] = [convertStringToURL(videos)]
              var inputUrl : [TruvideoSdkVideoFile] = []
              for url in urlArray {
                  inputUrl.append(.init(url: url))
              }
              let result = try await TruvideoSdkVideo.getVideosInformation(input: inputUrl)
              let dictionaryResult = result.map { videoInfo in
                  return [
                      "path": videoInfo.path,
                      "size": videoInfo.size,
                      "durationMillis": videoInfo.durationMillis,
                      "format": videoInfo.format,
                      "videos": videoInfo.videos.map { video in
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
                      "audios": videoInfo.audios.map { audio in
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
                  ] as [String: Any]
              }
              resolve(dictionaryResult)
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
                    resolve(thumbnail.generatedThumbnailURL.absoluteString)
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
                resolve(result.fileURL.absoluteString)
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
                let result = builder.build()
                do{
                    let response = try await result.process()
                    resolve(response.videoURL.absoluteString)
                    print("Successfully concatenated", response.videoURL.absoluteString)
                }catch let error {
                    print(error.localizedDescription)
                    reject("Concat_error", error.localizedDescription, error)
                }
                
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
                    guard let frameRateStr = configuration["framesRate"] as? String,
                          let videoCodec = configuration["videoCodec"] as? String else {
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
                    let result = builder.build()
                    do {
                        if let output = try? await result.process() {
                            resolve(output.videoURL.absoluteString)
                            await print("Successfully merge", output.videoURL.absoluteString ?? "")
                        }

                    } catch {
                        reject("process_error", "Failed to process video merge: \(error.localizedDescription)", error)
                    }
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
                    
                    if let frameRateStr = configuration["framesRate"] as? String, let videoCodec = configuration["videoCodec"]{
                        let inputPath : TruvideoSdkVideoFile = .init(url: videoUrl)
                        let outputPath :TruvideoSdkVideoFileDescriptor = .custom(rawPath: outputUrl.absoluteString)
                        let builder = TruvideoSdkVideo.EncodingBuilder(input: inputPath, output: outputPath)
                        builder.height = height
                        builder.width = width
                        builder.framesRate = frameRate(frameRateStr)
                        let result = builder.build()
                        do{
                            let output = try? await result.process()
                            resolve(output?.videoURL.absoluteString)
                            await print("Successfully concatenated", output?.videoURL.absoluteString)
                        }
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
                resolve(editionResult.editedVideoURL?.absoluteString)
                print("Successfully edited", editionResult.editedVideoURL?.absoluteString)
            })
        }
    }
}

