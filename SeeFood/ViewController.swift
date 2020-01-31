//
//  ViewController.swift
//  SeeFood
//
//  Created by sayali on 30/01/20.
//  Copyright © 2020 sayali. All rights reserved.
//

import UIKit
import CoreML
import Vision
class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var imagepicker = UIImagePickerController()
    @IBOutlet var img: UIImageView!
    @IBOutlet var btncamera: UIBarButtonItem!
   var model: Inceptionv3!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagepicker.delegate = self
        imagepicker.sourceType = .photoLibrary
        imagepicker.allowsEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
          model = Inceptionv3()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagepicker.dismiss(animated: true)
       
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        img.image = newImage
        
        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
            return
        }
        print(prediction.classLabel)
      
        self.navigationItem.title = "I think this is a \(prediction.classLabel)."
        //classifier.text = "I think this is a \(prediction.classLabel)."
        
        
      //  imagepicker.dismiss(animated: true, completion: nil)
    }
    
    
//    func detecte(image : CIImage)  {
//       guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else
//       {
//        fatalError("loding coreML model fail")
//        }
//        
//        var request = VNCoreMLRequest(model: model)
//        {(request, error) in
//            guard let result = request.results as? [VNClassificationObservation]
//            else
//            {
//                fatalError("problem n request creation")
//            }
//            print(result)
//            }
//        let handler = VNImageRequestHandler(ciImage: image)
//        do{
//            try handler.perform([request])
//        }
//        catch{
//            print(Error.self)
//        }
//        
//        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
//            return
//        }
//        
//        classifier.text = "I think this is a \(prediction.classLabel)."
//    }
    
    @IBAction func btncameraClicked(_ sender: UIBarButtonItem) {
        present(imagepicker, animated: true, completion: nil)
    }
    
    
}

