/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The implementation of the application's view controller, responsible for coordinating
 the user interface, video feed, and PoseNet model.
*/

import AVFoundation
import UIKit
import VideoToolbox
import OrderedCollections


import UIKit
import AVKit
import Vision

//crops the body? to identify gender

class ViewController: UIViewController {
    /// The view the controller uses to visualize the detected poses.
    @IBOutlet private var previewImageView: PoseImageView!
    

   
    var thedict: OrderedDictionary<String, String> = [:]
 
 
   
    @IBOutlet weak var sitcountlabel: UILabel!
    @IBOutlet weak var standcountlabel: UILabel!
    let layer = CAShapeLayer()
    @IBOutlet weak var posecountlabel: UILabel!
    let captureSession = AVCaptureSession()
    var origin = CGPoint(x:0, y:0)
    var size = CGSize(width:0, height:0)
    

    
    
    @IBOutlet weak var agelabel: UILabel!
    @IBOutlet weak var genderlabel: UILabel!
    
   
    private let videoCapture = VideoCapture()
    private var drawings: [CAShapeLayer] = []
    private var poseNet: PoseNet!
    var faceView: FaceView?
  
    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    /// The algorithm the controller uses to extract poses from the current frame.
    private var algorithm: Algorithm = .multiple

    /// The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()

    private var popOverPresentationManager: PopOverPresentationManager?
   
    var i = 1
    var j = 0
    var k = 0
    var result = "undetected"
    var nosex = 0
    var nosey = 0
    var bodyx = 0
    var bodyy = 0
   
    var bodycoord = ""
    var sequenceHandler = VNSequenceRequestHandler()
    
    var bstring = ""
    var tstring = ""
    var blist = [String]()
    var rlist = [String]()
    var glist = [String]()
    var alist = [String]()
    
   
    
    var rect = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // For convenience, the idle timer is disabled to prevent the screen from locking.
     UIApplication.shared.isIdleTimerDisabled = true

        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
        super.viewDidLoad()
      
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }
           // self.captureSession.startRunning()
            self.videoCapture.delegate = self

            self.videoCapture.startCapturing()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }

    @IBAction func printbutton(_ sender: Any) {
        print(thedict)
    }
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }

    @IBAction func onAlgorithmSegmentValueChanged(_ sender: UISegmentedControl) {
        guard let selectedAlgorithm = Algorithm(
            rawValue: sender.selectedSegmentIndex) else {
                return
        }

        algorithm = selectedAlgorithm
    }

}

// MARK: - Navigation

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let uiNavigationController = segue.destination as? UINavigationController else {
            return
        }
        guard let configurationViewController = uiNavigationController.viewControllers.first
            as? ConfigurationViewController else {
                    return
        }

        configurationViewController.configuration = poseBuilderConfiguration
        configurationViewController.algorithm = algorithm
        configurationViewController.delegate = self

        popOverPresentationManager = PopOverPresentationManager(presenting: self,
                                                                presented: uiNavigationController)
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = popOverPresentationManager
    }
}

// MARK: - ConfigurationViewControllerDelegate

extension ViewController: ConfigurationViewControllerDelegate {
    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateConfiguration configuration: PoseBuilderConfiguration) {
        poseBuilderConfiguration = configuration
    }

    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateAlgorithm algorithm: Algorithm) {
        self.algorithm = algorithm
    }
}

// MARK: - VideoCaptureDelegate

extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
        
       
    }
    
  
    
    func detectGender(_ image: CGImage) { //runs
             //  genderlabel.text = "nil"
               guard let model = try? VNCoreMLModel(for: genderset1().model) else {
                    fatalError("can't load Gender model")
               }
               // Create request for Vision Core ML model created
               let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                   guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                         fatalError("unexpected result type from VNCoreMLRequest")
                       
                   }
                
                   self?.glist.append(topResult.identifier)
                   Dispatch.DispatchQueue.main.async { [weak self] in
                    //   self?.genderlabel.text = topResult.identifier
                       
                 
                       }
                   
                   }
        
        

              // Run the Core ML AgeNet classifier on global dispatch queue
              let handler = VNImageRequestHandler(cgImage: image)
                    DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try handler.perform([request])
                    } catch {
                        print(error)
                        return
                    }
              }
      }
    
    func detectAge(_ image: CGImage) { //runs
              
               guard let model = try? VNCoreMLModel(for: ageset2().model) else {
                    fatalError("can't load AgeNet model")
               }
               // Create request for Vision Core ML model created
               let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                   guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                         fatalError("unexpected result type from VNCoreMLRequest")
                   }

                   // Update UI on main queue
                   self?.alist.append(topResult.identifier)
                   Dispatch.DispatchQueue.main.async { [weak self] in
                   //    self?.agelabel.text = topResult.identifier
                       
                       }
                   }
        
              // Run the Core ML AgeNet classifier on global dispatch queue
              let handler = VNImageRequestHandler(cgImage: image)
                    DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try handler.perform([request])
                    } catch {
                        print(error)
                        return
                    }
              }
      }
   
    }



// MARK: - PoseNetDelegate

extension ViewController: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }

        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = algorithm == .single
            ? [poseBuilder.pose]
            : poseBuilder.poses

        previewImageView.show(poses: poses, on: currentFrame)
        
      
        let date = Date()

        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "y-M-d, HH:mm:ss"

        // Convert Date to String
        let key = dateFormatter.string(from: date)

       var posecount = 0
        var standcount = 0
        var sitcount = 0
       
        var nosedot: CGPoint
     
        layer.removeFromSuperlayer()
   
        for pose in poses{
            
           
           
            nosedot = pose[.nose].position
           
            let lefteye2righteye = (pose[.leftEye].position.distance(to:pose[.rightEye].position))
           // let nose2righteye = (pose[.nose].position.distance(to:pose[.rightEye].position))
           
            origin = CGPoint(x: nosedot.x * 0.6 , y: nosedot.y * 1.1) //to make it center at the nose
            //size = CGSize(width: 100, height: 100)
            size = CGSize(width: 5 * lefteye2righteye, height: 5 * lefteye2righteye)
            let rect = CGRect(origin: origin, size: size)
         
            
            
            layer.frame = CGRect(origin: origin, size: size) //print box over head (but only one box at a time)
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 2
            previewImageView.layer.addSublayer(layer)
       
      
            var croppedImage: CGImage
          
                
            croppedImage = cropImage1(image: currentFrame, rect: rect)
            
           
            self.detectGender(croppedImage)
            self.detectAge(croppedImage)
          
        
          posecount += 1
                
                bodyy = Int(Double(pose[.leftShoulder].position.y + pose[.leftHip].position.y)/2.0)
                bodyx = Int(Double(pose[.leftShoulder].position.x + pose[.rightShoulder].position.x)/2.0)
                bodycoord = "(\(bodyx),\(bodyy))"
              
                blist.append(bodycoord)
          print(blist)
                
            
            
         
            //declarations
                        let LShldr2Hip = pose[.leftShoulder].position.distance(to:pose[.leftHip].position)
                        let LAnk2Hip = pose[.leftAnkle].position.distance(to:pose[.leftHip].position)
                        let RShldr2Hip = pose[.rightShoulder].position.distance(to:pose[.rightHip].position)
                        let RAnk2Hip = pose[.rightAnkle].position.distance(to:pose[.rightHip].position)
                        let RHip2KneeAngle = atan2(pose[.rightHip].position.y - pose[.rightKnee].position.y, pose[.rightHip].position.x - pose[.rightKnee].position.x)
                        let LHip2KneeAngle = atan2(pose[.leftHip].position.y - pose[.leftKnee].position.y, pose[.leftHip].position.x - pose[.leftKnee].position.x)
                        
                        let RKnee2AnkAngle = atan2(pose[.rightKnee].position.y - pose[.rightAnkle].position.y, pose[.rightKnee].position.x - pose[.rightAnkle].position.x)
                        
                        let LKnee2AnkAngle = atan2(pose[.leftKnee].position.y - pose[.leftAnkle].position.y, pose[.leftKnee].position.x - pose[.leftAnkle].position.x)
                        let LKnee2Hip = pose[.leftKnee].position.distance(to:pose[.leftHip].position)
                        let LAnk2Knee = pose[.leftAnkle].position.distance(to:pose[.leftKnee].position)
                        let RKnee2Hip = pose[.rightKnee].position.distance(to:pose[.rightHip].position)
                        let RAnk2Knee = pose[.rightAnkle].position.distance(to:pose[.rightKnee].position)
                        let RShldr2HipAngle = atan2(pose[.rightShoulder].position.y - pose[.rightHip].position.y, pose[.rightShoulder].position.x - pose[.rightHip].position.x)
                        let LShldr2HipAngle = atan2(pose[.leftShoulder].position.y - pose[.leftHip].position.y, pose[.leftShoulder].position.x - pose[.leftHip].position.x)
                        
                
                        // Hip to Knee and Shoulder to Hip
                        var RangleHipRadians = RHip2KneeAngle - RShldr2HipAngle
                        while RangleHipRadians < 0 {
                            RangleHipRadians += CGFloat(2 * Double.pi)}
                        let RangleHipDegree = Int(RangleHipRadians * 180 / .pi)
                        
                        var LangleHipRadians = LHip2KneeAngle - LShldr2HipAngle
                        while LangleHipRadians < 0 {
                            LangleHipRadians += CGFloat(2 * Double.pi)}
                        let LangleHipDegree = Int(LangleHipRadians * 180 / .pi)
                            
                        
                        // Knee to Hip and Hip to Ankle
                        var RangleKneeRadians = RHip2KneeAngle - RKnee2AnkAngle
                        var LangleKneeRadians = LHip2KneeAngle - LKnee2AnkAngle
                        while RangleKneeRadians < 0 || LangleKneeRadians < 0{
                            RangleKneeRadians += CGFloat(2 * Double.pi)
                            LangleKneeRadians += CGFloat(2 * Double.pi)
                        }
                        let RangleKneeDegree = Int(RangleKneeRadians * 180 / .pi)
                        let LangleKneeDegree = Int(LangleKneeRadians * 180 / .pi)
                        
                        //1. bent knee ankle check for standing (Right)
                       if RangleKneeDegree > 340 || RangleKneeDegree < 10 {
                           standcount += 1
                           result = "Stand"
                       }
                        //1. bent knee ankle check for standing (Left)
                        else if LangleKneeDegree > 340 || LangleKneeDegree < 10 {
                            standcount += 1
                            result = "Stand"
                        }
                         
                        
                        //2. considering angle of hip (Right)
                        else if RangleHipDegree > 350 || RangleHipDegree < 10 {
                            standcount += 1
                            result = "Stand"
                        }
                            
                        else if RangleHipDegree > 20 && RangleHipDegree < 80 {
                           
                            sitcount += 1
                            result = "Sit"
                        }
                            
                        else if RangleHipDegree > 130 && RangleHipDegree < 170 {
                           
                            sitcount += 1
                            result = "Sit"
                        }
                        
                        //2. considering angle of hip (Left)
                        else if LangleHipDegree > 350 || LangleHipDegree < 10 {
                            standcount += 1
                            result = "Stand"
                        }
                            
                        else if LangleHipDegree > 20 && LangleHipDegree < 80 {
                           
                            sitcount += 1
                            result = "Sit"
                        }
                            
                        else if LangleHipDegree > 130 && LangleHipDegree < 170 {
                           
                            sitcount += 1
                            result = "Sit"
                        }
                        
                        
                        
                    // 3. Shoulder to Hip length longer than Hip to Ankle confirm Sitting
                        else if (LAnk2Hip < LShldr2Hip && RAnk2Hip < RShldr2Hip) {
                         
                            sitcount += 1
                            result = "Sit"
                            
                        }
                        
                    //  4. hip to knee distance shorter than knee to ankle distance confirm sitting
                    
                        
                        else if (LKnee2Hip < LAnk2Knee && RKnee2Hip < RAnk2Knee) {
                           
                            sitcount += 1
                            result = "Sit"
                            
                           
                        }
                 
                        //pose is added to a list
                        rlist.append(result)
                     
                        
                    }
                    
                
            self.posecountlabel.text = "[No. of People: " + String(posecount) + "]"
            self.sitcountlabel.text = "[Sitting: " + String(sitcount) + "]"
            self.standcountlabel.text = "[Standing: " + String(standcount) + "]"
    
        
        
        
        let a = alist.count
        let b = a - 1
        if a == 0 {
            return
        }
        else{
        
            print(blist.count, rlist.count, glist.count, alist.count)
        for j in 0...b {
                tstring += "[" + blist[j] + " " + rlist[j] + " "  + glist[j] + " " + alist[j] + "]"
                //bodycoord + result + gender + age
        }}
            //
            thedict[key] = "Number of people \(posecount) : " + tstring
        tstring = ""
        blist = [String]()
        rlist = [String]()
        glist = [String]()
        alist = [String]()
       
            
        }
          
               
   
    
    func cropImage1(image: CGImage, rect: CGRect) -> CGImage {
        let cgImage = image
        let croppedCGImage = cgImage.cropping(to: rect)
        return croppedCGImage ?? currentFrame!
       
    }
    
    
}
   

