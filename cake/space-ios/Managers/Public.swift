//
//  Public.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import SystemConfiguration
import AudioToolbox
import RealmSwift
import SDWebImage
import MapKit

public let statusOnline = "Online"
public let userMessagesFirebaseFolder = "userMessages"
public let messageMetaDataFirebaseFolder = "metaData"

extension UISearchBar {
  func changeBackgroundColor(to color: UIColor) {
    if let textfield = self.value(forKey: "searchField") as? UITextField {
      textfield.textColor = UIColor.blue
      if let backgroundview = textfield.subviews.first {
        backgroundview.backgroundColor = color
        backgroundview.layer.cornerRadius = 10
        backgroundview.clipsToBounds = true
      }
    }
  }
}

extension UITableView {
  
  func indexPathForView(_ view: UIView) -> IndexPath? {
    let center = view.center
    let viewCenter = self.convert(center, from: view.superview)
    let indexPath = self.indexPathForRow(at: viewCenter)
    return indexPath
  }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

//extension UIColor {
//    static func random() -> UIColor {
//        return UIColor(
//           red:   .random(),
//           green: .random(),
//           blue:  .random(),
//           alpha: 1.0
//        )
//    }
//}

extension UIColor {
    static var random: UIColor {
        return .init(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
}

extension String {
  
  var digits: String {
    return components(separatedBy: CharacterSet.decimalDigits.inverted)
      .joined()
  }
  
  var doubleValue: Double {
    return Double(self) ?? 0
  }
}

extension SystemSoundID {
  static func playFileNamed(fileName: String, withExtenstion fileExtension: String) {
    var sound: SystemSoundID = 0
    if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
      AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
      AudioServicesPlaySystemSound(sound)
    }
  }
}

func createImageThumbnail (_ image: UIImage) -> UIImage {
  
  let actualHeight:CGFloat = image.size.height
  let actualWidth:CGFloat = image.size.width
  let imgRatio:CGFloat = actualWidth/actualHeight
  let maxWidth:CGFloat = 150.0
  let resizedHeight:CGFloat = maxWidth/imgRatio
  let compressionQuality:CGFloat = 0.5
  
  let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
  UIGraphicsBeginImageContext(rect.size)
  image.draw(in: rect)
  let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    let imageData: Data = img.jpegData(compressionQuality: compressionQuality)!
  UIGraphicsEndImageContext()
  
  return UIImage(data: imageData)!
}

func compressImage(image: UIImage) -> Data {
  // Reducing file size to a 10th
  
  var actualHeight : CGFloat = image.size.height
  var actualWidth : CGFloat = image.size.width
  let maxHeight : CGFloat = 1920.0
  let maxWidth : CGFloat = 1080.0
  var imgRatio : CGFloat = actualWidth/actualHeight
  let maxRatio : CGFloat = maxWidth/maxHeight
  var compressionQuality : CGFloat = 0.8
  
  if (actualHeight > maxHeight || actualWidth > maxWidth) {
    
    if (imgRatio < maxRatio) {
      
      //adjust width according to maxHeight
      imgRatio = maxHeight / actualHeight;
      actualWidth = imgRatio * actualWidth;
      actualHeight = maxHeight;
    } else if (imgRatio > maxRatio) {
      
      //adjust height according to maxWidth
      imgRatio = maxWidth / actualWidth;
      actualHeight = imgRatio * actualHeight;
      actualWidth = maxWidth;
      
    } else {
      
      actualHeight = maxHeight
      actualWidth = maxWidth
      compressionQuality = 1
    }
  }
  
  let rect = CGRect(x: 0.0, y: 0.0, width:actualWidth, height:actualHeight)
  UIGraphicsBeginImageContext(rect.size)
  image.draw(in: rect)
  let img = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = img!.jpegData(compressionQuality: compressionQuality)
  UIGraphicsEndImageContext();
  
  return imageData!
}

//func uploadAvatarForUserToFirebaseStorageUsingImage(_ image: UIImage, quality: CGFloat, completion: @escaping (_  imageUrl: String) -> ()) {
//  let imageName = UUID().uuidString
//  let reference = Storage.storage().reference().child("userProfilePictures").child(imageName)
//
//  if let uploadData = image.jpegData(compressionQuality: quality) {
//    ref.putData(uploadData, metadata: nil) { (metadata, error) in
//      guard error == nil else { completion(""); return }
//      
//      ref.downloadURL(completion: { (url, error) in
//        guard error == nil, let imageURL = url else { completion(""); return }
//         completion(imageURL.absoluteString)
//      })
//    }
//  }
//}

private var backgroundView: UIView = {
  let backgroundView = UIView()
  backgroundView.backgroundColor = UIColor.black
  backgroundView.alpha = 0.8
  backgroundView.layer.cornerRadius = 0
  backgroundView.layer.masksToBounds = true
  
  return backgroundView
}()

private var activityIndicator: UIActivityIndicatorView = {
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
  activityIndicator.hidesWhenStopped = true
  activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
    activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
  activityIndicator.autoresizingMask = [.flexibleLeftMargin , .flexibleRightMargin , .flexibleTopMargin , .flexibleBottomMargin]
  activityIndicator.isUserInteractionEnabled = false
  
  return activityIndicator
}()

extension UIView {
  func addDashedBorder() {
    let color = UIColor.black.cgColor

    let shapeLayer:CAShapeLayer = CAShapeLayer()
    let frameSize = self.frame.size
    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

    shapeLayer.bounds = shapeRect
    shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color
    shapeLayer.lineWidth = 2
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.lineDashPattern = [6,3]
    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath

    self.layer.addSublayer(shapeLayer)
    }
}

extension UIView{
    func roundedButton(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: [.topLeft , .topRight],
            cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}

extension UILocalizedIndexedCollation {
  
  func partitionObjects(array:[AnyObject], collationStringSelector:Selector) -> ([AnyObject], [String]) {
    var unsortedSections = [[AnyObject]]()
    
    //1. Create a array to hold the data for each section
    for _ in self.sectionTitles {
      unsortedSections.append([]) //appending an empty array
    }
    //2. Put each objects into a section
    for item in array {
      let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
      unsortedSections[index].append(item)
    }
    //3. sorting the array of each sections
    var sectionTitles = [String]()
    var sections = [AnyObject]()
    for index in 0 ..< unsortedSections.count { if unsortedSections[index].count > 0 {
      sectionTitles.append(self.sectionTitles[index])
      sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
      }
    }
    
    return (sections, sectionTitles)
  }
}

extension UIImageView {
  
  func showActivityIndicator() {
    
    self.addSubview(backgroundView)
    self.addSubview(activityIndicator)
        activityIndicator.style = .white
    activityIndicator.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    DispatchQueue.main.async {
      activityIndicator.startAnimating()
    }
  }
  
  func hideActivityIndicator() {
    DispatchQueue.main.async {
      activityIndicator.stopAnimating()
    }
    
    activityIndicator.removeFromSuperview()
    backgroundView.removeFromSuperview()
  }
}

func uploadImageForUserToFirebaseStorageUsingImage(_ image: UIImage, quality: CGFloat, completion: @escaping (_  imageUrl: String) -> ()) {
    let imageName = UUID().uuidString
    let reference = Storage.storage().reference().child("profielImages").child(imageName)

    if let uploadData = image.jpegData(compressionQuality: quality) {
        reference.putData(uploadData, metadata: nil) { (metadata, error) in
            guard error == nil else { completion(""); return }
      
            reference.downloadURL(completion: { (url, error) in
                guard error == nil, let imageURL = url else { completion(""); return }
                completion(imageURL.absoluteString)
            })
        }
    }
}

func uploadImageForChannelToFirebaseStorageUsingImage(_ image: UIImage, quality: CGFloat, completion: @escaping (_  imageUrl: String) -> ()) {
    let imageName = UUID().uuidString
    let reference = Storage.storage().reference().child("channelImages").child(imageName)

    if let uploadData = image.jpegData(compressionQuality: quality) {
        reference.putData(uploadData, metadata: nil) { (metadata, error) in
            guard error == nil else { print("error /// \(error?.localizedDescription ?? "")"); completion(""); return }
      
            reference.downloadURL(completion: { (url, error) in
                guard error == nil, let imageURL = url else { completion(""); return }
                completion(imageURL.absoluteString)
            })
        }
    }
}

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text

    label.sizeToFit()
    return label.frame.height
}

func basicErrorAlertWith (title: String, message: String, controller: UIViewController) {
    hapticFeedback(style: .error)
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
  controller.present(alert, animated: true, completion: nil)
}

extension Notification {
    var keyboardRect: CGRect? {
        guard let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return nil
        }
        return keyboardSize.cgRectValue
    }
}

extension UIImage {
  var asJPEGData: Data? {
    //    self.jpegData(compressionQuality: 1)
    return self.jpegData(compressionQuality: 1)   // QUALITY min = 0 / max = 1
  }
  var asPNGData: Data? {
    return self.pngData()
  }
}

extension UIView {
    
    func constrainCentered(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        
        let horizontalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        
        let heightContraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.height)
        
        let widthContraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.width)
        
        addConstraints([
            horizontalContraint,
            verticalContraint,
            heightContraint,
            widthContraint])
        
    }
    
    func constrainToEdges(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
    
}

class ImageViewWithOverlay: UIImageView {
    let overlay: UIView
    
    override init(frame: CGRect) {
        overlay = UIView()
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        overlay = UIView()
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        self.addSubview(overlay)
    }
    
    override func layoutSubviews() {
        overlay.frame = self.layer.bounds
    }
}

public func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
    var arr = array
    let element = arr.remove(at: fromIndex)
    arr.insert(element, at: toIndex)
    
    return arr
}

public enum HapticFeedbackStyle: Int {
    
    case success = 0
    case error = 1
    case warning = 2
    case impact = 3 // medium
    case selectionChanged = 4
}

public func hapticFeedback(style: HapticFeedbackStyle) {
    switch style {
    case .error:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)

    case .success:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

    case .warning:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

    case .impact:
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

    case .selectionChanged:
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
//        let generator = UISelectionFeedbackGenerator()
//        generator.selectionChanged()
    }
}

public func hapticFeedbackRegular(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
    impactFeedbackgenerator.prepare()
    impactFeedbackgenerator.impactOccurred()
}

public func hapticFeedbackError() {
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    selectionFeedbackGenerator.selectionChanged()
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        // Swift 4.1 and below
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
}

class BioTextView: UITextView {
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(UIResponderStandardEditActions.paste(_:)) {
      return false
    }
    return super.canPerformAction(action, withSender: sender)
  }
}

class PasteRestrictedTextField: UITextField {
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(UIResponderStandardEditActions.paste(_:)) {
      return false
    }
    return super.canPerformAction(action, withSender: sender)
  }
}

extension UITextView :UITextViewDelegate {

    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }

    /// The UITextView placeholder text
    public var pholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }

    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }

    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100

        placeholderLabel.isHidden = self.text.count > 0

        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}


extension UIView {
   // For insert layer in Foreground
   func addBlackGradientLayerInForeground(frame: CGRect, colors:[UIColor]){
    let gradient = CAGradientLayer()
    gradient.frame = frame
    gradient.colors = colors.map{$0.cgColor}
    self.layer.addSublayer(gradient)
   }
   // For insert layer in background
   func addBlackGradientLayerInBackground(frame: CGRect, colors:[UIColor]){
    let gradient = CAGradientLayer()
    gradient.frame = frame
    gradient.colors = colors.map{$0.cgColor}
    self.layer.insertSublayer(gradient, at: 0)
   }
}

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}

class TextField: UITextField {
    let xInset: CGFloat = 10
    let yInset: CGFloat = 4

    // placeholder position
    override func textRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: self.xInset , dy: self.yInset)
    }

    // text position
    override func editingRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: self.xInset , dy: self.yInset)
    }

    override func placeholderRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: self.xInset, dy: self.yInset)
    }
}

extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
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
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UserDefaults {
    func imageForKey(key: String) -> UIImage? {
        var image: UIImage?
        if let imageData = data(forKey: key) {
            image = NSKeyedUnarchiver.unarchiveObject(with: imageData) as? UIImage
        }
        return image
    }
    func setImage(image: UIImage?, forKey key: String) {
        var imageData: NSData?
        if let image = image {
            imageData = NSKeyedArchiver.archivedData(withRootObject: image) as NSData?
        }
        set(imageData, forKey: key)
    }
}

extension UIView {
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        })
    }
}

extension UITextField {
    func checkEmail(field: String, completion: @escaping (Bool) -> Void) {
        let collectionRef = Firestore.firestore().collection("users")
        collectionRef.whereField("email", isEqualTo: field).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else if (snapshot?.isEmpty)! {
                completion(false)
            } else {
                for document in (snapshot?.documents)! {
                    if document.data()["email"] != nil {
                        completion(true)
                    }
                }
            }
        }
    }
}


public func checkIfPhoneNumberAlreayExists(field: String, completion: @escaping (Bool) -> Void) {
    let collectionRef = Firestore.firestore().collection("users")
    collectionRef.whereField("phoneNumber", isEqualTo: field).getDocuments { (snapshot, err) in
        if let err = err {
            print("Error getting document: \(err)")
            return
        }
        guard let snapshot = snapshot else { return }
        if snapshot.isEmpty {
            completion(false)
        } else {
            completion(true)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

extension Collection {
    func insertionIndex(of element: Self.Iterator.Element,
                        using areInIncreasingOrder: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> Index {
        return firstIndex(where: { !areInIncreasingOrder($0, element) }) ?? endIndex
    }
}

extension UIApplication {
  class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topViewController(controller: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topViewController(controller: presented)
    }
    return controller
  }
}


extension UIScrollView {
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
}

extension UINavigationItem {
    func setTitle(title:String, subtitle:String) {
        let one = UILabel()
        one.text = title
        one.textColor = ThemeManager.currentTheme().generalTitleColor
        one.font = ThemeManager.currentTheme().secondaryFont(with: 15)
        one.textAlignment = .center
        one.sizeToFit()

        let two = UILabel()
        two.text = subtitle
        two.font = ThemeManager.currentTheme().secondaryFontItalic(with: 10)
        two.textAlignment = .center
        two.textColor = ThemeManager.currentTheme().generalSubtitleColor
        two.sizeToFit()

        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical

        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)

        one.sizeToFit()
        two.sizeToFit()
        self.titleView = stackView
    }
}

public let messageStatusRead = "Read"
public let messageStatusSending = "Sending"
public let messageStatusDelivered = "Delivered"

let cameraAccessDeniedMessage = " needs access to your camera to take photos and videos.\n\nPlease go to Settings –– Privacy –– Camera –– and set  to ON."
let contactsAccessDeniedMessage = " needs access to your contacts to create new ones.\n\nPlease go to Settings –– Privacy –– Contacts –– and set  to ON."
let microphoneAccessDeniedMessage = " needs access to your microphone to record audio messages.\n\nPlease go to Settings –– Privacy –– Microphone –– and set  to ON."
let photoLibraryAccessDeniedMessage = " needs access to your photo library to send photos and videos.\n\nPlease go to Settings –– Privacy –– Photos –– and set  to ON."

let cameraAccessDeniedMessageProfilePicture = " needs access to your camera to take photo for your profile.\n\nPlease go to Settings –– Privacy –– Camera –– and set  to ON."
let photoLibraryAccessDeniedMessageProfilePicture = " needs access to your photo library to select photo for your profile.\n\nPlease go to Settings –– Privacy –– Photos –– and set  to ON."

let videoRecordedButLibraryUnavailableError = "To send a recorded video, it has to be saved to your photo library first. Please go to Settings –– Privacy –– Photos –– and set  to ON."

let basicErrorTitleForAlert = "Error"
let basicTitleForAccessError = "Please Allow Access"
let noInternetError = "Internet is not available. Please try again later"
let copyingImageError = "You cannot copy not downloaded image, please wait until downloading finished"
let genericOperationError = "Could not complete this request. Try Again later?"

let datesError = "Date selection is invalid"
let emptyChannelName = "Please provide a name for the event"

let deletionErrorMessage = "There was a problem when deleting. Try again later."
let cameraNotExistsMessage = "You don't have camera"
let thumbnailUploadError = "Failed to upload your image to database. Please, check your internet connection and try again."
let fullsizePictureUploadError = "Failed to upload fullsize image to database. Please, check your internet connection and try again. Despite this error, thumbnail version of this picture has been uploaded, but you still should re-upload your fullsize image."

let cannotDoThisState = "Cannot edit event"

let basicActionTitle = "Got it"

let phoneNumberSMSDisclaimer = "We will send you a text with a verification code. \nMessage and data rates may apply."

struct ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
    static let frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

struct DeviceType {
    static let iPhone4orLess = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength < 568.0
    static let iPhone5orSE = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 568.0
    static let iPhone678 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 667.0
    static let iPhone678p = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 736.0
    static let iPhoneX = UIDevice.current.userInterfaceIdiom == .phone && (ScreenSize.maxLength == 812.0 || ScreenSize.maxLength == 896.0)
    
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxLength == 1024.0
    static let IS_IPAD_PRO = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxLength == 1366.0
}
// You can make it nicer by using enum (.down, .up) instead of Bool
func shrink(cell: UITableViewCell, down: Bool) {
    UIView.animate(withDuration: 0.6) {
        if down {
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } else {
            cell.transform = .identity
        }
    }
}
extension Date {
    
    func nearestHour() -> Date {
        return Date(timeIntervalSinceReferenceDate:
                (timeIntervalSinceReferenceDate / 3600.0).rounded(.toNearestOrEven) * 3600.0)
    }
    
    func nearestHalfHour() -> Date {
        return Date(timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate / 1800.0).rounded(.toNearestOrEven) * 1800.0)
    }
    
    public var nextHour: Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        let components = DateComponents(hour: 1, minute: -minutes)
        return calendar.date(byAdding: components, to: self) ?? self
    }
    
    func getShortDateStringFromUTC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: self)
    }
    
    func getTimeStringFromUTC() -> String {
        let dateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: self)
    }
    
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self).capitalized
    }
    
    func dayNumberOfWeek() -> Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday!
    }
    func monthNumber() -> Int {
        return Calendar.current.dateComponents([.month], from: self).month!
    }
    func yearNumber() -> Int {
        return Calendar.current.dateComponents([.year], from: self).year!
    }
}

func timestampOfLastMessage(_ date: Date) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [ .day, .weekOfYear, .weekday]
    let now = Date()
    let earliest = now < date ? now : date
    let latest = (earliest == now) ? date : now
    let components =  calendar.dateComponents(unitFlags, from: earliest,  to: latest)
    
    //  if components.weekOfYear! >= 1 {
    //    return date.getShortDateStringFromUTC()
    //  } else if components.weekOfYear! < 1 && date.dayNumberOfWeek() != now.dayNumberOfWeek() {
    //    return date.dayOfWeek()
    //  } else {
    //    return date.getTimeStringFromUTC()
    //  }
    
    if now.getShortDateStringFromUTC() != date.getShortDateStringFromUTC() {  // not today
        if components.weekOfYear! >= 1 { // last week
            return date.getShortDateStringFromUTC()
        } else { // this week
            return date.dayOfWeek()
        }
        
    } else { // this day
        return date.getTimeStringFromUTC()
    }
    
    
}

func timestampOfChatLogMessage(_ date: Date) -> String {
//    let now = Date()
    return date.getTimeStringFromUTC()
//    if now.getShortDateStringFromUTC() != date.getShortDateStringFromUTC() {
//        return "\(date.getShortDateStringFromUTC())\n\(date.getTimeStringFromUTC())"
//    } else {
//        return date.getTimeStringFromUTC()
//    }
}

func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = Date()
    let earliest = now < date ? now : date
    let latest = (earliest == now) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "yesterday at \(date.getTimeStringFromUTC())"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "an hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "a minute ago"
        }
    } else if (components.second! >= 3) {
        return "just now"//"\(components.second!) seconds ago"
    } else {
        return "just now"
    }
}

extension Int {
    func toString() -> String {
        let myString = String(self)
        return myString
    }
}

extension UINavigationController {
//    override open var preferredStatusBarStyle : UIStatusBarStyle {
//        return ThemeManager.currentTheme().statusBarStyle
//    }
    
    func backToViewController(viewController: Swift.AnyClass) {
      for element in viewControllers {
        if element.isKind(of: viewController) {
          self.popToViewController(element, animated: true)
          break
        }
      }
    }
}


extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}

func displayAlert(title: String, message: String, preferredStyle: CustomAlertController.Style, actionTitle: String, controller: UIViewController) {
    DispatchQueue.main.async {
        let alert = CustomAlertController(title_: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(CustomAlertAction(title: actionTitle, style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}

func displayErrorAlert(title: String, message: String, preferredStyle: CustomAlertController.Style, actionTitle: String, controller: UIViewController) {
    hapticFeedback(style: .error)
    let alert = CustomAlertController(title_: title, message: message, preferredStyle: preferredStyle)
    alert.addAction(CustomAlertAction(title: actionTitle, style: .default, handler: nil))
    
    DispatchQueue.main.async {
        controller.present(alert, animated: true, completion: nil)
    }
}

func basicErrorAlert(errorMessage: String, controller: UIViewController) {
    hapticFeedback(style: .error)
    let alert = CustomAlertController(title_: basicErrorTitleForAlert, message: errorMessage, preferredStyle: .alert)
    alert.addAction(CustomAlertAction(title: basicActionTitle, style: .default, handler: nil))
    
    DispatchQueue.main.async {
        controller.present(alert, animated: true, completion: nil)
    }
}

import PhoneNumberKit
fileprivate let phoneNumberKit = PhoneNumberKit()
func prepareNumbers(from numbers: [String]) -> [String] {
    var preparedNumbers = [String]()
    for number in numbers {
        do {
            let countryCode = try phoneNumberKit.parse(number).countryCode
            let nationalNumber = try phoneNumberKit.parse(number).nationalNumber
            preparedNumbers.append("+" + String(countryCode) + String(nationalNumber))
        } catch {
            if number == "5555555555" {
                preparedNumbers.append("+15555555555")
            } else if number == "3333333333" {
                preparedNumbers.append("+13333333333")
            } else if number == "4444444444" {
                preparedNumbers.append("+14444444444")
            }
        }
    }
    return preparedNumbers
}

typealias UpdateChannelDetailsCompletionHandler = (_ success: Bool) -> Void
//func updateChannelDetails(with channelID: String?, image: UIImage, completion: @escaping UpdateChannelDetailsCompletionHandler) {
typealias CompletionHandler = (_ success: Bool, _ phoneNumbers: [String]) -> Void
//func deleteCurrentPhoto(with channelID: String?, completion: @escaping DeleteCurrentPhotoCompletionHandler) {
func prepareNumbersWithCompletion(from numbers: [String], completion: @escaping CompletionHandler) {
    var preparedNumbers = [String]()
    for number in numbers {
        do {
            let countryCode = try phoneNumberKit.parse(number).countryCode
            let nationalNumber = try phoneNumberKit.parse(number).nationalNumber
            preparedNumbers.append("+" + String(countryCode) + String(nationalNumber))
        } catch {
            if number == "5555555555" {
                preparedNumbers.append("+15555555555")
            } else if number == "3333333333" {
                preparedNumbers.append("+13333333333")
            } else if number == "4444444444" {
                preparedNumbers.append("+14444444444")
            }
        }
    }
    completion(true, preparedNumbers)
}

func getLocalName(_ user: User) -> String? {
    if let number = user.phoneNumber {
        for contact in globalVariables.localContacts {
            for phone in prepareNumbers(from: contact.phoneNumbers.map({$0.value.stringValue.digits})) {
                if number == phone {
                    return contact.givenName
                }
            }
        }
    }
    return nil
}

class Alerts {
    static func showActionsheet(viewController: UIViewController, title: String, message: String, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}

public func parseAddress(selectedItem: MKPlacemark) -> String {
    // put a space between "4" and "Melrose Place"
    let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // put a comma between street and city/state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    // put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
        format:"%@%@%@%@%@%@%@",
        // street number
        selectedItem.subThoroughfare ?? "",
        firstSpace,
        // street name
        selectedItem.thoroughfare ?? "",
        comma,
        // city
        selectedItem.locality ?? "",
        secondSpace,
        // state
        selectedItem.administrativeArea ?? ""
    )
    return addressLine
}

public func runTransaction(firstChild: String, secondChild: String) {
  var ref = Database.database().reference().child("user-messages").child(firstChild).child(secondChild)
  ref.observeSingleEvent(of: .value, with: { (snapshot) in
    
    guard snapshot.hasChild(messageMetaDataFirebaseFolder) else {
      ref = ref.child(messageMetaDataFirebaseFolder)
      ref.updateChildValues(["badge": 1])
      return
    }
    ref = ref.child(messageMetaDataFirebaseFolder).child("badge")
    
    ref.runTransactionBlock({ (mutableData) -> TransactionResult in
      var value = mutableData.value as? Int
      if value == nil { value = 0 }
      mutableData.value = value! + 1
      return TransactionResult.success(withValue: mutableData)
    })
  })
}
extension Bool {
  init<T: BinaryInteger>(_ num: T) {
    self.init(num != 0)
  }
}

extension UITableViewCell {
  var selectionColor: UIColor {
    set {
      let view = UIView()
      view.backgroundColor = newValue

      self.selectedBackgroundView = view
    }
    get {
      return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
    }
  }
}

protocol Utilities {}

extension NSObject: Utilities {
  
  enum ReachabilityStatus {
    case notReachable
    case reachableViaWWAN
    case reachableViaWiFi
  }
  
  var currentReachabilityStatus: ReachabilityStatus {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        SCNetworkReachabilityCreateWithAddress(nil, $0)
      }
    }) else {
      return .notReachable
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
      return .notReachable
    }
    
    if flags.contains(.reachable) == false {
      // The target host is not reachable.
      return .notReachable
    }
    else if flags.contains(.isWWAN) == true {
      // WWAN connections are OK if the calling application is using the CFNetwork APIs.
      return .reachableViaWWAN
    }
    else if flags.contains(.connectionRequired) == false {
      // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
      return .reachableViaWiFi
    }
    else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
      // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
      return .reachableViaWiFi
    }
    else {
      return .notReachable
    }
  }
}

extension List where Element == String {
    func assign(_ array: [String]?) {
        guard let array = array else { return }
        removeAll()
        insert(contentsOf: array, at: 0)
    }

    func assign(_ array: List<String>?) {
        guard let array = array else { return }
        removeAll()
        insert(contentsOf: array, at: 0)
    }
}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

enum EventState {
    case InProgress
    case Upcoming
    case Past
}

func channelState(channel: Channel) -> EventState? {
    guard !channel.isInvalidated ,let startTime = channel.startTime.value, let endTime = channel.endTime.value else { return nil }
    
    let currentDateInt64 = Int64(Int(Date().timeIntervalSince1970))
    if startTime > currentDateInt64 && endTime > currentDateInt64 {
        return .Upcoming
    } else if startTime < currentDateInt64 && endTime > currentDateInt64 {
        return .InProgress
    } else {
        return .Past
    }
}

extension String {
    
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 1024) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.lighterGray().set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}

extension Date {
    static func dateFromCustomString(customString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: customString) ?? Date()
    }
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)) ~= self
    }

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

extension UITableView {
    func hasRow(at indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

func prefetchThumbnail(from urlString: String?) {
    if let thumbnail = urlString, let url = URL(string: thumbnail) {
        SDWebImagePrefetcher.shared.prefetchURLs([url], progress: nil) { (finished, skipped) in
//            print("finished", finished, "skipped", skipped)
        }
    }
}

func prefetchThumbnail(from urls: [URL]?) {
    SDWebImagePrefetcher.shared.prefetchURLs(urls, progress: nil) { (finished, skipped) in
//        print("finished", finished, "skipped", skipped)
    }
}

func prefetchThumbnail(from urlStrings: [String]) {
    let urls = urlStrings.compactMap({ URL(string: $0) })
    SDWebImagePrefetcher.shared.prefetchURLs(urls, progress: nil) { (finished, skipped) in
//        print("finished", finished, "skipped", skipped)
    }
}

extension List where Element == Message {
    func assign(_ array: Results<Message>?) {
        guard let array = array else { return }
        removeAll()

        insert(contentsOf: array, at: 0)
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
