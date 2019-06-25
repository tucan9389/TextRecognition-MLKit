//
//  ViewController.swift
//  TextRecognition-MLKit
//
//  Created by GwakDoyoung on 21/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import UIKit
import CoreMedia
import CoreImage
import Firebase

class MainVideoViewController: UIViewController {

    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var logLabel: UILabel!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    // MARK: - ML Kit Vision Property
    lazy var vision = Vision.vision()
    lazy var textRecognizer = vision.onDeviceTextRecognizer()
    var isInference = false
    
    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup camera
        setUpCamera()
        
        // setup delegate for performance measurement
        👨‍🔧.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate
extension MainVideoViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if !self.isInference, let pixelBuffer = pixelBuffer {
            // start of measure
            self.👨‍🔧.🎬👏()
            
            self.isInference = true
            
            // predict!
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

extension MainVideoViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        let ciimage: CIImage = CIImage(cvImageBuffer: pixelBuffer)
        // crop found word
        let ciContext = CIContext()
        guard let cgImage: CGImage = ciContext.createCGImage(ciimage, from: ciimage.extent) else {
            self.isInference = false
            // end of measure
            self.👨‍🔧.🎬🤚()
            return
        }
        let uiImage: UIImage = UIImage(cgImage: cgImage)
        let visionImage = VisionImage(image: uiImage)
        textRecognizer.process(visionImage) { (features, error) in
            self.👨‍🔧.🏷(with: "endInference")
            // this closure is called on main thread
            if error == nil, let features: VisionText = features {
                self.drawingView.imageSize = uiImage.size
                self.drawingView.visionText = features
            } else {
                self.drawingView.imageSize = .zero
                self.drawingView.visionText = nil
            }
            
            self.showNumberOfBlocks(features: features)
            
            self.isInference = false
            // end of measure
            self.👨‍🔧.🎬🤚()
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
}

// MARK: - 📏(Performance Measurement) Delegate
extension MainVideoViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        self.inferenceLabel.text = "inference: \(Int(inferenceTime*1000.0)) mm"
        self.etimeLabel.text = "execution: \(Int(executionTime*1000.0)) mm"
        self.fpsLabel.text = "fps: \(fps)"
    }
}
