/*
 *  MemeMeViewController.swift
 *  MemeMe
 *
 *  Created by Paul Lewallen on 5/30/23.
 *
 */

import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: IBoutlets
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setTextFields(textField: topTextField, string: AppModel.defaultTopTextFieldText)
        setTextFields(textField: bottomTextField, string: AppModel.defaultBottomTextFieldText)
        scrollView.delegate = self;
        scrollView.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if AppModel.currentFontIndex != -1 {
            topTextField.font = UIFont(name: AppModel.selectedFont, size: 38)
            bottomTextField.font = UIFont(name: AppModel.selectedFont, size: 38)
        }
        
        if let _ = imagePickerView.image {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        self.subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: UIImagePickerController Functions
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        presentImagePicker(sourceType: UIImagePickerController.SourceType.camera)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: AnyObject) {
        //To pick an image from Photos Albums
        presentImagePicker(sourceType: UIImagePickerController.SourceType.photoLibrary)
    }
    
    // MARK: UIImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // To select an image and set it to imageView
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            self.view.layoutIfNeeded()
            setZoomScaleForImage(scrollViewSize: scrollView.bounds.size)
            scrollView.zoomScale = scrollView.minimumZoomScale
            centerImage()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Notification Functions
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Keyboard Methods and Delegates
    @objc func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Meme Object Generation
    func generateMemedImage() -> UIImage {
        configureBars(hidden: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        configureBars(hidden: false)
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text! as NSString?, bottomText: bottomTextField.text! as NSString?,  image: imagePickerView.image, memedImage: memedImage)
        (UIApplication.shared.delegate as!
            AppDelegate).memes.append(meme)
    }
    
    //MARK: Top Bar Button
    @IBAction func shareAction(_ sender: AnyObject) {
        let memedImage = generateMemedImage()
        let shareActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareActivityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(shareActivityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        if imagePickerView.image != nil {
            let alert = UIAlertController(title: AppModel.alert.alertTitle , message: AppModel.alert.alertMessage, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                self.imagePickerView.image = nil
                self.resetTextfieldText()
                self.shareButton.isEnabled = false
            }
            let no  = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: Animation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.topTextField.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.bottomTextField.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (UIViewControllerTransitionCoordinatorContext) in
            UIView.animate(withDuration: 0.5, animations: {
                self.topTextField.transform = CGAffineTransform.identity
                self.bottomTextField.transform = CGAffineTransform.identity
            })
        }
    }
    
    @IBAction func setFont(_ sender: AnyObject) {
        self.performSegue(withIdentifier: AppModel.fontTableViewSegueIdentifier, sender: nil)
    }
    
    //MARK: Helper Functions
    var statusBarHidden: Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        self.view.layoutIfNeeded()
        setZoomScaleForImage(scrollViewSize: scrollView.bounds.size)
        if scrollView.zoomScale < scrollView.minimumZoomScale || scrollView.zoomScale == 1{
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        centerImage()
    }
    
    func configureBars(hidden: Bool) {
        navBar.isHidden = hidden
        toolBar.isHidden = hidden
    }
    
    func resetTextfieldText(){
        topTextField.text = AppModel.defaultTopTextFieldText
        bottomTextField.text = AppModel.defaultBottomTextFieldText
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion:nil)
    }
}

extension MemeMeViewController: UITextFieldDelegate {
    //MARK: UITextField Extension
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text as NSString?
        text = text!.replacingCharacters(in: range, with: string) as NSString?
        
        textField.text = text?.uppercased
        return false
    }
    
    func setTextFields(textField: UITextField, string: String) {
        textField.defaultTextAttributes = AppModel.memeTextAttributes
        textField.text = string
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self;
    }
    
    /*
     static let memeTextAttributes: [NSAttributedString.Key: Any] = [
             NSAttributedString.Key.strokeColor     : UIColor.black,
             NSAttributedString.Key.foregroundColor : UIColor.white,
             NSAttributedString.Key.font            : UIFont(name: "system", size: 32)!,
             NSAttributedString.Key.strokeWidth     : 1.0
         ]
     */
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text == AppModel.defaultTopTextFieldText {
            textField.text = ""
        } else if textField == bottomTextField && textField.text == AppModel.defaultBottomTextFieldText {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text!.isEmpty {
            textField.text = AppModel.defaultTopTextFieldText;
        }else if textField == bottomTextField && textField.text!.isEmpty {
            textField.text = AppModel.defaultBottomTextFieldText;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension MemeMeViewController: UIScrollViewDelegate {
    //MARK: Center Image
    func centerImage() {
        if imagePickerView.image != nil {
            let scrollViewSize = scrollView.bounds.size
            let imageSize = imagePickerView.frame.size
            let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
            let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
            scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
        }
    }
    
    //MARK: Zoom Scale
    func setZoomScaleForImage(scrollViewSize: CGSize) {
        if let image = imagePickerView.image {
            let imageSize = image.size
            let widthScale = scrollViewSize.width / imageSize.width
            let heightScale = scrollViewSize.height / imageSize.height

            let minScale = min(widthScale, heightScale)
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 3.0
        }
    }
    
    //MARK: UIScrollView Extension
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return imagePickerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
