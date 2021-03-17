//
//  MarginStackCell.swift
//  StackScrollView
//
//  Created by muukii on 5/2/17.
//  Copyright © 2017 muukii. All rights reserved.
//
import UIKit

final class TitleStackCell: StackCellBase {
  
  let height: CGFloat
  
  init(height: CGFloat, backgroundColor: UIColor) {
    self.height = height
    super.init()
    self.backgroundColor = backgroundColor
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: height)
  }
}

final class ImageStackCell: StackCellBase {
    
    let height: CGFloat
    
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "fff")
        
        return imageView
    }()
    
    init(height: CGFloat, backgroundColor: UIColor) {
        self.height = height
        super.init()
        self.backgroundColor = backgroundColor
        addSubview(imageView)
    }
    
    override var intrinsicContentSize: CGSize {
      return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
}

final class LabelStackCell: UIView {
  
  private let label = UILabel()
  
  init(title: String) {
    super.init(frame: .zero)
    
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8).isActive = true
    label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 8).isActive = true
    label.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
    label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.text = title
  }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class buttonStackCell: UIView {
  
    var tapped: () -> Void = {}
  
    private let button = UIButton(type: .system)
  
    init(title: String) {
        super.init(frame: .zero)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8).isActive = true
        button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 8).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitleColor(.red, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped() {
      tapped()
    }
}
