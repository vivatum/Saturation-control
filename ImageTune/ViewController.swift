//
//  ViewController.swift
//  ImageTune
//
//  Created by Vivatum on 6/17/17.
//  Copyright © 2017 vivatum. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AlertProtocol, SaturationControlProtocol, ImageHandlerProtocol {
    
    static let ui_log = OSLog(subsystem: "com.vivatum.ImageTune", category: "UI")
    
    @IBOutlet weak var monitorImageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var toolNameLabel: UILabel!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var imageDidOpen: Bool = false
    var imageDidEdit: Bool = false
    
    var baseImage: UIImage? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    
    // MARK: - IBAction methods
    
    @IBAction func openImageAction(_ sender: Any) {
        
        _ = imageDidEdit ? discardChangesAlert(titleWord: "Open", action: openImagePicker) : openImagePicker()
        os_log("Open button was tapped", log: ViewController.ui_log, type: .info)
    }
    
    @IBAction func discardChangesAction(_ sender: Any) {
        
        discardChangesAlert(titleWord: "Discard", action: resetFilter)
        os_log("Discard button was tapped", log: ViewController.ui_log, type: .info)
    }
    
    @IBAction func saveAction(_ sender: Any) {
     
        guard let imageForSave = monitorImageView.image, let imageData = UIImageJPEGRepresentation(imageForSave, 0.6), let compressedJPGImage = UIImage(data: imageData) else {
            os_log("Cen't get image for save", log: ViewController.ui_log, type: .info)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        os_log("Save button was tapped", log: ViewController.ui_log, type: .info)
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        
        filterApplying(factor: sender.value)
        os_log("Slider value changed: %.02f", log: ViewController.ui_log, type: .info, sender.value)
    }
    
    
    // MARK: - CIFilter applying
    
    private func filterApplying(factor: Float) {
        
        guard let filteredImage = saturationFilter(baseImage: baseImage, factor: factor) else {
            os_log("Can't apply filter", log: ViewController.ui_log, type: .info)
            return
        }
        
        monitorImageView.image = filteredImage
        
        os_log("Saturation was changed: factor %.02f", log: ViewController.ui_log, type: .info, factor)
        
        // setup view
        self.imageDidEdit = true
        self.setupView()
    }
    
    
    // MARK: - Helper methods
    
    private func setupView() {
        
        DispatchQueue.main.async {
            
            self.saveButton.isEnabled = self.imageDidEdit
            self.saveButton.alpha = self.imageDidEdit ? 1 : 0.3
            
            self.discardButton.isEnabled = self.imageDidEdit
            self.discardButton.alpha = self.imageDidEdit ? 1 : 0.3
            
            self.slider.isEnabled = self.imageDidOpen
            self.slider.alpha = self.imageDidOpen ? 1 : 0.3
            
            self.toolNameLabel.alpha = self.imageDidOpen ? 1 : 0.3
        }
        
        os_log("View' elements were setuped", log: ViewController.ui_log, type: .info)
    }
    
    private func resetFilter() {
        
        // reset filter
        filterApplying(factor: 1.0)
        
        // reset slider
        DispatchQueue.main.async {
            self.slider.setValue(1.0, animated: true)
        }
        
        // setup view
        imageDidEdit = false
        setupView()
        
        os_log("Filter was reseted", log: ViewController.ui_log, type: .info)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            
            imageDidOpen = false
            os_log("Something wrong", log: ViewController.ui_log, type: .debug)
            return
        }
        
        monitorImageView.image = pickedImage
        baseImage = pickedImage
        imageDidOpen = true
        os_log("Image was opened", log: ViewController.ui_log, type: .info)
        
        picker.dismiss(animated: true, completion: nil)
        setupView()
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            os_log("BaseImage updated process error: %@", log: ViewController.ui_log, type: .info, error.localizedDescription)
            present(ac, animated: true)
            
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                
                // update baseImage
                self.baseImage = image
                self.resetFilter()
                os_log("BaseImage was updated", log: ViewController.ui_log, type: .info)
            })
            
            ac.addAction(okAction)
            present(ac, animated: true)
        }
    }
}
