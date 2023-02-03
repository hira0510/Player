//
// avnight
// UIButtonExtension 建立時間：2019/11/14 3:16 PM
//
// 使用的Swift版本：5.0
//
// Copyright © 2019 com. All rights reserved.


import Foundation
import Kingfisher
import Alamofire


extension UIButton {

    /// +下底線
    func underline() {
        if let textString = self.titleLabel?.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: textString.count))
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    /// 下載base64的圖片
    /// - Parameter url: 圖片url
    /// - Parameter placeholder: 載不到圖時的預設圖
    /// - Parameter options: 下載時的轉場效果等
    /// - Parameter completionHandler: 內部請求後的狀態
    func loadBase64Image(url: String, placeholder: UIImage? = nil, options: KingfisherOptionsInfo?, completionHandler: CompletionHandler? = nil) {

        guard let urls = URL(string: url) else {
            DispatchQueue.main.async {
                self.setImage(placeholder, for: .normal)
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
                                self.setImage(success.image, for: .normal)
                                completionHandler?(success.image, .dataTransferImgSuccess, urls)
                            case .failure:
                                self.setImage(placeholder, for: .normal)
                                completionHandler?(nil, .dataTransferImgFailure, urls)
                            }
                        }
                    }
                case .failure:
                    self.setImage(placeholder, for: .normal)
                    completionHandler?(nil, .dataDownloadFailure, urls)
                }
            }
        }

        UIImageView().kf.setImage(with: urls, placeholder: placeholder, options: options, progressBlock: nil) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let success):
                self.setImage(success.image, for: .normal)
                completionHandler?(success.image, .imgInDisk, urls)
            case .failure(let error):
                self.setImage(placeholder, for: .normal)
                
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
                                UIImageView().kf.setImage(with: provider, placeholder: placeholder, options: options, progressBlock: nil) { (result) in
                                    switch result {
                                    case .success(let success):
                                        self.setImage(success.image, for: .normal)
                                        completionHandler?(success.image, .dataTransferImgSuccess, urls)
                                    case .failure:
                                        self.setImage(placeholder, for: .normal)
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
                self.setImage(placeholder, for: .normal)
            }
            return
        }

        UIImageView().kf.setImage(with: urls, placeholder: placeholder, options: options, progressBlock: nil) { [weak self] (result) in
            guard let `self` = self else { return }
            completionHandler?(result)
            if let image = try? result.get().image {
                self.setImage(image, for: .normal)
            } else {
                self.setImage(placeholder, for: .normal)
            }
        }
    }
}
