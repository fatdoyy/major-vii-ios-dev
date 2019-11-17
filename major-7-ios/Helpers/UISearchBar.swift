//
//  UISearchBar.swift
//  major-7-ios
//
//  Created by jason on 17/11/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UISearchBar {
    private var textField: UITextField? {
        let subViews = self.subviews.flatMap { $0.subviews }
        if #available(iOS 13, *) {
            if let _subViews = subViews.last?.subviews {
                return (_subViews.filter { $0 is UITextField }).first as? UITextField
            }else{
                return nil
            }
            
        } else {
            return (subViews.filter { $0 is UITextField }).first as? UITextField
        }
        
    }
    
    private var searchIcon: UIImage? {
        let subViews = subviews.flatMap { $0.subviews }
        return  ((subViews.filter { $0 is UIImageView }).first as? UIImageView)?.image
    }
    
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
            @unknown default:
                break
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }
    
    private var activityIndicator: NVActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? NVActivityIndicatorView }.first
    }
    
    // Public API
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            let _searchIcon = searchIcon
            if newValue {
                if activityIndicator == nil {
                    let _activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 12, height: 12)), type: .lineScale)
                    _activityIndicator.startAnimating()
                    let clearImage = UIImage().imageWithPixelSize(size: CGSize.init(width: 19.5, height: 16)) ?? UIImage()
                    self.setImage(clearImage, for: .search, state: .normal)
                    textField?.leftViewMode = .always
                    textField?.leftView?.addSubview(_activityIndicator)
                    let leftViewSize = CGSize.init(width: 16, height: 16)
                    _activityIndicator.center = CGPoint(x: leftViewSize.width / 2, y: leftViewSize.height / 2)
                }
            } else {
                self.setImage(_searchIcon, for: .search, state: .normal)
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
