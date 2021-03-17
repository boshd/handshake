//
//  ProfileController+NameEditing.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-22.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

extension ProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneBarButtonPressed()
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileController: UITextViewDelegate {
    func estimateFrameForText(_ text: String, width: CGFloat) -> CGRect {
        let size = CGSize(width: width, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil).integral
    }
    
    func tableHeaderHeight() -> CGFloat {
        return 190 + estimateFrameForText(userProfileContainerView.bio.text, width: userProfileContainerView.bio.textContainer.size.width - 10).height
    }
    
    func tableFooterHeight() -> CGFloat {
        return 150
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setEditingBarButtons()
        userProfileContainerView.bioPlaceholderLabel.isHidden = true
        userProfileContainerView.countLabel.text = "\(userProfileContainerView.bioMaxCharactersCount - userProfileContainerView.bio.text.count)"
        userProfileContainerView.countLabel.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        userProfileContainerView.bioPlaceholderLabel.isHidden = !textView.text.isEmpty
        userProfileContainerView.countLabel.isHidden = true
    }

    func textViewDidChange(_ textView: UITextView) {
        view.setNeedsLayout()
        if textView.isFirstResponder && textView.text == "" {
            userProfileContainerView.bioPlaceholderLabel.isHidden = true
        } else {
            userProfileContainerView.bioPlaceholderLabel.isHidden = !textView.text.isEmpty
        }
        userProfileContainerView.countLabel.text = "\(userProfileContainerView.bioMaxCharactersCount - textView.text.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            doneBarButtonPressed()
            return false
        }

        return textView.text.count + (text.count - range.length) <= userProfileContainerView.bioMaxCharactersCount
    }

}

extension ProfileController { /* user name editing */

    @objc func nameDidBeginEditing() {
        setEditingBarButtons()
    }
    
    @objc func nameEditingChanged() {
        if userProfileContainerView.name.text!.count == 0 ||
        userProfileContainerView.name.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            doneBarButton.isEnabled = false
        } else {
            doneBarButton.isEnabled = true
        }
    }
    
    func setEditingBarButtons() {
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    @objc func cancelBarButtonPressed() {
        userProfileContainerView.name.text = currentName
        userProfileContainerView.bio.text = currentBio
        userProfileContainerView.name.resignFirstResponder()
        userProfileContainerView.bio.resignFirstResponder()
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = nil
        view.setNeedsLayout()
    }
    
    @objc func doneBarButtonPressed() {
        if currentReachabilityStatus == .notReachable {
            basicErrorAlertWith(title: noInternetError, message: noInternetError, controller: self)
            return
        }

        globalIndicator.show()
        self.view.isUserInteractionEnabled = false
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = nil
        userProfileContainerView.name.resignFirstResponder()
        userProfileContainerView.bio.resignFirstResponder()

        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData([
            "name": userProfileContainerView.name.text!,
            "bio": userProfileContainerView.bio.text!
        ]) { (error) in
            if error != nil {
                globalIndicator.dismiss()
                self.view.isUserInteractionEnabled = true
            }
            userDefaults.updateObject(for: userDefaults.currentUserName, with: self.userProfileContainerView.name.text!)
            globalIndicator.showSuccess(withStatus: nil)
            self.view.isUserInteractionEnabled = true
        }
    }
    
}

