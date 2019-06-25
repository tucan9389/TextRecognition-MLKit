//
//  StaticImageViewController.swift
//  TextRecognition-MLKit
//
//  Created by Doyoung Gwak on 25/06/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import UIKit
import CoreMedia
import CoreImage
import Firebase

class StaticImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var logLabel: UILabel!
    
    @IBOutlet weak var drawingViewAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var drawingViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: - ML Kit Vision Property
    lazy var vision = Vision.vision()
    lazy var textRecognizer = vision.onDeviceTextRecognizer()
    var visionText: VisionText?
    
    // MARK: - Image Picker
    var picker: UIImagePickerController?
    @IBOutlet weak var textItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoTextViewController", let vc = segue.destination as? TextViewController {
            let text = getCSV(visionText: visionText)
            vc.text = text
        }
    }
    
    @IBAction func tapCamera(_ sender: Any) {
        // TODO
        if picker == nil {
            picker =  UIImagePickerController()
            picker?.sourceType = .photoLibrary
            picker?.delegate = self
        }
        
        if let picker = picker {
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func updateImage(image: UIImage) {
        imageView.image = image
        
        // predict!!
        predictUsingVision(image: image)
    }
    
    func predictUsingVision(image: UIImage) {
        let visionImage = VisionImage(image: image)
        textRecognizer.process(visionImage) { (features, error) in
            // this closure is called on main thread
            if error == nil, let features: VisionText = features {
                self.visionText = features
                self.drawingView.imageSize = image.size
                self.drawingView.visionText = features
                self.textItem.isEnabled = true
            } else {
                self.visionText = nil
                self.drawingView.imageSize = .zero
                self.drawingView.visionText = nil
                self.textItem.isEnabled = false
            }
            
            self.showNumberOfBlocks(features: features)
        }
    }
    
    func showNumberOfBlocks(features: VisionText?) {
        guard let features = features else {
            logLabel.text = "N/A"
            return
        }
        let blockCount = features.blocks.count
        let lineCount = features.blocks.reduce(0, {$0 + $1.lines.count})
        let elementCount = features.blocks.reduce(0, {$0 + $1.lines.reduce(0, {$0 + $1.elements.count})})
        logLabel.text = "Block Count\t\t: \(blockCount)\n" + "Line Count\t\t: \(lineCount)\n" + "Element Count\t\t: \(elementCount)\n"
    }
    
    func getCSV(visionText: VisionText?) -> String? {
        guard let visionText = visionText else { return nil }
        
//        // need to improve
//        var elements: [VisionTextElement] = visionText.blocks.reduce([]) { blockResult, block in
//            blockResult + block.lines.reduce([]) { lineResult, line in
//                lineResult + line.elements
//            }
//        }
        
        return visionText.blocks.reduce("") { blockResult, block in
            blockResult + block.lines.reduce("") { lineResult, line in
                lineResult + line.elements.reduce("") { elementResult, element in
                    elementResult + element.text + ", "
                } + "\n"
            }
        }
    }
}

extension StaticImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        updateImage(image: image)
    }
}
