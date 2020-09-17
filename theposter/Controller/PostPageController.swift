//
//  ViewController.swift
//  theposter
//
//  Created by Admin on 15/09/2017.
//  Copyright © 2017 pavbox. All rights reserved.
//


import UIKit
import TwitterCore
import TwitterKit

class PostPageController: UIViewController {

    // MARK: - Properties
    
    // FIXME: not flexible behavior
    @IBOutlet weak var bodyTextField: UITextView!
    
    // FIXME: OS_ACTIVITY_MODE returns error for autocorrection
    @IBOutlet weak var hashtagField: UITextField!
    
    // scroll and autoscroll
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var insidePostView: UIView!
    @IBOutlet weak var heightOfTextView: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = insidePostView.frame.size
        }
    }
    
    // Imagepicker
    @IBOutlet weak var imageButton: UIButton!
    private var imagePicker: UIImagePickerController? = UIImagePickerController()
    
    // fetch data object
    private var fetch_data: FetchData?
    
    // get data from postList while updating post (not add)
    public var seguePost: [String: Any?]?
    var selectedImage: UIImage?
    

    // MARK: - Methods
    // BUG: Why doesnt work for slowly touch (just focus, not down)
    @IBAction func textFieldTouchDown(_ sender: UITextField) {
        print("touch down")
    }

    @IBAction func shareAction(_ sender: UIButton) {
        post()
    }

    private func post() {
        let text = ""
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            // App must have at least one logged-in user to compose a Tweet
            let composer = TWTRComposer()
            composer.setText(text)
            composer.setImage(selectedImage)
            composer.show(from: navigationController!) { (result) in
                print(result)
            }
        } else {
            // Log in, and then check again
            TWTRTwitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let composer = TWTRComposer()
                    composer.setText(text)
                    composer.setImage(self.selectedImage)
                    composer.show(from: self.navigationController!) { (result) in
                        print(result)
                    }
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available",
                                                  message: "You must log in before presenting a composer.",
                                                  preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
    // MARK: Initial and prepare events
    private func initCustomUI() {
        // set similar view for TextView
        let lightGrayColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        bodyTextField.layer.borderWidth = 1.0
        bodyTextField.layer.borderColor = lightGrayColor.cgColor
        bodyTextField.layer.cornerRadius = 5
        imageButton.layer.borderWidth = 1.0
        imageButton.layer.borderColor = lightGrayColor.cgColor
        imageButton.layer.cornerRadius = 5
        imageButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        shareButton.layer.cornerRadius = 8
        view.backgroundColor = .black
    }
    
    
    // FIXME: Use extensions? why objc style
    private func setObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Keyboard Events
    @objc private func keyboardWillBeShown(note: Notification) {
        let userInfo = note.userInfo
        let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        
        // 30px is margin bottom for main Stack View. Inner content for scrollView indicator
        let contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0, keyboardFrame.height, 0.0)
        
        var scrollInset = contentInset
        scrollInset.bottom += 15
        
        scrollView.contentInset = scrollInset
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.scrollRectToVisible(hashtagField.frame, animated: true)
        scrollView.scrollRectToVisible(bodyTextField.frame, animated: true)
    }
    
    @objc private func keyboardWillBeHidden(note: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    

    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initCustomUI()
        setObservers()
        
        fetch_data = FetchData();
        
        if seguePost != nil {
            bodyTextField?.text = seguePost!["title"]! as? String
            hashtagField?.text = seguePost!["hashtag"]! as? String
            
            let id = seguePost!["id"]! as! String
            let imageURL = URL(string: "\((fetch_data?.API_ADDR)!)/post/\(id)/upload")
            
            loadFromUrl(imageURL)
        }
        
    }
    
    // MARK: - Events
    @IBAction func imageButtonPick(_ sender: UIButton) {
        openGallery()
    }

    @IBAction func sharePost(_ sender: UIButton) {
        if seguePost != nil {
            fetch_data!.removePostById(seguePost!["id"]! as! String);
        }
    }
    
    
    @IBAction func savePost(_ sender: UIBarButtonItem) {
        if  !bodyTextField.text.isEmpty ||
            !hashtagField.text!.isEmpty ||
            selectedImage != nil {
            
            let imageURL = (seguePost != nil) ? seguePost!["id"]! as? String : ""

            let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            sender.customView = indicator
            indicator.startAnimating()
            fetch_data!.savePostToDatabase(
                description: bodyTextField.text,
                hashtag: hashtagField.text!,
                image: imageURL!,
                isUpdate: (seguePost != nil)
            ) { (id) in
                if (self.selectedImage != nil) {
                    self.fetch_data!.uploadImage(self.selectedImage!, id) {
                        DispatchQueue.main.async {
                            indicator.stopAnimating()
                            sender.customView = nil
                            sender.isEnabled = false
                        }
                    }
                    self.selectedImage = nil
                } else {
                    DispatchQueue.main.async {
                        indicator.stopAnimating()
                        sender.customView = nil
                        sender.isEnabled = false
                    }
                }
            }
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension PostPageController: UIImagePickerControllerDelegate {
    private func loadFromUrl(_ imageUrl: URL?) {
        if let url = imageUrl {
            DispatchQueue.global(qos: .userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = contentsOfURL {
                        self.chooseImage(UIImage(data: imageData), for: UIControlState.normal)
                    } else {
                        self.chooseImage(UIImage(named: "angry"), for: UIControlState.normal)
                    }
                }
            }
        }
    }
    
    private func openGallery() {
        imagePicker?.delegate = self
        imagePicker?.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker!, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
                    ?? (info[UIImagePickerControllerOriginalImage] as? UIImage)
        
        if image != nil {
            chooseImage(image, for: UIControlState.normal)
            self.selectedImage = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func chooseImage(_ image: UIImage?, for state: UIControlState) {
        imageButton.setBackgroundImage(image, for: UIControlState.normal)
        imageButton.setTitle("Change Image", for: UIControlState.normal)
    }
}

// Allow delegate for imagePicker
extension PostPageController: UINavigationControllerDelegate { }




