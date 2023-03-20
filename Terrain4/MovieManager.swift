//
//  MovieManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/20/23.
//

import Foundation
import AVFoundation
import CoreImage

class MovieManager {
    static var shared = MovieManager()
    
    var outputMovieURL: URL?
    var pixelBuffer: CVPixelBuffer?
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var assetWriterAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    var width = 0
    var height = 0
    
    var frameCount = 0
    var framesPerSecond = 30
    var totalFrames = 0
    
    var context: CIContext?
    
    var recording = false
    
    func startMovieCreation(width: Int, height: Int, duration: Int) throws {
        //generate a file url to store the video. some_image.jpg becomes some_image.mov
        guard let imageNameRoot = "Test.mov".split(separator: ".").first else {
            throw Errors.invalidURL
        }
        
        outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(imageNameRoot).mov")
        
        guard let outputMovieURL = outputMovieURL else {
            throw Errors.invalidURL
        }
        
        //delete any old file
        do {
          try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
          print("Could not remove file \(error.localizedDescription)")
        }
        
        //create an assetwriter instance
        assetWriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov)
        
        guard let assetWriter = assetWriter else {
          abort()
        }
        
        self.width = width
        self.height = height
        
        createPixelBuffer(width: width, height: height)
        
        let assetWriterSettings = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey : width, AVVideoHeightKey: height] as [String : Any]

        //create a single video input
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: assetWriterSettings)
        
        guard let assetWriterInput = assetWriterInput else {
            throw Errors.invalidAssetWriterInput
        }
        
        //create an adaptor for the pixel buffer
        assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        
        //add the input to the asset writer
        assetWriter.add(assetWriterInput)
        
        //begin the session
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        //determine how many frames we need to generate
        framesPerSecond = 30
        
        totalFrames = duration * framesPerSecond
        frameCount = 0
        
        context = CIContext()
        
        recording = true
    }
    
    func createPixelBuffer(width: Int, height: Int) {
        //set some standard attributes
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary

        //create a buffer (notice it uses an in/out parameter for the pixelBuffer variable)
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
    }
    
    func scaleImage(image: CIImage) -> CIImage? {
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")!
        let targetSize = NSSize(width: width, height: height)

        let scale = targetSize.height / (image.extent.height)

        resizeFilter.setValue(image, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)

        return resizeFilter.outputImage
    }
    
    func addFrame(image: CGImage, action: @escaping  () -> Void) {
        if let context = context, let pixelBuffer = pixelBuffer {
            let ciImage = CIImage(cgImage: image)
            
            if let ciImage = scaleImage(image: ciImage) {
                
                context.render(ciImage, to: pixelBuffer)
                
                if assetWriterInput?.isReadyForMoreMediaData ?? false {
                    let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
                    //append the contents of the pixelBuffer at the correct time
                    assetWriterAdaptor?.append(pixelBuffer, withPresentationTime: frameTime)
                    frameCount+=1
                }
                
                if frameCount > totalFrames {
                    finishMovieCreation()
                    action()
                }
            }
        }
    }
    
    func finishMovieCreation() {
        //close everything
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting {
            self.pixelBuffer = nil
            
            //outputMovieURL now has the video
            print("Finished video location: \(self.outputMovieURL?.absoluteString ?? "Unknown")")
        }
        
        recording = false
    }
}
