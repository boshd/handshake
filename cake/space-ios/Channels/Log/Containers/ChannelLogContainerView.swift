//
//  ChannelLogContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
//import InputBarAccessoryView

class ChannelLogContainerView: UIView {
    
    let channelLogHeaderView = ChannelLogHeaderView()
    
    let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        return backgroundView
    }()
    
    let participantsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: ScreenSize.width - 20, height: 100)
        let participantsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        participantsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        participantsCollectionView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        return participantsCollectionView
    }()

    let collectionViewContainer: UIView = {
        let collectionViewContainer = UIView()
        collectionViewContainer.translatesAutoresizingMaskIntoConstraints = false
        return collectionViewContainer
    }()
    
    let inputContainerSafeAreaView: UIView = {
        let inputContainerSafeAreaView = UIView()
        inputContainerSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerSafeAreaView.backgroundColor = .cyan

        return inputContainerSafeAreaView
    }()
    
    let inputViewContainer: BlurView = {
        let inputViewContainer = BlurView()
        inputViewContainer.translatesAutoresizingMaskIntoConstraints = false
        inputViewContainer.blurEffectView = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
        inputViewContainer.backgroundColor = ThemeManager.currentTheme().inputBarContainerViewBackgroundColor
        return inputViewContainer
    }()
    
    var refreshControl: UIRefreshControl = {
        var refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(ChannelLogController.performRefresh), for: .valueChanged)
      
        return refreshControl
    }()
    
    let transparentView: BlurView = {
        let view = BlurView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var headerHeightConstraint: NSLayoutConstraint?
    var headerTopConstraint: NSLayoutConstraint?
    var bottomConstraint_: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        addSubview(collectionViewContainer)
        addSubview(inputViewContainer)
        addSubview(transparentView)
        addSubview(backgroundView)
        addSubview(channelLogHeaderView)
        
//        channelLogHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        channelLogHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7).isActive = true
        channelLogHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7).isActive = true
        headerHeightConstraint = channelLogHeaderView.heightAnchor.constraint(equalToConstant: 65)
        headerHeightConstraint?.isActive = true
        
        headerTopConstraint = channelLogHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5)
        headerTopConstraint?.isActive = true
        
        backgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: inputViewContainer.bottomAnchor).isActive = true
        
        collectionViewContainer.topAnchor.constraint(equalTo: channelLogHeaderView.bottomAnchor).isActive = true
        if #available(iOS 11.0, *) {
            collectionViewContainer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
            collectionViewContainer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            collectionViewContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            collectionViewContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }

        if #available(iOS 11.0, *) {
            inputViewContainer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
            inputViewContainer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            inputViewContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            inputViewContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        bottomConstraint_ = inputViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        collectionViewContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
//        inputViewContainer.topAnchor.constraint(equalTo: collectionViewContainer.bottomAnchor).isActive = true
    }
    
    func add(_ collectionView: UICollectionView) {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewContainer.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: collectionViewContainer.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: collectionViewContainer.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: collectionViewContainer.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionViewContainer.bottomAnchor).isActive = true
    }
    
    func blockBottomConstraint(constant: CGFloat) {
        bottomConstraint_.constant = constant
        bottomConstraint_.isActive = true
    }
    
    func unblockBottomConstraint() {
        bottomConstraint_.isActive = false
    }
    
    func add(_ inputView: UIView) {
        for subview in inputViewContainer.subviews
        where subview is InputContainerView {
            subview.removeFromSuperview()
        }

        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputViewContainer.addSubview(inputView)
        inputView.topAnchor.constraint(equalTo: inputViewContainer.topAnchor).isActive = true
        inputView.leftAnchor.constraint(equalTo: inputViewContainer.leftAnchor).isActive = true
        inputView.rightAnchor.constraint(equalTo: inputViewContainer.rightAnchor).isActive = true
        inputView.bottomAnchor.constraint(equalTo: inputViewContainer.bottomAnchor).isActive = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
