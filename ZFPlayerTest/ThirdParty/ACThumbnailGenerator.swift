
//**************這是影片截圖工具**************//

import AVKit
import AVFoundation

public protocol ACThumbnailGeneratorDelegate: AnyObject {
    func generator(_ generator: ACThumbnailGenerator, didCapture image: UIImage, at position: Double)
}

public class ACThumbnailGenerator: NSObject {

    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?

    public weak var delegate: ACThumbnailGeneratorDelegate?

    deinit {
        clear()
    }

    init<vc: UIViewController>(url: URL, vc: vc) where vc: ACThumbnailGeneratorDelegate {
        super.init()
        self.clear()
        self.delegate = vc

        let asset = AVAsset(url: url)
        let keys = ["playable", "tracks", "duration"]
        asset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            guard let `self` = self else { return }
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.preferredPeakBitRate = 0

            DispatchQueue.main.async {
                let settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                self.videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: settings)
                if let videoOutput = self.videoOutput {
                    playerItem.add(videoOutput)
                }
                self.player = AVPlayer(playerItem: playerItem)
            }
        }
    }

    private func clear() {
        if let player = player {
            player.pause()
            if let videoOutput = videoOutput {
                player.currentItem?.remove(videoOutput)
                self.videoOutput = nil
            }
            player.currentItem?.asset.cancelLoading()
            player.cancelPendingPrerolls()
            player.replaceCurrentItem(with: nil)
            self.player = nil
        }
    }

    private func seek(to draggedTime: Double, completionHandler: @escaping () -> Void) {
        let timeScale = self.player?.currentItem?.asset.duration.timescale ?? 0
        let targetTime = CMTimeMakeWithSeconds(draggedTime, preferredTimescale: timeScale)
        if CMTIME_IS_VALID(targetTime) {
            self.player?.seek(to: targetTime, completionHandler: { _ in
                completionHandler()
            })
        }
    }

    public func captureImage(draggedTime: TimeInterval) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.seek(to: draggedTime) { [weak self] in
                guard let `self` = self else { return }
                guard let videoOutput = self.videoOutput, let currentItem = self.player?.currentItem else { return }

                let currentTime = currentItem.currentTime()
                if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                    let ciImage = CIImage(cvPixelBuffer: buffer)
                    let transform = CGAffineTransform(scaleX: 1, y: 1)
                    let output = ciImage.transformed(by: transform)

                    DispatchQueue.main.async {
                        self.delegate?.generator(self, didCapture: UIImage(ciImage: output), at: CMTimeGetSeconds(currentTime))
                    }
                }
            }
        }
    }

    public func seek(to position: Double) {
        let timeScale = self.player?.currentItem?.asset.duration.timescale ?? 0

        let targetTime = CMTimeMakeWithSeconds(position, preferredTimescale: timeScale)
        if CMTIME_IS_VALID(targetTime) {
            self.player?.seek(to: targetTime)
        }
    }
}




//    func generateThumbnail(path: URL, time: Int64) {
//        let asset = AVAsset(url: path)
//        let imgGenerator = AVAssetImageGenerator(asset: asset)
//        imgGenerator.appliesPreferredTrackTransform = true
//        imgGenerator.requestedTimeToleranceAfter = CMTime.zero
//        imgGenerator.requestedTimeToleranceBefore = CMTime.zero
//        var testAry: [NSValue] = []
//        testImageAry = Array(repeating: UIImage(), count: Int(time))
//        for i in 0..<time {
//            testAry.append(NSValue(time: CMTimeMake(value: i, timescale: 1)))
//        }
//
//        imgGenerator.generateCGImagesAsynchronously(forTimes: testAry) { [weak self] requestedTime, image, actualTime, result, error in
//            guard let `self` = self else { return }
//            if let image = image {
//                let thumbnail = UIImage(cgImage: image)
//                self.testImageAry[Int(requestedTime.seconds)] = thumbnail
//                print("🟠suc\(Int(requestedTime.seconds))")
//            } else {
//                print("🟠\(error)")
//            }
//        }
//    }






//func playerDraggedTimeChanged(draggedTime: TimeInterval) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard
//                let videoOutput = self.zfPlayerManager.videoOutput,
//                let currentItem = self.zfPlayerManager.player.currentItem,
//                currentItem.status == .readyToPlay
//                else {
//                return
//            }
//// test2 CMTime(value: 1146232997598, timescale: 1000000000, flags: __C.CMTimeFlags(rawValue: 1), epoch: 0)
////                        let currentTime = currentItem.currentTime()
////                    let currentTime = CMTimeMake(value: 0, timescale: Int32(self.zfPlayerManager.currentTime)
////                    let currentTime = self.zfPlayerManager.playerItem.currentTime()
////                    let currentTime = CMTimeMake(value: Int64(draggedTime), timescale:  600)
////                    let currentTime = CMTimeMakeWithSeconds(draggedTime, preferredTimescale: 600)
////                    let currentTime = CMTimeMake(value: Int64(draggedTime), timescale: 1)
////            let currentTime = CMTimeMake(value: Int64(draggedTime * 1000000000), timescale: 60)
////                let currentTime = CMTime(value: Int64(draggedTime * 1000000000), timescale: 1000000000, flags: CMTimeFlags(rawValue: 1), epoch: 0)
//            let currentTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
//            print("test1 \(draggedTime)")
//            print("test2 \(currentTime)")
//            if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
//                let ciImage = CIImage(cvPixelBuffer: buffer)
//                let transform = CGAffineTransform(scaleX: 1, y: 1)
//                let output = ciImage.transformed(by: transform)
//
//                DispatchQueue.main.async {
//                    self.mView.testImgView.image = UIImage(ciImage: output)
//                }
//            }
//        }
//        guard let url = URL(string: "https://cel.xewall.com/584AD-091/240/ts/584AD-091-34.ts?k=3602b6a60ed14dec66d7134eb44f2f41&t=1658990401") else { return }
//        guard let url = URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") else { return }
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.generateThumbnail(path: url)
//        }
//        self.generator.captureImage(draggedTime: draggedTime)
    
//        let ts = Int(draggedTime / 6.006)
//        guard let url = URL(string: "https://cel.xewall.com/584AD-091/240/ts/584AD-091-35.ts?k=7cd81f5b0acbe6b293e4a3ac7f120229&t=1658990401") else { return }
    
    
    
//        generator = ACThumbnailGenerator(url: url, vc: self)
//        generator.captureImage(draggedTime: draggedTime)
    
    
//        guard testImageAry.count > draggedTime + 1 else { return }
//            self.mView.testImgView.image = testImageAry[Int(draggedTime)]
//}





//public class ACThumbnailGenerator: NSObject {
//    private(set) var preferredBitrate: Double
//    private(set) var streamUrl: URL
//    private(set) var queue: [Double] = []
//
//    private var player: AVPlayer?
//    private var videoOutput: AVPlayerItemVideoOutput?
//
//    var loading = false
//    public weak var delegate: ACThumbnailGeneratorDelegate?
//
//    public init(streamUrl: URL, preferredBitrate: Double = 0.0) {
//        self.streamUrl = streamUrl
//        self.preferredBitrate = preferredBitrate
//    }
//
//    deinit {
//        clear()
//    }
//
//    private func prepare(completionHandler: @escaping () -> Void) {
//        let asset = AVAsset(url: streamUrl)
//        let keys = ["playable", "tracks", "duration"]
//        asset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
//            let playerItem = AVPlayerItem(asset: asset)
//            playerItem.preferredPeakBitRate = self?.preferredBitrate ?? 1000000
//
//            DispatchQueue.main.async {
//                let settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
//                self?.videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: settings)
//                if let videoOutput = self?.videoOutput {
//                    playerItem.add(videoOutput)
//                }
//
//                self?.player = AVPlayer(playerItem: playerItem)
//                self?.player?.currentItem?.addObserver(self!, forKeyPath: "status", options: [], context: nil)
//
//                completionHandler()
//            }
//        }
//    }
//
//    private func clear() {
//        if let player = player {
//            player.currentItem?.removeObserver(self, forKeyPath: "status")
//            player.pause()
//            if let videoOutput = videoOutput {
//                player.currentItem?.remove(videoOutput)
//                self.videoOutput = nil
//            }
//            player.currentItem?.asset.cancelLoading()
//            player.cancelPendingPrerolls()
//            player.replaceCurrentItem(with: nil)
//            self.player = nil
//        }
//    }
//
//    public func replaceStreamUrl(newUrl url: URL) {
//        streamUrl = url
//        clear()
//    }
//
//    public func captureImage(at position: Double) {
//        guard !loading else {
//            // If loading, queue new request
//            if let index = queue.firstIndex(of: position) {
//                queue.remove(at: index)
//            }
//            queue.append(position)
//            return
//        }
//        loading = true
//
//        if player == nil {
//            prepare { [weak self] in
//                self?.seek(to: position)
//            }
//        }
//        else {
//            seek(to: position)
//        }
//    }
//
//    public func seek(to position: Double) {
//        let timeScale = self.player?.currentItem?.asset.duration.timescale ?? 0
//
//        let targetTime = CMTimeMakeWithSeconds(position, preferredTimescale: timeScale)
//        if CMTIME_IS_VALID(targetTime) {
//            self.player?.seek(to: targetTime)
//        }
//    }
//
//    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        guard
//            let videoOutput = self.videoOutput,
//            let currentItem = self.player?.currentItem,
//            currentItem.status == .readyToPlay
//            else {
//            return
//        }
//
//        let currentTime = currentItem.currentTime()
//
////        let assetImageGenerator = AVAssetImageGenerator(asset: currentItem.asset)
////        assetImageGenerator.appliesPreferredTrackTransform = true
////        let times = [NSValue(time: currentTime)]
////        assetImageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { [weak self] _, image, _, reault, error in
////            guard let `self` = self else { return }
////            if let image = image {
////                let uiImage = UIImage(cgImage: image)
////                self.delegate?.generator(self, didCapture: uiImage, at: CMTimeGetSeconds(currentTime))
////
////                self.loading = false
////
////                // Capture the next position in the queue
////                if !self.queue.isEmpty {
////                    let position = self.queue.removeFirst()
////                    self.captureImage(at: position)
////                }
////            } else {
////                print("error")
////            }
////        })
//
//
//
//        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
//            delegate?.generator(self, didCapture: bb(buffer: buffer), at: CMTimeGetSeconds(currentTime))
//
//            loading = false
//
//            // Capture the next position in the queue
//            if !queue.isEmpty {
//                let position = queue.removeFirst()
//                captureImage(at: position)
//            }
//        }
//    }
//
//    func bb(buffer: CVPixelBuffer) -> UIImage {
//        let ciImage = CIImage(cvPixelBuffer: buffer)
//        let transform = CGAffineTransform(scaleX: 1, y: 1)
//        let output = ciImage.transformed(by: transform)
//        return UIImage(ciImage: output)
//    }
//}





//public class ACThumbnailGenerator: NSObject {
//
//    private var zfPlayerManager: ZFAVPlayerManager = ZFAVPlayerManager()
//
//    public weak var delegate: ACThumbnailGeneratorDelegate?
//
//    deinit {
//        clear()
//    }
//
//    init<vc: UIViewController>(manager: ZFAVPlayerManager, vc: vc) where vc: ACThumbnailGeneratorDelegate {
//        super.init()
//        self.clear()
//        self.zfPlayerManager = manager
//        self.delegate = vc
//    }
//
//    private func clear() {
//        if let player = zfPlayerManager.player {
//            player.pause()
//            player.currentItem?.asset.cancelLoading()
//            player.cancelPendingPrerolls()
//            player.replaceCurrentItem(with: nil)
//            self.zfPlayerManager.stop()
//        }
//    }
//
//    public func seek(to draggedTime: Double, completionHandler: @escaping () -> Void) {
//        let timeScale = self.zfPlayerManager.player.currentItem?.asset.duration.timescale ?? 0
//
//        let targetTime = CMTimeMakeWithSeconds(draggedTime, preferredTimescale: timeScale)
//        if CMTIME_IS_VALID(targetTime) {
//            self.zfPlayerManager.player.seek(to: targetTime)
//            completionHandler()
//        }
//    }
//
//    public func captureImage(draggedTime: TimeInterval) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.seek(to: draggedTime) { [weak self] in
//                guard let `self` = self else { return }
//                guard let videoOutput = self.zfPlayerManager.videoOutput, let currentItem = self.zfPlayerManager.player.currentItem else { return }
//
//                let currentTime = currentItem.currentTime()
//                if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
//                    let ciImage = CIImage(cvPixelBuffer: buffer)
//                    let transform = CGAffineTransform(scaleX: 1, y: 1)
//                    let output = ciImage.transformed(by: transform)
//
//                    DispatchQueue.main.async {
//                        self.delegate?.generator(self, didCapture: UIImage(ciImage: output), at: CMTimeGetSeconds(currentTime))
//                    }
//                }
//            }
//        }
//    }
//}
