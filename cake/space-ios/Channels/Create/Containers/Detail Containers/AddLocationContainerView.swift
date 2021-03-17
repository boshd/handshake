//
//  AddLocationContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class AddLocationContainerView: UIView {
    
    var resultSearchController: UISearchController? = nil
    
    let locationSearchTable = LocationSearchTable()
    
    var mapView: MKMapView = {
        var mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    let doneButton: RoundButton = {
        let button = RoundButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.setTitleColor(ThemeManager.currentTheme().buttonIconColor, for: .normal)
        button.setTitle("Done", for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        
        searchBar.placeholder = "Search places"
        searchBar.backgroundColor = .clear
        searchBar.setTextColor(color: .black)
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        locationSearchTable.mapView = mapView
        
        addSubview(mapView)
        addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -170),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 80),
            doneButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - UISearchBar EXTENSION
    extension UISearchBar {

        private func getViewElement<T>(type: T.Type) -> T? {

            let svs = subviews.flatMap { $0.subviews }
            guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
            return element
        }

        func getSearchBarTextField() -> UITextField? {
            return getViewElement(type: UITextField.self)
        }

        func setTextColor(color: UIColor) {

            if let textField = getSearchBarTextField() {
                textField.textColor = color
            }
        }

        func setTextFieldColor(color: UIColor) {

            if let textField = getViewElement(type: UITextField.self) {
                switch searchBarStyle {
                case .minimal:
                    textField.layer.backgroundColor = color.cgColor
                    textField.layer.cornerRadius = 6
                case .prominent, .default:
                    textField.backgroundColor = color
                }
            }
        }

        func setPlaceholderTextColor(color: UIColor) {

            if let textField = getSearchBarTextField() {
                textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
            }
        }

        func setTextFieldClearButtonColor(color: UIColor) {

            if let textField = getSearchBarTextField() {

                let button = textField.value(forKey: "clearButton") as! UIButton
                if let image = button.imageView?.image {
                    button.setImage(image.transform(withNewColor: color), for: .normal)
                }
            }
        }

        func setSearchImageColor(color: UIColor) {

            if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
                imageView.image = imageView.image?.transform(withNewColor: color)
            }
        }
    }



extension UIImage {

    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)

        color.setFill()
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
