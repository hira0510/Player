//
// InHand
// UITabBarItemExtension 建立時間：2019/11/12 4:00 PM
//
// 使用的Swift版本：5.0
//
//


import Foundation
import Kingfisher
import Alamofire

extension UITabBarItem {

    /// 下載base64的圖片
    /// - Parameter url: 圖片url
    /// - Parameter placeholder: 載不到圖時的預設圖
    /// - Parameter options: 下載時的轉場效果等
    /// - Parameter completionHandler: 內部請求後的狀態
    func loadBase64Image(url: String, placeholder: UIImage? = nil, options: KingfisherOptionsInfo?, completionHandler: CompletionHandler? = nil) {
        
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
                        UIImageView().kf.setImage(with: provider, placeholder: placeholder, options: options, progressBlock: nil) { (result) in
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

        UIImageView().kf.setImage(with: urls, placeholder: placeholder, options: options, progressBlock: nil) { [weak self] (result) in
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
                            let provider = Base64ImageDataProviders(base64String: unwrap(base64String, ""), cacheKey: url)
                            DispatchQueue.main.async {
                                UIImageView().kf.setImage(with: provider, placeholder: placeholder, options: options, progressBlock: nil) { (result) in
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

        UIImageView().kf.setImage(with: urls, placeholder: placeholder, options: options, progressBlock: nil) { [weak self] (result) in
            guard let `self` = self else { return }
            completionHandler?(result)

            if let image = try? result.get().image {
                self.image = image
            } else {
                self.image = placeholder
            }
        }
    }
}
