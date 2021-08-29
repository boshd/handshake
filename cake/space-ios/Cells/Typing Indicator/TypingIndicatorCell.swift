//
//  TypingIndicatorCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class TypingIndicatorCell: UICollectionViewCell {
  
static let typingIndicatorHeight: CGFloat = 30
    
    enum TypingPrompt: String {
        case isTyping1 = " is typing."
        case isTyping2 = " is typing.."
        case isTyping3 = " is typing..."
        
        case areTyping1 = " are typing."
        case areTyping2 = " are typing.."
        case areTyping3 = " are typing..."
    }
    
    var isIs = true
    
    var currentLabelText: String?
    
    var currentTypingPrompt: TypingPrompt?

//    var typingIndicator: TypingBubble = {
//        var typingIndicator = TypingBubble()
//        typingIndicator.typingIndicator.isBounceEnabled = true
//        typingIndicator.typingIndicator.isFadeEnabled = true
//        typingIndicator.isPulseEnabled = true
//
//        return typingIndicator
//    }()
    
    var label: DynamicLabel = {
        var label = DynamicLabel(withInsets: 5, 5, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Someone is typing..."
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
//        label.backgroundColor = .red
        label.font = ThemeManager.currentTheme().secondaryFont(with: 10)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame.integral)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
//            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            label.heightAnchor.constraint(equalToConstant: 30),
//            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        
        //addSubview(typingIndicator)
        //typingIndicator.frame = CGRect(x: 10, y: 2, width: 72, height: TypingIndicatorCell.typingIndicatorHeight).integral
//        label.frame = CGRect(x: 150, y: 2, width: 250, height: label.frame.height).integral
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        restart()
//        invalidateTimer()
    }

    deinit {
        invalidateTimer()
    }
    
    weak var timer: Timer?
    func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
        }
    }

    func invalidateTimer()  {
        self.timer?.invalidate()
        self.timer = nil
    }

    func restart() {
        if timer != nil {
            invalidateTimer()
            startTimer()
        } else {
            startTimer()
        }
    }
    
    @objc
    func animate() {
        if let currentLabelText = currentLabelText {
            
            if currentTypingPrompt == nil {
                if isIs {
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.isTyping1.rawValue)\u{200C}"
                    currentTypingPrompt = .isTyping1
                } else {
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.areTyping1.rawValue)\u{200C}"
                    currentTypingPrompt = .areTyping1
                }
                
            }
            
            switch currentTypingPrompt {
                case .isTyping1:
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.isTyping2.rawValue)\u{200C}"
                    currentTypingPrompt = .isTyping2
                case .isTyping2:
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.isTyping3.rawValue)\u{200C}"
                    currentTypingPrompt = .isTyping3
                case .isTyping3:
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.isTyping1.rawValue)\u{200C}"
                    currentTypingPrompt = .isTyping1
                case .areTyping1:
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.areTyping2.rawValue)\u{200C}"
                    currentTypingPrompt = .areTyping2
                case .areTyping2:
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.areTyping3.rawValue)\u{200C}"
                    currentTypingPrompt = .areTyping3
                case .areTyping3:
                    label.text = "\u{200E}\(currentLabelText + TypingPrompt.areTyping1.rawValue)\u{200C}"
                    currentTypingPrompt = .areTyping1
                default:
                    break
            }
        }
        // \u{200E} \u{200C}
    }
    
}
