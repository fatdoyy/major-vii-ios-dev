//
//  UIImage.swift
//  major-7-ios
//
//  Created by jason on 22/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

//make image grayscale
extension UIImage {
    var tonalFilter: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectTonal") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}

//MARK: Scale image for UICollectionView
extension UIImage {
    func scaleImage(maxWidth: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let cgImage: CGImage = self.cgImage!.cropping(to: rect)!
        
        return UIImage(cgImage: cgImage, scale: size.width / maxWidth, orientation: imageOrientation)
    }
}
