//
//  UIImage.swift
//  major-7-ios
//
//  Created by jason on 22/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import Kingfisher

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

//kingfisher imageprocessor
struct tonalFilter: CIImageProcessor {
    
    let identifier = "myCIFilter"
    
    let filter = Filter { input in
        guard let filter = CIFilter(name: "CIPhotoEffectTonal") else { return nil }
        filter.setValue(input, forKey: kCIInputImageKey)
        return filter.outputImage
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

//Rotate image
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        /*  .pi = rotate 180 degrees
            .pi/2 = rotate 90 degrees
         */
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
