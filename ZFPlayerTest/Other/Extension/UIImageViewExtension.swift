//
// avnight
// UIImageViewExtension 建立時間：2019/8/2 11:11 AM
//
// 使用的Swift版本：5.0
//
// Copyright © 2019 com. All rights reserved.


import Foundation
import Kingfisher
import Alamofire

enum ErrorType {
    case urlStringEmpty
    case dataDownloadFailure
    case dataEmpty
    case imgInDisk
    case dataTransferStrFailure
    case dataTransferImgFailure
    case dataTransferImgSuccess
}

typealias CompletionHandler = (_ image: UIImage?, _ error: ErrorType?, _ imageURL: URL?) -> ()

typealias CompletionHandlers = (_ result: Swift.Result<RetrieveImageResult, KingfisherError>) -> ()


extension UIImageView {

    /// 下載base64的圖片
    /// - Parameter url: 圖片url
    /// - Parameter placeholder: 載不到圖時的預設圖
    /// - Parameter options: 下載時的轉場效果等
    /// - Parameter completionHandler: 內部請求後的狀態
    func loadBase64Image(url: String, placeholder: UIImage? = nil, options: KingfisherOptionsInfo?, completionHandler: CompletionHandler?) {
        
        guard let urls = URL(string: url) else {
            DispatchQueue.main.async {
                self.image = placeholder
            }
            completionHandler?(nil, .urlStringEmpty, nil)
            return
        }
        
        let setImageError: (URL) -> () = { [weak self] (urls) in
            guard let `self` = self else { return }
            AF.request(urls).responseString { (response) in
                switch response.result {
                case .success(let success):

                    let base64 = success.substring(from: 1)
                    let provider = Base64ImageDataProviders(base64String: base64, cacheKey: url)

                    DispatchQueue.main.async {
                        self.kf.setImage(with: provider, placeholder: placeholder, options: options, progressBlock: nil) { (result) in
                            switch result {
                            case .success(let success):
                                self.image = success.image
                                completionHandler?(success.image, .dataTransferImgSuccess, urls)
                            case .failure:
                                self.image = placeholder
                                completionHandler?(nil, .dataTransferImgFailure, urls)
                            }
                        }
                    }
                case .failure:
                    self.image = placeholder
                    completionHandler?(nil, .dataDownloadFailure, urls)
                }
            }
        }

        self.kf.setImage(with: urls, placeholder: placeholder, options: options, progressBlock: nil) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let success):
                self.image = success.image
                completionHandler?(success.image, .imgInDisk, urls)
            case .failure(let error):
                self.image = placeholder
                
                switch error {
                case .processorError(let reason):
                    switch reason {
                    case .processingFailed(_, let item):
                        switch item {
                        case .data(let data):
                            let dataString = String(data: data, encoding: .utf8)
                            let base64String = dataString?.substring(from: 1)
                            let provider = Base64ImageDataProviders(base64String: base64String ?? "", cacheKey: url)
                            DispatchQueue.main.async {
                                self.kf.setImage(with: provider, placeholder: placeholder, options: options, progressBlock: nil) { (result) in
                                    switch result {
                                    case .success(let success):
                                        self.image = success.image
                                        completionHandler?(success.image, .dataTransferImgSuccess, urls)
                                    case .failure:
                                        self.image = placeholder
                                        completionHandler?(nil, .dataTransferImgFailure, urls)
                                    }
                                }
                            }
                        default: setImageError(urls)
                        }
                    }
                default: setImageError(urls)
                }
            }
        }
    }

    /// kingfisherf下載圖片
    /// - Parameter url: 圖片url
    /// - Parameter placeholder: 載不到圖時的預設圖
    /// - Parameter options: 下載時的轉場效果等
    /// - Parameter completionHandler: 內部請求後的狀態
    func loadImage(url: String, placeholder: UIImage? = nil, options: KingfisherOptionsInfo?, completionHandler: CompletionHandlers?) {

        guard let urls = URL(string: url) else {
            DispatchQueue.main.async {
                self.image = placeholder
            }
            return
        }

        self.kf.setImage(with: urls, placeholder: placeholder, options: options, progressBlock: nil) { (result) in
            completionHandler?(result)
        }
    }

    func cancelRepeatDownload(url: String) {
        guard let urls = URL(string: url) else { return }

        KingfisherManager.shared.downloader.cancel(url: urls)
        Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, sessionUploadTask, sessionDownloadTask) in
            sessionDataTask.forEach {
                if unwrap($0.currentRequest?.url?.absoluteString, "") == url {
                    $0.cancel()
                }
            }
            sessionUploadTask.forEach {
                if unwrap($0.currentRequest?.url?.absoluteString, "") == url {
                    $0.cancel()
                }
            }
            sessionDownloadTask.forEach {
                if unwrap($0.currentRequest?.url?.absoluteString, "") == url {
                    $0.cancel()
                }
            }
        }
    }

    /// url轉換成QRCode
    ///
    /// - Parameter urlString: String的url
    func generateQRCode(from urlString: String) {
        let data = urlString.data(using: String.Encoding.utf8)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            // L: 7%, M: 15%, Q: 25%, H: 30%  ％越高圖檔越大 容錯率越高
            filter.setValue("M", forKey: "inputCorrectionLevel")

            if let qrImage = filter.outputImage {
                let scaleX = self.frame.size.width / qrImage.extent.size.width
                let scaleY = self.frame.size.height / qrImage.extent.size.height
                let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                let output = qrImage.transformed(by: transform)
                self.image = UIImage(ciImage: output)
            }
        }
    }
    
    /// loadGIF圖檔
    /// - Parameter name: GIF圖片名 ex: cat(cat.gif)
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}


public struct Base64ImageDataProviders: ImageDataProvider {

    public let base64String: String

    public init(base64String: String, cacheKey: String) {
        self.base64String = base64String
        self.cacheKey = cacheKey
    }

    public var cacheKey: String

    public func data(handler: (Swift.Result<Data, Error>) -> Void) {
        if let data = Data(base64Encoded: base64String) {
            handler(.success(data))
        }
    }
}
