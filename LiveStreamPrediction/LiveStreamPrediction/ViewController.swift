//
//  ViewController.swift
//  LiveStreamPrediction
//
//  Created by Surya on 11/4/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Vision
import CoreML
import AVFoundation

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    private let inceptionModel = Inceptionv3()
    private var requests = [VNCoreMLRequest]()
    
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createImageRequest()
        startLiveVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func startLiveVideo() {
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        let capturedevice = AVCaptureDevice.default(for: .video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: capturedevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
    
    private func createImageRequest() {
        
        guard let model = try? VNCoreMLModel(for: self.inceptionModel.model) else {
            fatalError("problem creating request using core ml model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            if error != nil {
                return
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else {
                return
            }
            
            let classifications = observations.map { observation in
                "\(observation.identifier) \(observation.confidence * 100.0)"
            }
            
            DispatchQueue.main.async {
                self.textView.text = classifications.joined(separator: "\n")
            }
            
            print(observations)
            
        }
        
        self.requests.append(request)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
}

