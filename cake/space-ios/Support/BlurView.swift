import UIKit


class BlurView : UIView {
    var blurEffectView: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView()
        return blurEffectView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        blurEffectView.effect = UIBlurEffect(style: ThemeManager.currentTheme().blurViewBackground)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
    func resetEffect() {
//        blurEffectView.removeFromSuperview()
        
//        blurEffectView.effect = UIBlurEffect(style: ThemeManager.currentTheme().blurViewBackground)
//        blurEffectView.frame = bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        addSubview(blurEffectView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
