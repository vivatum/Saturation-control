//
//  AppController.swift
//  ImageTune
//
//  Created by Vivatum on 6/19/17.
//  Copyright © 2017 vivatum. All rights reserved.
//

import UIKit
import os.log


let pop_log = OSLog(subsystem: "com.vivatum.ImageTune", category: "POP")


    // MARK: - ImagePicker controller

protocol ImageHandlerProtocol: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openImagePicker()
}

extension ImageHandlerProtocol where Self: UIViewController {
    
    func openImagePicker() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        os_log("ImagePicker OK", log: pop_log, type: .info)
    }
}


    // MARK: - CIFilter saturation control

protocol SaturationControlProtocol {
    func saturationFilter(baseImage: UIImage?, factor: Float) -> UIImage?
}

extension SaturationControlProtocol {
    
    func saturationFilter(baseImage: UIImage?, factor: Float) -> UIImage? {
        
        guard let bsImage = baseImage else {
            os_log("Can't get the baseImage", log: pop_log, type: .info)
            return nil
        }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setDefaults()
        filter?.setValue(CIImage(image: bsImage), forKey: kCIInputImageKey)
        filter?.setValue(factor, forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter?.outputImage, let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            
            os_log("Can't get outputImage", log: pop_log, type: .info)
            return nil
        }
        
        os_log("Saturation was changed: factor %.02f", log: pop_log, type: .info, factor)
        
        return UIImage(cgImage: cgImage, scale: bsImage.scale, orientation: bsImage.imageOrientation)
    }
}


// MARK: - UIAlertController protocol

protocol AlertProtocol {
    func discardChangesAlert(titleWord: String, action: @escaping ()->())
}

extension AlertProtocol where Self: UIViewController {
    
    func discardChangesAlert(titleWord: String, action: @escaping ()->()) {
        
        let alertController = UIAlertController(title: "Do you really want to \(titleWord.lowercased())?", message: "All changes will be lost!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            os_log("DiscardChanges alert: Cancel pressed", log: pop_log, type: .info)
        }
        
        
        let titleAction = UIAlertAction(title: titleWord, style: .destructive, handler: { _ in
            action()
            os_log("DiscardChanges alert: %@ pressed", log: pop_log, type: .info, titleWord)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(titleAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}



extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
