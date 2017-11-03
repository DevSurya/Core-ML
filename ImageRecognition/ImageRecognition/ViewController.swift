//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Surya on 11/3/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var outputLabel: UILabel!
    
    let imageArray = ["apple.jpg","banana.jpeg","cat.jpeg","rat.jpg"]
    var index = 0
    
    
    private var model :Inceptionv3 = Inceptionv3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nextButton.layer.cornerRadius = 4.0
        nextButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        if index >= imageArray.count {
            index = 0
        }
        let img = UIImage.init(named: imageArray[index])
        self.pictureImageView.image = img
        
        // resize image to a particular size
        let resizeImage = img?.resizeTo(size: CGSize.init(width: 299, height: 299))
        
        let buffer = resizeImage?.toBuffer()
        
        let predeiction = try! self.model.prediction(image: buffer!)
        
        self.outputLabel.text = predeiction.classLabel
        
        // model wont take input as UIImage
//        self.model.prediction(image: <#T##CVPixelBuffer#>)
        
        
        index += 1
    }
    
}

