//
//  VideoCreator.swift
//  FloatingClock
//
//  Created by wl on 2020/12/18.
//

import Foundation
import AVFoundation


//https://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie/3742212#3742212
class VideoCreator {
    func create() {
        //1.Wire the writer:
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  else {
            return
        }
        url.appendPathComponent("temp.mov")
        
        guard let videoWrite = try? AVAssetWriter(url: url, fileType: .mov) else {
            return
        }
        
        let videoSettings: [String : Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 640,
            AVVideoHeightKey: 360,
        ]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        guard  videoWrite.canAdd(writerInput) else {
            return
        }
        videoWrite.add(writerInput)
        print(url)
        
        // 2.start session
        videoWrite.startWriting()
        videoWrite.startSession(atSourceTime: .zero)
        
        //3. empty buffer
        writerInput.append(getCMSampleBuffer())
        
        //4. finish session
        writerInput.markAsFinished()
        videoWrite.finishWriting {
            print(videoWrite.status)
        }
        
        
    }
    
    fileprivate func getCMSampleBuffer() -> CMSampleBuffer {
        var pixelBuffer : CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, 640, 360, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)

        var info = CMSampleTimingInfo()
        info.presentationTimeStamp = CMTime.zero
        info.duration = CMTime(value: 60, timescale: 600)
        info.decodeTimeStamp = CMTime.invalid


        var formatDesc: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, formatDescriptionOut: &formatDesc)

        var sampleBuffer: CMSampleBuffer? = nil

        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                 imageBuffer: pixelBuffer!,
                                                 formatDescription: formatDesc!,
                                                 sampleTiming: &info,
                                                 sampleBufferOut: &sampleBuffer);

        return sampleBuffer!
    }
}
