//
//  PhotoEditingViewController.swift
//  PaintBoardExtension
//
//  Created by Gocy on 2017/5/15.
//  Copyright © 2017年 Gocy. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController: UIViewController, PHContentEditingController {

    var input: PHContentEditingInput?
    
    @IBOutlet weak var imagePainter: ImagePainter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func undo(_ sender: Any) {
        imagePainter.tryUndo()
    }
    
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        guard let version = Double(adjustmentData.formatVersion) else{
            return false
        }
        
        guard adjustmentData.formatIdentifier == "com.gocy.PaintBoard" else {
            return false
        }
        
        return version >= 0.2
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        
        // If you returned false, the contentEditingInput has past edits "baked in".
        imagePainter.image = placeholderImage
        imagePainter.resetPainting()
        
        input = contentEditingInput
        if let adjustmentData = input?.adjustmentData?.data , let restoredData = NSKeyedUnarchiver.unarchiveObject(with: adjustmentData) as? [[CGPoint]]{
            imagePainter.resetPainting(withData: restoredData)
        }
        
        imagePainter.image = contentEditingInput.displaySizeImage
        
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            
            let fullImageData : Data?
            do{
                fullImageData = try Data(contentsOf: self.input!.fullSizeImageURL!)
            }catch{
                fullImageData = nil
                NSLog("Error getting full size img data : \(error)")
            }
            
            if let data = fullImageData, let image = UIImage(data: data){
                
                self.imagePainter.image = image
                
                if let painted = self.imagePainter.paintedImage{
                    guard let jpeg = UIImageJPEGRepresentation(painted, 0.8) else{
                        return
                    }
                    
                    try? jpeg.write(to: output.renderedContentURL, options: .atomic)
                    
                    output.adjustmentData = PHAdjustmentData(formatIdentifier: "com.gocy.PaintBoard", formatVersion: "0.2", data: NSKeyedArchiver.archivedData(withRootObject: self.imagePainter.pointsList))
                }
                
            }
            
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return self.imagePainter.pointsList.count > 0
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }

}
