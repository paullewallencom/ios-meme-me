/*
 *  MemeMeViewController.swift
 *  MemeMe
 *
 *  Created by Paul Lewallen on 5/30/23.
 *
 */

import UIKit

class MemeMeViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: IBoutlets
    @IBOutlet weak var navBar               : UINavigationBar!
    @IBOutlet weak var imageViewPicker      : UIImageView!
    @IBOutlet weak var topTextField         : UITextField!
    @IBOutlet weak var bottomTextField      : UITextField!
    @IBOutlet weak var toolBar              : UIToolbar!
    @IBOutlet weak var cameraButton         : UIBarButtonItem!
    @IBOutlet weak var albumButton          : UIBarButtonItem!
    
    let textAttributes = [
        NSAttributedStringKey.strokeColor.rawValue      : UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue  : UIColor.white,
        NSAttributedStringKey.font.rawValue             : UIFont (name : "system", size : 36)!,
        NSAttributedStringKey.strokeWidth.rawValue      : -1.0
    ]  as [String : Any]
    
    //MARK: LifeCycle Methods
    override func viewDidLoad () {
        super.viewDidLoad ()

        func textFieldStyle (textField : UITextField) {
            textField.defaultTextAttributes     = textAttributes
            topTextField.text                   = "TOP TEXT"
            bottomTextField.text                = "BOTTOM TEXT"
            textField.textAlignment             = .center
            textField.delegate                  = self
        }
        textFieldStyle (textField : topTextField)
        textFieldStyle (textField : bottomTextField)
    }
    
    override func viewWillAppear (_ animated : Bool) {
        super.viewWillAppear (animated)
        self.subscribeToKeyboardNotifications ()
                
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable (UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear (_ animated : Bool) {
        super.viewWillAppear (animated)
        
        unsubscribeToKeyboardNotifications ()

        func textFieldDidBeginEditing (textField : UITextField) {
            if textField.text == "TOP TEXT" || textField.text == "BOTTOM TEXT" {
                textField.text = ""
            }
        }
    }
    
    // MARK: UIImagePickerController Functions
    func pickImageFromSource (source : UIImagePickerControllerSourceType) {
        //Code To Pick An Image From Source
        let pickerController                = UIImagePickerController ()
        pickerController.delegate           = self
        pickerController.sourceType         = source
        present (pickerController, animated : true, completion : nil)
    }
    
    @IBAction func cameraButtonAction (_ sender : Any) {
            pickImageFromSource (source : .camera)
        }
    
    @IBAction func photoLibraryAction (_ sender : Any) {
            pickImageFromSource (source : .photoLibrary)
        }
    
    // MARK: UIImagePickerController Delegates
    func imagePickerController (_ picker : UIImagePickerController, didFinishPickingMediaWithInfo info : [String : Any]) {
        imageViewPicker.image = info [UIImagePickerControllerOriginalImage] as? UIImage; dismiss (animated : true, completion : nil)
        }
    
    func imagePickerControllerDidCancel (_ picker : UIImagePickerController) {
        dismiss (animated : true, completion: nil)
    }
    
    func textFieldShouldReturn (_ textField : UITextField) -> Bool {
        textField.resignFirstResponder ()
        return true
    }
    
    // MARK: Notification Functions
    func subscribeToKeyboardNotifications () {
        NotificationCenter.default.addObserver (self, selector : #selector (MemeMeViewController.keyboardWillShow (_:)), name : NSNotification.Name.UIKeyboardWillShow, object : nil)
        NotificationCenter.default.addObserver (self, selector : #selector (MemeMeViewController.keyboardWillHide (_:)), name : NSNotification.Name.UIKeyboardWillHide, object : nil)
    }
    
    func unsubscribeToKeyboardNotifications () {
        NotificationCenter.default.removeObserver (self, name : NSNotification.Name.UIKeyboardWillShow, object : nil)
        NotificationCenter.default.removeObserver (self, name : NSNotification.Name.UIKeyboardWillHide, object : nil)
    }
    
    // MARK: Keyboard Methods and Delegates
    @objc func keyboardWillHide (_ notification : Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillShow (_ notification : Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight (notification) * (-1)
        }

    }
    
    func getKeyboardHeight (_ notification : Notification) -> CGFloat {
        let userInfo            = notification.userInfo
        let keyboardSize        = userInfo! [UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Meme Object Generation
    func generateMemedImage () -> UIImage {
        //Hide Toolbar And Navigation Bar
        navBar.isHidden     = true
        toolBar.isHidden    = true

        // Render View To An Image
        UIGraphicsBeginImageContext (self.view.frame.size)
        view.drawHierarchy ( in : self.view.frame, afterScreenUpdates : true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext ()!
        UIGraphicsEndImageContext ()

        //Show Toolbar and Navigation Bar
        navBar.isHidden     = false
        toolBar.isHidden    = false

        return memedImage
    }
    
    func save () {
        // Create The Meme
        let memedImage = generateMemedImage ()
        _ = Meme (topText : topTextField.text!, bottomText : bottomTextField.text!, image : imageViewPicker.image, memedImage : memedImage)
    }
    
    //MARK: Top Bar Button
    @IBAction func shareButtonAction (_ sender : Any) {
        let memedImage = generateMemedImage ()
        let activityController = UIActivityViewController (activityItems : [memedImage], applicationActivities : nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            self.save ()
            self.dismiss (animated : true, completion : nil)
        }
        present (activityController, animated : true, completion : nil)
            
    }
    
    @IBAction func cancelButtonAction (_ sender : Any) {
        //self.dismissViewControllerAnimated (true, completion : nil)
        topTextField.text               = "TOP TEXT"
        bottomTextField.text            = "BOTTOM TEXT"
        self.imageViewPicker.image      = nil
    }
}
