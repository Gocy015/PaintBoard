//
//  ViewController.swift
//  PaintBoard
//
//  Created by Gocy on 2017/5/15.
//  Copyright © 2017年 Gocy. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var imagePainter: ImagePainter!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        installNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UI
    
    func installNavigationBar(){
        self.title = "Paint Board"
        
        let leftItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveToPhotos))
        self.navigationItem.setLeftBarButton(leftItem, animated: false)
        
        let rightItem = UIBarButtonItem(title: "Select Photo", style: .plain, target: self, action: #selector(self.openPhotos))
        self.navigationItem.setRightBarButton(rightItem, animated: false)
        
    }

    
    //MARK: - Actions
    
    func saveToPhotos(){
        doSavePhotos()
    }
    
    func openPhotos(){
        doOpenPhotos()
    }

    @IBAction func undoPainting(_ sender: Any) {
        self.imagePainter.tryUndo()
    }
}

//MARK: - PhotoLibrary Logic

extension ViewController : UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    func doOpenPhotos(){
        askPhotoPermissionIfNeeded {
            [weak self] in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            
            picker.mediaTypes = [kUTTypeImage as String]
            
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
    func askPhotoPermissionIfNeeded(completion:@escaping ()->()){
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized{
                    completion()
                }
            }
            break
        case .authorized:
            completion()
            break
        default:
            break
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            return
        }
        imagePainter.resetPainting()
        imagePainter.image = image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ViewController{
    func doSavePhotos(){
        guard let paintedImage = imagePainter.paintedImage else{
            return
        }
        PaintingManager.default.storeLatest(image: paintedImage)
        UIImageWriteToSavedPhotosAlbum(paintedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    func image(_ image:UIImage, didFinishSavingWithError error:NSError?, contextInfo:AnyObject){
        
        NSLog("Image saved successfully ,error : \(String(describing: error))")
    }
}

