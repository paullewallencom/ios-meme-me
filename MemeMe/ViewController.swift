/*
 *  ViewController.swift
 *  MemeMe
 *
 *  Created by Paul Lewallen on 5/30/23.
 *
 */

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Two textFields TOP BOTTOM use text property
        // textAlignment - center-aligned
        // defaultTextAttributes
        // textFieldDidBeginEditing
        // textFieldShouldReturn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @obj func keyboardWillShow(_ notifications:Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)
    }
    
    /*
     let memeTextAttributes: [NSAttributed.Key: Any] = [
        NSAttributedString.Key.strokeColor: /*TODO: fill in appropriate UIColor*/,
        NSAttributedString.Key.foregroundColor: /*TODO: fill in appropriate UIColor*/,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: /*TODO: fill in appropriate Float*/
     ]
     */
    
    @IBAction func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    //dismiss(animated: true, completion: nil)
    //imagePickerController(_:didFinishPickingMediaWithInfo:)
    //imagePickerControllerDidCancel(_:)
    /*
     if let image = info[@TODO: Dictionary Key Goes Here] as? UIImage {
     imagePickerView.image = image
     }
     */
    
    /*
     @IBAction func pickAnImageFromAlbum(_ sender: Any) {
     let imagePicker = UIImagePickerController()
     imagePicker.delegate = self
     present(imagePicker, animated: true, completion: nil)
     }
     */
    
    /*
     @IBAction func pickAnImageFromCamera(_ sender: Any) {
     let imagePicker = UIImagePickerController()
     imagePicker.delegate = self
     present(imagePicker, animated: true, completion: nil)
     }
     */
    
    /*
     @IBAction func pickAnImageFromAlbum(_ sender: Any) {
     let imagePicker = UIImagePickerController()
     imagePicker.delegate = self
     imagePicker.sourceType = .photoLibrary
     present(imagePicker, animated: true, completion: nil)
     }
     */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    func generatedMemeImage() -> UIImage {
        
        // @TODO: Hide toolbar and navbar
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // @TODO: Show toolbar and navbar
        
        return memedImage
    }


}

