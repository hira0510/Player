//
//  UINib+Extensions.swift
//  CkNovelPop
//
//  Created by John on 2017/5/2.
//  Copyright © 2017年 John. All rights reserved.
//


import UIKit
import ImageIO
import Foundation

public func unwrap<T>(_ lhs: T?, _ rhs: T) -> T {
    if let unwrappedLhs = lhs {
        return unwrappedLhs
    }
    return rhs
}

public func unwrapData<T>(_ body: Any?,_ initData: T) -> T {
    if let data = body as? T {
        return data
    }
    return initData
}

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}
extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    func register<T: UITableViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
    
    func reloadWithoutAnimation() {
        let lastScrollOffset = contentOffset
        reloadData()
        layoutIfNeeded()
        setContentOffset(lastScrollOffset, animated: false)
    }
}
extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }
    
    func register<T: UICollectionViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }
    
    func register<T: UICollectionReusableView>(reusableViewType: T.Type, of kind: String = UICollectionView.elementKindSectionHeader) {
        let className = reusableViewType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
    
    func register<T: UICollectionReusableView>(reusableViewTypes: [T.Type], kind: String = UICollectionView.elementKindSectionHeader) {
        reusableViewTypes.forEach { register(reusableViewType: $0, of: kind) }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as! T
    }
    
    func dequeueReusableView<T: UICollectionReusableView>(with type: T.Type, for indexPath: IndexPath, of kind: String = UICollectionView.elementKindSectionHeader) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.className, for: indexPath) as! T
    }
}
extension UINavigationController {
    func pushToViewController(_ viewController: UIViewController, animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    func popViewController(animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }

    func popToViewController(_ viewController: UIViewController, animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated:Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
extension UIView {
    func removeAllSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
extension UIColor {
    static func colorWithRGBValue(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
extension Date {
    
    //取得 timestep 取到毫秒
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 ) * 1_000)
    }
    
    func toString(formater: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formater
        dateFormatter.locale = Locale(identifier: "zh_TW")
        return  dateFormatter.string(from: self)
    }
    
    
    func offsetFrom(date:Date) -> String {
        
        let difference = Calendar.current.dateComponents([.day , .hour, .minute, .second], from: date, to: self)
        let second = "剛剛"
        let minutes = "\(difference.minute!)分鐘前"
        let hours = "\(difference.hour!)小時前"
        let days = date.toString(formater: "yyyy-MM-dd")
        
        if difference.day! > 0 { return days }
        if difference.hour!   > 0 { return hours }
        if difference.minute! > 0 { return minutes }
        if difference.second! > 0 { return second }
        return ""
    }
    
}
extension UIApplication {
    var topViewController: UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    var topNavigationController: UINavigationController? {
        return topViewController as? UINavigationController
    }
    
    class func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFl") {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBeforeFl")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}

extension UIAlertController {
    
    func addAction(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        let okAction = UIAlertAction(title: title, style: style, handler: handler)
        addAction(okAction)
        return self
    }
    
    func addActionWithTextFields(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction, [UITextField]) -> Void)? = nil) -> Self {
        let okAction = UIAlertAction(title: title, style: style) { [weak self] action in
            handler?(action, unwrap(self?.textFields, []))
        }
        addAction(okAction)
        return self
    }
    
    func configureForIPad(sourceRect: CGRect, sourceView: UIView? = nil) -> Self {
        popoverPresentationController?.sourceRect = sourceRect
        if let sourceView = UIApplication.shared.topViewController?.view {
            popoverPresentationController?.sourceView = sourceView
        }
        return self
    }
    
    func configureForIPad(barButtonItem: UIBarButtonItem) -> Self {
        popoverPresentationController?.barButtonItem = barButtonItem
        return self
    }
    
    func addTextField(handler: @escaping (UITextField) -> Void) -> Self {
        addTextField(configurationHandler: handler)
        return self
    }
    
    func show() {
        UIApplication.shared.topViewController?.present(self, animated: true, completion: nil)
    }
}

extension UIImage {
    
    /// 更改圖片大小
    func reSizeImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        UIGraphicsBeginImageContextWithOptions(reSize,false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage!
    }
    
    //取用GIF方法
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = unwrap(delayObject as? Double, 0)
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
            delays.append(Int(delaySeconds * 500.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        
        for i in 0..<count {
            
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
    
}
extension TimeZone {
    
    static let utc = TimeZone(abbreviation: "UTC")
    
}
extension DateFormatter {
    
    class func create() -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = Constant.dateFormat
        formatter.timeZone = .utc
        
        return formatter
        
    }
    
}
struct Constant {
    
    static let appName = NSLocalizedString("YouBike", comment: "")
    
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
}
extension UIView {
    
    //UIView 動畫速度
    static let ANIMATION_DURATION_EXIT = 0.5
    static let ANIMATION_DURATION_SLOW = 0.6
    static let ANIMATION_DURATION_FAST = 0.2
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    /// The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }
    
}
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":                 return "iPhone 8"
        case "iPhone10,2","iPhone10,5":                 return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE 2nd Gen"
        case "iPhone13,1":                              return "iPhone 12 Mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
        case "iPhone14,2":                              return "iPhone 13 Pro"
        case "iPhone14,3":                              return "iPhone 13 Pro Max"
        case "iPhone14,4":                              return "iPhone 13 Mini"
        case "iPhone14,5":                              return "iPhone 13"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    var isLessIPhone5S : Bool {
        
        switch UIDevice().modelName {
        case "iPhone 4" , "iPhone 4s" , "iPhone 5" , "iPhone 5c" ,"iPhone 5s" , "iPhone SE" :
            return true
        default : break
        }
        return false
    }
    
    var isAboveIPhoneX: Bool {
        switch UIDevice().modelName {
        case "iPhone X", "iPhone XS", "iPhone XS Max", "iPhone XR", "iPhone 11", "iPhone 11 Pro", "iPhone 11 Pro Max", "iPhone 12 Mini", "iPhone 12", "iPhone 12 Pro", "iPhone 12 Pro Max", "iPhone 13 Mini", "iPhone 13", "iPhone 13 Pro", "iPhone 13 Pro Max":
            return true
        default : break
        }
        return false
    }
    
    var isLessIPhone7: Bool {
        switch UIDevice().modelName {
        case "iPhone 7", "iPhone 7 Plus", "iPhone 8", "iPhone 8 Plus", "iPhone X", "iPhone XS", "iPhone XS Max", "iPhone XR", "iPhone 11", "iPhone 11 Pro", "iPhone 11 Pro Max", "iPhone 12 Mini", "iPhone 12", "iPhone 12 Pro", "iPhone 12 Pro Max", "iPhone 13 Mini", "iPhone 13", "iPhone 13 Pro", "iPhone 13 Pro Max":
            return true
        default : break
        }
        return false
    }
    
    /// 是不是iPhoneX以上的機型
    ///
    /// - Returns: 回傳布林
    func isiPhoneXDevice() -> Bool {
        return UIScreen.main.bounds.height >= 812 ? true : false
    }
    
    /// 手機剩餘空間Bytes
    var freeDiskSpaceInBytes: Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    /// 手機剩餘空間Str(GB)
    var freeDiskSpaceInGB: String {
        let bytes = freeDiskSpaceInBytes
        if (bytes < 1000) { return "\(bytes)B" }
            let exp = Int(log2(Double(bytes)) / log2(1000.0))
            let unit = ["K", "M", "G", "T", "P", "E"][exp - 1]
            let number = Double(bytes) / pow(1000, Double(exp))
            return String(format: "%.1f%@", number, unit)
    }
}

public extension UserDefaults {
    class Proxy {
        fileprivate let defaults: UserDefaults
        fileprivate let key: String
        
        fileprivate init(_ defaults: UserDefaults, _ key: String) {
            self.defaults = defaults
            self.key = key
        }
        
        // MARK: Getters
        
        public var object: Any? {
            return defaults.object(forKey: key)
        }
        
        public var string: String? {
            return defaults.string(forKey: key)
        }
        
        public var array: [Any]? {
            return defaults.array(forKey: key)
        }
        
        public var dictionary: [String: Any]? {
            return defaults.dictionary(forKey: key)
        }
        
        public var data: Data? {
            return defaults.data(forKey: key)
        }
        
        public var date: Date? {
            return object as? Date
        }
        
        public var number: NSNumber? {
            return defaults.numberForKey(key)
        }
        
        public var int: Int? {
            return number?.intValue
        }
        
        public var double: Double? {
            return number?.doubleValue
        }
        
        public var bool: Bool? {
            return number?.boolValue
        }
        
        // MARK: Non-Optional Getters
        
        public var stringValue: String {
            return unwrap(string, "")
        }
        
        public var arrayValue: [Any] {
            return unwrap(array, [])
        }
        
        public var dictionaryValue: [String: Any] {
            return unwrap(dictionary, [:])
        }
        
        public var dataValue: Data {
            return unwrap(data, Data())
        }
        
        public var numberValue: NSNumber {
            return unwrap(number, 0)
        }
        
        public var intValue: Int {
            return unwrap(int, 0)
        }
        
        public var doubleValue: Double {
            return unwrap(double, 0)
        }
        
        public var boolValue: Bool {
            return unwrap(bool, false)
        }
    }
    
    /// `NSNumber` representation of a user default
    
    func numberForKey(_ key: String) -> NSNumber? {
        return object(forKey: key) as? NSNumber
    }
    
    /// Returns getter proxy for `key`
    
    subscript(key: String) -> Proxy {
        return Proxy(self, key)
    }
    
    /// Sets value for `key`
    
    subscript(key: String) -> Any? {
        get {
            // return untyped Proxy
            // (make sure we don't fall into infinite loop)
            let proxy: Proxy = self[key]
            return proxy
        }
        set {
            
            guard let newValue = newValue else {
                removeObject(forKey: key)
                return
            }
            
            switch newValue {
                // @warning This should always be on top of Int because a cast
            // from Double to Int will always succeed.
            case let v as Double: self.set(v, forKey: key)
            case let v as Int: self.set(v, forKey: key)
            case let v as Bool: self.set(v, forKey: key)
            case let v as URL: self.set(v, forKey: key)
            default: self.set(newValue, forKey: key)
            }
        }
    }
    
    /// Returns `true` if `key` exists
    
    func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    /// Removes value for `key`
    
    func remove(_ key: String) {
        removeObject(forKey: key)
    }
    
    /// Removes all keys and values from user defaults
    /// Use with caution!
    /// - Note: This method only removes keys on the receiver `UserDefaults` object.
    ///         System-defined keys will still be present afterwards.
    
    func removeAll() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
    }
}

/// Global shortcut for `UserDefaults.standard`
///
/// **Pro-Tip:** If you want to use shared user defaults, just
///  redefine this global shortcut in your app target, like so:
///  ~~~
///  var Defaults = UserDefaults(suiteName: "com.my.app")!
///  ~~~
public let Defaults = UserDefaults.standard

// MARK: - Static keys
/// Extend this class and add your user defaults keys as static constants
/// so you can use the shortcut dot notation (e.g. `Defaults[.yourKey]`)
open class DefaultsKeys {
    fileprivate init() {}
}

/// Base class for static user defaults keys. Specialize with value type
/// and pass key name to the initializer to create a key.
open class DefaultsKey<ValueType>: DefaultsKeys {
    // TODO: Can we use protocols to ensure ValueType is a compatible type?
    public let _key: String
    
    public init(_ key: String) {
        self._key = key
        super.init()
    }
}

extension UserDefaults {
    /// This function allows you to create your own custom Defaults subscript. Example: [Int: String]
    public func set<T>(_ key: DefaultsKey<T>, _ value: Any?) {
        self[key._key] = value
    }
}

extension UserDefaults {
    /// Returns `true` if `key` exists
    
    public func hasKey<T>(_ key: DefaultsKey<T>) -> Bool {
        return object(forKey: key._key) != nil
    }
    
    /// Removes value for `key`
    
    public func remove<T>(_ key: DefaultsKey<T>) {
        removeObject(forKey: key._key)
    }
}

// MARK: Subscripts for specific standard types
// TODO: Use generic subscripts when they become available
extension UserDefaults {
    public subscript(key: DefaultsKey<String?>) -> String? {
        get { return string(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<String>) -> String {
        get { return unwrap(string(forKey: key._key), "") }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Int?>) -> Int? {
        get { return numberForKey(key._key)?.intValue }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Int>) -> Int {
        get { return unwrap(numberForKey(key._key)?.intValue, 0) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Double?>) -> Double? {
        get { return numberForKey(key._key)?.doubleValue }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Double>) -> Double {
        get { return unwrap(numberForKey(key._key)?.doubleValue, 0.0) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Bool?>) -> Bool? {
        get { return numberForKey(key._key)?.boolValue }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return unwrap(numberForKey(key._key)?.boolValue, false) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Any?>) -> Any? {
        get { return object(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Data?>) -> Data? {
        get { return data(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Data>) -> Data {
        get { return unwrap(data(forKey: key._key), Data()) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Date?>) -> Date? {
        get { return object(forKey: key._key) as? Date }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<URL?>) -> URL? {
        get { return url(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    // TODO: It would probably make sense to have support for statically typed dictionaries (e.g. [String: String])
    
    public subscript(key: DefaultsKey<[String: Any]?>) -> [String: Any]? {
        get { return dictionary(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[String: Any]>) -> [String: Any] {
        get { return unwrap(dictionary(forKey: key._key), [:]) }
        set { set(key, newValue) }
    }
}

// MARK: Static subscripts for array types
extension UserDefaults {
    public subscript(key: DefaultsKey<[Any]?>) -> [Any]? {
        get { return array(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Any]>) -> [Any] {
        get { return unwrap(array(forKey: key._key), []) }
        set { set(key, newValue) }
    }
}

// We need the <T: AnyObject> and <T: _ObjectiveCBridgeable> variants to
// suppress compiler warnings about NSArray not being convertible to [T]
// AnyObject is for NSData and NSDate, _ObjectiveCBridgeable is for value
// types bridge-able to Foundation types (String, Int, ...)
extension UserDefaults {
    public func getArray<T: _ObjectiveCBridgeable>(_ key: DefaultsKey<[T]>) -> [T] {
        return unwrap(array(forKey: key._key) as NSArray? as? [T], [])
    }
    
    public func getArray<T: _ObjectiveCBridgeable>(_ key: DefaultsKey<[T]?>) -> [T]? {
        return array(forKey: key._key) as NSArray? as? [T]
    }
    
    public func getArray<T: Any>(_ key: DefaultsKey<[T]>) -> [T] {
        return unwrap(array(forKey: key._key) as NSArray? as? [T], [])
    }
    
    public func getArray<T: Any>(_ key: DefaultsKey<[T]?>) -> [T]? {
        return array(forKey: key._key) as NSArray? as? [T]
    }
}

extension UserDefaults {
    public subscript(key: DefaultsKey<[String]?>) -> [String]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[String]>) -> [String] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Int]?>) -> [Int]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Int]>) -> [Int] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Double]?>) -> [Double]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Double]>) -> [Double] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Bool]?>) -> [Bool]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Bool]>) -> [Bool] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Data]?>) -> [Data]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Data]>) -> [Data] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Date]?>) -> [Date]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Date]>) -> [Date] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
}

// MARK: - Archiving custom types
// MARK: RawRepresentable
extension UserDefaults {
    // TODO: Ensure that T.RawValue is compatible
    public func archive<T: RawRepresentable>(_ key: DefaultsKey<T>, _ value: T) {
        set(key, value.rawValue)
    }
    
    public func archive<T: RawRepresentable>(_ key: DefaultsKey<T?>, _ value: T?) {
        if let value = value {
            set(key, value.rawValue)
        } else {
            remove(key)
        }
    }
    
    public func unarchive<T: RawRepresentable>(_ key: DefaultsKey<T?>) -> T? {
        return object(forKey: key._key).flatMap { T(rawValue: $0 as! T.RawValue) }
    }
    
    public func unarchive<T: RawRepresentable>(_ key: DefaultsKey<T>) -> T? {
        return object(forKey: key._key).flatMap { T(rawValue: $0 as! T.RawValue) }
    }
}

// MARK: NSCoding
extension UserDefaults {
    // TODO: Can we simplify this and ensure that T is NSCoding compliant?
    public func archive<T>(_ key: DefaultsKey<T>, _ value: T) {
        set(key, NSKeyedArchiver.archivedData(withRootObject: value))
    }
    
    public func archive<T>(_ key: DefaultsKey<T?>, _ value: T?) {
        if let value = value {
            set(key, NSKeyedArchiver.archivedData(withRootObject: value))
        } else {
            remove(key)
        }
    }
    
    public func unarchive<T>(_ key: DefaultsKey<T>) -> T? {
        return data(forKey: key._key).flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) } as? T
    }
    
    public func unarchive<T>(_ key: DefaultsKey<T?>) -> T? {
        return data(forKey: key._key).flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) } as? T
    }
}

// MARK: - Deprecations
infix operator ?= : AssignmentPrecedence

/// If key doesn't exist, sets its value to `expr`
/// - Deprecation: This will be removed in a future release.
///   Please migrate to static keys and use this gist: https://gist.github.com/radex/68de9340b0da61d43e60
/// - Note: This isn't the same as `Defaults.registerDefaults`. This method saves the new value to disk, whereas `registerDefaults` only modifies the defaults in memory.
/// - Note: If key already exists, the expression after ?= isn't evaluated
@available(*, deprecated, message:"Please migrate to static keys and use this gist: https://gist.github.com/radex/68de9340b0da61d43e60")
public func ?= (proxy: UserDefaults.Proxy, expr: @autoclosure() -> Any) {
    if !proxy.defaults.hasKey(proxy.key) {
        proxy.defaults[proxy.key] = expr()
    }
}

/// Adds `b` to the key (and saves it as an integer)
/// If key doesn't exist or isn't a number, sets value to `b`
@available(*, deprecated, message:"Please migrate to static keys to use this.")
public func += (proxy: UserDefaults.Proxy, b: Int) {
    let a = proxy.defaults[proxy.key].intValue
    proxy.defaults[proxy.key] = a + b
}

@available(*, deprecated, message:"Please migrate to static keys to use this.")
public func += (proxy: UserDefaults.Proxy, b: Double) {
    let a = proxy.defaults[proxy.key].doubleValue
    proxy.defaults[proxy.key] = a + b
}

/// Icrements key by one (and saves it as an integer)
/// If key doesn't exist or isn't a number, sets value to 1
@available(*, deprecated, message:"Please migrate to static keys to use this.")
public postfix func ++ (proxy: UserDefaults.Proxy) {
    proxy += 1
}

extension Date {
    //算出當前月份的第幾號
    func day(date: Date) -> NSInteger{
        let components = Calendar.current.dateComponents([.year,.month,.day], from: date)
        return components.day!
    }
    //算出當前是第幾月份
    func month(date: Date) -> NSInteger{
        let components = Calendar.current.dateComponents([.year,.month,.day], from: date)
        return components.month!
    }
    //算出當前年份
    func year(date: Date) -> NSInteger{
        let components = Calendar.current.dateComponents([.year,.month,.day], from: date)
        return components.year!
    }
    //算出每個月的1號對應的星期幾
    func firstWeekdayInThisMonth(date: Date) -> NSInteger{
        
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        var components = Calendar.current.dateComponents([.year,.month,.day], from: date)
        components.day = 1
        let firstDayOfMonthDate = calendar.date(from: components)
        let firstWeekday = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: firstDayOfMonthDate!)
        return firstWeekday!
        
    }
    //當前月份的天數
    func totaldaysInThisMonth(date: Date) -> NSInteger{
        let totaldaysInMonth: Range = Calendar.current.range(of: .day, in: .month, for: date)!
        return (totaldaysInMonth.count)
    }
    
    func totalmonthInThisYear(date: Date) -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        //當前年份
        let year = calendar.component(.year, from: date)
        let dateComponents = DateComponents(year: year, month: month, day:1)
        let firstDate = calendar.date(from: dateComponents)
        return firstDate!
    }
    //上一個月
    func lastMonth(date: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate!
    }
    //下一個月
    func nextMonth(date: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = +1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        
        return newDate!
    }
    
    func firstMonthOfYear(date: Date, year: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: date)
        components.month = 1
        components.year = year
        let startOfYear = calendar.date(from: components)
        return startOfYear!
    }
    
    func firstYear(date:Date)-> Date{
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: date)
        components.year = 2016
        let startOfYear = calendar.date(from: components)
        return startOfYear!
    }
    
    func nextYear(date:Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate!
    }
    
    func lastYear(date: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = -1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate!
    }
    
    func getDayOfWeek(fromDate date: Date) -> String? {
        let cal = Calendar(identifier: .gregorian)
        let dayOfWeek = cal.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1:
            return "週日"
        case 2:
            return "週一"
        case 3:
            return "週二"
        case 4:
            return "週三"
        case 5:
            return "週四"
        case 6:
            return "週五"
        case 7:
            return "週六"
        default:
            return nil
        }
    }
    
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var nextday: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    func daysCount(year: Int, month: Int) -> Int {
        
        var daysArray = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        
        if year % 400 == 0 || year % 100 != 0 && year % 4 == 0 {
            
            daysArray[2] += 1
            
        }
        
        
        return daysArray[month]
        
    }
    
}
extension DefaultsKeys {
    static let home_reset_time = DefaultsKey<Double>("home_reset_time")
    static let repair_reset_time = DefaultsKey<Double>("repair_reset_time")
    static let official_url = DefaultsKey<String?>("official_url")
    /// 裝置id
    static let deviceId = DefaultsKey<String?>("deviceId")
    /// 是否顯示過教學
    static let isFirstDisplayTeachingView = DefaultsKey<Bool?>("isFirstDisplayTeachingView")
    /// 是否出現首頁教學頁
    static let isShowTeachingVC = DefaultsKey<Bool?>("isShowTeachingVC20210510")
    /// 是否出現播放器下載教學頁
    static let isShowPlayerDownloadTeachingVC = DefaultsKey<Bool?>("isShowPlayerDownloadTeachingVC20210104")
    /// 會員帳號->用來看是否被登出
    static let memberAccount = DefaultsKey<String>("memberAccount")
    /// 裝置註冊ID, 打自動登入時會使用
    static let registerId = DefaultsKey<String>("registerId")
    /// 收藏的點我是否出現
    static let isDisPlayPointView = DefaultsKey<Bool>("isDisPlayPointView")
    /// 點擊收藏的點我次數
    static let displayPointViewCount = DefaultsKey<Int>("displayPointViewCount")
    /// 任務頁入口顯示訊息
    static let checkInEntranceDisplayMsg = DefaultsKey<String>("checkInEntranceDisplayMsg")
    /// 傳送mkt下載
    static let installedLogs = DefaultsKey<Bool>("installedLogs")
    /// vip廣告跳過時間
    static let VIPAdFreeSystemTime = DefaultsKey<Double>("VIPAdFreeSystemTime")
    /// 資料庫升級日期 如需更新資料庫直接改日期就好
    static let upgradeSqlite = DefaultsKey<Bool>("upgradeSqlite20210625")
    /// 配合avdata2.0的資料庫影片番號更新 如需更新資料庫直接改日期就好
    static let newApiUpgradeSqliteVideoId = DefaultsKey<Bool>("newApiUpgradeSqliteVideoId20211122")
    /// 獨家頁選擇片商3個
    static let exclusiveDirector = DefaultsKey<[Int]>("exclusiveDirector")
    /// 一般觀看日期
    static let videoWatchDate = DefaultsKey<String>("videoWatchDate")
    /// 一般每日片數
    static let videoWatchCode = DefaultsKey<[String]>("videoWatchCode")
    /// 首頁、vip頁直播教學
    static let liveTeachingHome = DefaultsKey<Bool?>("liveTeachingHome")
    /// 直播頁教學
    static let liveTeaching = DefaultsKey<Bool?>("liveTeaching")
    /// 是否出現過免廣告解鎖 VIP pop窗了(只會出現一次，記在後端 > 不管在不同裝置都只會出現一次)
    static let isAppearUnlockAdVipToast = DefaultsKey<Bool>("isAppearUnlockAdVipToast")
    /// 是否出現過免廣告解鎖 神龍 pop窗了(只會出現一次，記在後端 > 不管在不同裝置都只會出現一次)
    static let isAppearUnlockAdRankToast = DefaultsKey<Bool>("isAppearUnlockAdRankToast")
    /// 更版時間
    static let versionUpdateTimeStamp = DefaultsKey<Int>("versionUpdateTimeStamp")
    /// 分享任務 key: yyyyMMdd, value:次數
    static let shareMissionComplete = DefaultsKey<[String: Any]>("shareMissionComplete")
    /// 一般觀看日期/影片id key: yyyyMMdd, value:次數
    static let videoWatchCountDate = DefaultsKey<[String: Any]>("videoWatchCountDate")
    /// 開啟ＡＰＰ後是否點選過播放頁下方續費廣告
    static let isVideoBottomPromptClick = DefaultsKey<Bool>("isVideoBottomPromptClick")
    /// 會員頁教學點選不再提醒的版本(更版會再度顯示)
    static let memberTeachDontRemindVersion = DefaultsKey<String>("memberTeachDontRemindVersion")
    /// debug模式(正式/測試)
    static let debugModeSelect = DefaultsKey<Bool?>("debugModeSelect")
}

public extension UITableView {
    
    var indexesOfVisibleSections: [Int] {
        // Note: We can't just use indexPathsForVisibleRows, since it won't return index paths for empty sections.
        var visibleSectionIndexes = [Int]()
        
        for i in 0..<numberOfSections {
            var headerRect: CGRect?
            // In plain style, the section headers are floating on the top, so the section header is visible if any part of the section's rect is still visible.
            // In grouped style, the section headers are not floating, so the section header is only visible if it's actualy rect is visible.
            if (self.style == .plain) {
                headerRect = rect(forSection: i)
            } else {
                headerRect = rectForHeader(inSection: i)
            }
            if headerRect != nil {
                // The "visible part" of the tableView is based on the content offset and the tableView's size.
                let visiblePartOfTableView: CGRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.size.width, height: bounds.size.height)
                if (visiblePartOfTableView.intersects(headerRect!)) {
                    visibleSectionIndexes.append(i)
                }
            }
        }
        return visibleSectionIndexes
    }
    
    var visibleSectionHeaders: [UITableViewHeaderFooterView] {
        var visibleSects = [UITableViewHeaderFooterView]()
        for sectionIndex in indexesOfVisibleSections {
            if let sectionHeader = headerView(forSection: sectionIndex) {
                visibleSects.append(sectionHeader)
            }
        }
        
        return visibleSects
    }
}
extension String {
    
    /// 拿取廣告app是識別ID，並重新拼接
    ///
    /// - Parameter appIdentify: app識別碼
    /// - Returns: 回傳String（拼接好的app識別碼）
    func getAppIdentify() -> String? {
//        guard let id = self else { return nil }
        if self.contains("://") {
            return self
        } else {
            return "\(self)://"
        }
    }
    
    /// 期數設定
    func periodsSet() -> String {
        if self.count >= 4 {
            return self
        } else if self.count >= 3 {
            return "0" + self
        } else if self.count >= 2 {
            return "00" + self
        } else {
            return "000" + self
        }
    }
    
    /// 替換字串
    ///
    /// - Parameters:
    ///   - target: 要被替換的文字
    ///   - withString: 替換的文字
    /// - Returns: 回傳文字
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return unwrap(encodeUrlString, "")
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return unwrap(self.removingPercentEncoding, "")
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return unwrap(htmlToAttributedString?.string, "")
    }
    
    /// 從某個啟始點之後的佔位符開始擷取
    ///
    /// - Parameter index: 從哪一個
    /// - Returns: 回字串
    public func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]

            return String(subString)
        } else {
            return self
        }
    }
    
    /// 字串轉顏色
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /// 計算文字Label長度
    ///
    /// - Parameters:
    ///   - font: 字體樣式
    ///   - maxSize: 最大size
    /// - Returns: 回傳CGSize
    func textSize(font: UIFont, maxSize: CGSize) -> CGSize {
        return self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(token: String, block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}

extension UIPageControl {
    func customPageControl(dotFillColor1: UIColor, dotFillColor2: UIColor, dotBorderColor: UIColor, dotBorderWidth: CGFloat) {
        for (pageIndex, dotView) in self.subviews[0].subviews[0].subviews.enumerated() {
            if self.currentPage == pageIndex {
                dotView.backgroundColor = dotFillColor1
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
                dotView.layer.borderColor = dotBorderColor.cgColor
                dotView.layer.borderWidth = dotBorderWidth
            } else {
                dotView.backgroundColor = dotFillColor2
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
                dotView.layer.borderColor = dotBorderColor.cgColor
                dotView.layer.borderWidth = dotBorderWidth
            }
        }
    }
}

extension Dictionary {
    
    var json: String {
        let invalidJson = "不合法字串"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return unwrap(String(bytes: jsonData, encoding: String.Encoding.utf8), invalidJson)
        } catch {
            return invalidJson
        }
    }
    
    /// 轉換字典到JSON字串
    ///
    /// - Returns: 回傳JSON字串
    func toJSON() -> String {
        return json
    }
}


extension UISlider {
    
    func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setSliderThumbTintColor(size: CGSize, color: UIColor) {
        let circleImage = makeCircleWith(size: size, backgroundColor: color)
        self.setThumbImage(circleImage, for: .normal)
        self.setThumbImage(circleImage, for: .highlighted)
    }
}
