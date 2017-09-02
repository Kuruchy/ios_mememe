//
//  ViewController.swift
//  MemeMe
//
//  Created by Bruno Retolaza on 01.09.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    //Structure definition for Meme instances
    struct Meme {
        var topText: String?
        var bottomText: String?
        var baseImage: UIImage?
        var memedImage: UIImage
    }

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
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0,
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white
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

    @IBAction func pickAnImage(_ sender: Any) {

        // Assigns the Controller to a constant
        let pickerController = UIImagePickerController()

        // Sets its delegate to itself (musst xtend UIImagePickerControllerDelegate)
        pickerController.delegate = self

        pickerController.sourceType = .photoLibrary

        // Present the controller
        self.present(pickerController, animated:true, completion: nil)
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)    }


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
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true;
    }

    func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(_ notification:Notification) {
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
        //Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, baseImage: imagePickerView.image!, memedImage: generateMemedImage())
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
        topText.text = TOPBASETEXT
        bottomText.text = BOTTOMBASETEXT
        imagePickerView.image = nil
        // If there isn't an image in the view don't allow to click on share
        shareButton.isEnabled = (imagePickerView.image != nil)
    }

}
