//
//  VideoCompositing.swift
//  FloatingClock
//
//  Created by wl on 2020/12/16.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit

class TimeVideoComposition: NSObject, AVVideoCompositing {
    
    //https://developer.apple.com/documentation/avfoundation/avvideocompositing/1388610-sourcepixelbufferattributes?language=objc
    var sourcePixelBufferAttributes: [String : Any]? = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
    var requiredPixelBufferAttributesForRenderContext: [String : Any] =  [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
    
    /// Set if all pending requests have been cancelled.
    var shouldCancelAllRequests = false
    /// Dispatch Queue used to issue custom compositor rendering work requests.
    private var renderingQueue = DispatchQueue(label: "com.hzjuzhi.Floating.renderingqueue")
    /// Dispatch Queue used to synchronize notifications that the composition will switch to a different render context.
    private var renderContextQueue = DispatchQueue(label: "com.hzjuzhi.Floating.rendercontextqueue")
    /// The current render context within which the custom compositor will render new output pixels buffers.
    private var renderContext: AVVideoCompositionRenderContext?
    /// Maintain the state of render context changes.
    private var internalRenderContextDidChange = false
    /// Actual state of render context changes.
    private var renderContextDidChange: Bool {
        get {
            return renderContextQueue.sync { internalRenderContextDidChange }
        }
        set (newRenderContextDidChange) {
            renderContextQueue.sync { internalRenderContextDidChange = newRenderContextDidChange }
        }
    }
    
    
    
    // MARK: AVVideoCompositing protocol functions
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContextQueue.sync { renderContext = newRenderContext }
        renderContextDidChange = true
    }
    
    enum PixelBufferRequestError: Error {
        case newRenderedPixelBufferForRequestFailure
    }
    
    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
        autoreleasepool {
            renderingQueue.async {
                // Check if all pending requests have been cancelled.
                if self.shouldCancelAllRequests {
                    asyncVideoCompositionRequest.finishCancelledRequest()
                } else {
                    guard let resultPixels =
                            self.newRenderedPixelBufferForRequest(asyncVideoCompositionRequest) else {
                        asyncVideoCompositionRequest.finish(with: PixelBufferRequestError.newRenderedPixelBufferForRequestFailure)
                        return
                    }
                    
                    // The resulting pixelbuffer from Metal renderer is passed along to the request.
                    asyncVideoCompositionRequest.finish(withComposedVideoFrame: resultPixels)
                }
            }
        }
    }
    
    func newRenderedPixelBufferForRequest(_ request: AVAsynchronousVideoCompositionRequest) -> CVPixelBuffer? {
        guard renderContext?.newPixelBuffer() != nil else {
            return nil
        }
        
        guard let renderContext = renderContext else {
            return nil
        }
        
        guard let instruction =  request.videoCompositionInstruction as? TimeVideoCompositionInstruction else {
            return nil
        }
        
        return instruction.getPixelBuffer(renderContext)
    }
}

