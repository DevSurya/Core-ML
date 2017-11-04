//
//  ViewController.swift
//  CoreMLVision
//
//  Created by Surya on 11/3/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    private var imagePicker = UIImagePickerController()
    
    private var model = GoogLeNetPlaces()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var imageInfoPredictionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            return
        }
        self.photoImageView.image = pickedImage
        processImage(image: pickedImage)
    }
    
    @IBAction func openPhotoLibrary(_ sender: UIBarButtonItem) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    private func processImage(image :UIImage){
        
        guard let ciImage = CIImage.init(image: image) else{
            fatalError("unable to create vision model")
        }
        
        guard let visionModel = try? VNCoreMLModel.init(for: self.model.model) else {
            fatalError("unable to create vision model")
        }
        
        let visionRequest = VNCoreMLRequest.init(model: visionModel) { (request, error) in
            
            if error != nil {
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            let classification = results.map { observation in
                "\(observation.identifier) \(observation.confidence * 100)"
            }
            
            DispatchQueue.main.async {
                self.imageInfoPredictionTextView.text = classification.joined(separator: "\n")
            }
            
        }
        
        let visionRequestHandler = VNImageRequestHandler.init(ciImage: ciImage, orientation: .up, options: [:])
        
        DispatchQueue.global(qos: .userInteractive).async {
            try! visionRequestHandler.perform([visionRequest])
        }
    }
}

