//
//  CustomAlertControllerMainContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-04.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

final class CustomAlertControllerMainContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        // translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.red.withAlphaComponent(0.7)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

import Foundation


final class ModalController : UIViewController {
    
    let modalViewDataSource : [CGFloat] = [4, 5, 10, 5, 1, 15]
    
    lazy var modalView : ModalView = {
        let view = ModalView(frame: .zero)
        view.dataSource = self.modalViewDataSource
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(modalView)
        modalView.translatesAutoresizingMaskIntoConstraints = false
        modalView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        modalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        modalView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        modalView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = constant
            self.layoutIfNeeded()
        }
    }
}

final class ModalView : UIView {
    
    var dataSource : [CGFloat]? = []
    var counter = 0
    
    let nextButton : UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Next", for: .normal)
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupViews()
    }
    
    func setupViews () {
        self.backgroundColor = .red
        self.addSubview(nextButton)
        nextButton.anchor(top: self.topAnchor, leading: nil, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 100, height: 50))
        nextButton.addTarget(self, action: #selector(self.changeHeight), for: .touchUpInside)
    }
    
    @objc func changeHeight (sender: UIButton) {
        guard let dataSource = self.dataSource else {return}
        let height = dataSource[counter] * 50
        self.updateConstraint(attribute: NSLayoutConstraint.Attribute.height, constant: height)
        if self.counter < dataSource.count - 1 {
            self.counter += 1
        }
    }
}
