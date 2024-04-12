//
//  ViewController.swift
//  animalClassifier
//
//  Created by GurPreet SaiNi on 2024-04-12.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            imgView.image = userPickedImage
            
            guard let ciImg = CIImage(image: userPickedImage) else{
                fatalError("Error converting UIImg to CIImg!")
            }
            
            detect(image: ciImg)
        }
        imagePicker.dismiss(animated: true)
    }

    @IBAction func btnCameraTouchUp(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
    func detect(image: CIImage){
        
        guard let model = try? MyImageClassifier(configuration: MLModelConfiguration()).model else{
            fatalError("Model configuration error.")
        }

        //loading model
        // Create a Vision instance using the image classifier's model instance.
        guard let visionModel = try? VNCoreMLModel(for: model) else{
            fatalError("Loading CoreML model failed!")
        }
        
        //creating a request
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            //need the result to be a VNClassificationObservation
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image.")
            }
//            print(results.first)
            
            if let firstResult = results.first{
                
                self.navigationItem.title = firstResult.identifier + " - " + String(format: "%.2f",firstResult.confidence * 100) + "%"
                print(firstResult.description)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print("Error: \(error)")
        }
    }
}

