//
//  MemeMeEditorViewController.swift
//  MemeMe
//
//  Created by Bruno Retolaza on 01.09.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

class MemeMeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    var edited: Bool = false
    
    final let TOPBASETEXT = "TOP TEXT"
    final let BOTTOMBASETEXT = "BOTTOM TEXT"

    func configureTextField(_ textField: UITextField, _ defaultAttributes: [String: AnyObject]) {
        textField.defaultTextAttributes = defaultAttributes
        textField.textAlignment = .center

        textField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        // Prepare Text Attribute Dictionary for TextFields
        let memeTextAttributes:[String:Any]  = [
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -3.0,
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
            ]

        // Change Attributes of Textfields
        configureTextField(topText, memeTextAttributes as [String : AnyObject])
        topText.text = TOPBASETEXT
        configureTextField(bottomText, memeTextAttributes as [String : AnyObject])
        bottomText.text = BOTTOMBASETEXT

        // If there isn't an image in the view don't allow to click on share
        shareButton.isEnabled = (imagePickerView.image != nil)

        // Subscribe to Notifications
        subscribeToNotifications()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Unsubscribe from Notifications
        unsubscribeFromNotifications()
    }

    func pickAnImage(from source: UIImagePickerControllerSourceType) {
        // Assigns the Controller to a constant
        let pickerController = UIImagePickerController()
        
        // Sets its delegate to itself (musst xtend UIImagePickerControllerDelegate)
        pickerController.delegate = self
        
        pickerController.sourceType = source
        
        // Present the controller
        self.present(pickerController, animated:true, completion: nil)
        edited = true
    }
    
    @IBAction func pichAnImageFromGallery(_ sender: Any) {
        pickAnImage(from: .photoLibrary)
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(from: .camera)
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            // If there isn't an image in the view don't allow to click on share
            shareButton.isEnabled = (imagePickerView.image != nil)
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == TOPBASETEXT || textField.text == BOTTOMBASETEXT) {
            textField.text = ""
            edited = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    func subscribeToNotifications() {
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    func unsubscribeFromNotifications() {
        let center: NotificationCenter = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    func setToolbarsAs(hidden: Bool){
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }

    func generateMemedImage() -> UIImage {
        // Hide toolbars
        setToolbarsAs(hidden: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // Show toolbars
        setToolbarsAs(hidden: false)

        return memedImage
    }

    func save() {
        //Create the meme if all the elements are present
        if(topText.text != nil && bottomText.text != nil && imagePickerView.image != nil) {
            let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, baseImage: imagePickerView.image!, memedImage: generateMemedImage())
            // Add it to the memes array in the Application Delegate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }

    @IBAction func share(_ sender: Any) {
        // Prepare the Activity View Controller
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            type, completed, returnedItems, error in
            if completed {
                self.save()
            }
            self.dismiss(animated: true, completion: nil)
        }

        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        if edited {
            topText.text = TOPBASETEXT
            bottomText.text = BOTTOMBASETEXT
            imagePickerView.image = nil
            // If there isn't an image in the view don't allow to click on share
            shareButton.isEnabled = (imagePickerView.image != nil)
            edited = false
        } else {
            dismiss(animated: true, completion: nil)
            
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
