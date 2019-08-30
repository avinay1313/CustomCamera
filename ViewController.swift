//
//  ViewController.swift
//  CustomCamera
//
//  Created by TOSC164 on 30/08/19.
//  Copyright © 2019 Avinay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var viewPreview: UIView!
    
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnSwitchCamera: UIButton!
    @IBOutlet weak var btnDown: UIButton!
    
    @IBOutlet weak var consHeightViewPhoto: NSLayoutConstraint!
    var arrPreviewImage = [UIImage]()
    
    let cameraManager = CameraManager()
    
    var isViewPhotoOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setUpView()
        setUpCameraView()
    }
    
    func setUpView() {
        btnFlash.setImage(UIImage(named: "flash-off"), for: .normal)
        btnFlash.setImage(UIImage(named: "flash-off"), for: .selected)
        
        if arrPreviewImage.count > 0 {
            consHeightViewPhoto.constant = 90.0
            isViewPhotoOpen = true
        } else {
            consHeightViewPhoto.constant = 15.0
            isViewPhotoOpen = false
        }
    }
    
    func setUpCameraView() {
        cameraManager.shouldRespondToOrientationChanges = false
        cameraManager.shouldEnableExposure = true
        
        cameraManager.shouldFlipFrontCameraImage = false
        cameraManager.showAccessPermissionPopupAutomatically = false
        
        let currentCameraState = cameraManager.currentCameraStatus()
        
        if currentCameraState == .notDetermined {
            askForCameraPermissions()
        } else if currentCameraState == .ready {
            addCameraToView()
        } else {
            askForCameraPermissions()
        }
    }

    func askForCameraPermissions() {
        self.cameraManager.askUserForCameraPermission({ permissionGranted in
            
            if permissionGranted {
                self.addCameraToView()
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                } else {
                    // Fallback on earlier versions
                }
            }
        })
    }
    
    fileprivate func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(viewPreview, newCameraOutputMode: CameraOutputMode.stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnClosePressed(_ sender: Any) {
    }
    
    @IBAction func btnDonePressed(_ sender: Any) {
    }
    
    @IBAction func btnCapturePressed(_ sender: Any) {
        
        cameraManager.capturePictureWithCompletion({ result in
            switch result {
            case .failure:
                self.cameraManager.showErrorBlock("Error occurred", "Cannot save picture.")
            case .success(let content):
                self.arrPreviewImage.append(content.asImage!)
                self.isViewPhotoOpen = true
                self.consHeightViewPhoto.constant = 90.0
//                let vc: ImageViewController? = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController
//                if let validVC: ImageViewController = vc,
//                    case let capturedImage = content.asImage {
//                    validVC.image = capturedImage
//                    validVC.cameraManager = self.cameraManager
//                    self.navigationController?.pushViewController(validVC, animated: true)
//                }
            }
        })
    }
    
    @IBAction func btnFlashPressed(_ sender: Any) {
        if cameraManager.hasFlash {
            switch cameraManager.changeFlashMode() {
            case .off:
                btnFlash.setImage(UIImage(named: "flash-off"), for: .normal)
                btnFlash.setImage(UIImage(named: "flash-off"), for: .selected)
            case .on:
                btnFlash.setImage(UIImage(named: "flash-on"), for: .normal)
                btnFlash.setImage(UIImage(named: "flash-on"), for: .selected)
            case .auto:
                btnFlash.setImage(UIImage(named: "flash-auto"), for: .normal)
                btnFlash.setImage(UIImage(named: "flash-auto"), for: .selected)
            }
        }
        
    }
    
    @IBAction func btnSwitchCameraPressed(_ sender: Any) {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    }
    
    @IBAction func btnDownPressed(_ sender: Any) {
        if isViewPhotoOpen {
            isViewPhotoOpen = false
            self.consHeightViewPhoto.constant = 15.0
        } else {
            isViewPhotoOpen = true
            self.consHeightViewPhoto.constant = 90.0
        }
    }
    
    

}

