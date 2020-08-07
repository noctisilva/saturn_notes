//
//  NoteConstructionViewController.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/8/20.
//  Copyright © 2020 Interview. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

public protocol SaveNoteDelegate: NSObject {
    func saveNote(note: LocalNote, image: UIImage)
}

class NoteConstructionViewController: UIViewController, UINavigationControllerDelegate {
    
    var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "", size: 20)
        return textView
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var chooseImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.setTitle("Choose Image", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    var image: UIImage?
    var noteText: String = ""
    var imagePicker: ImagePicker!
    var imgUrl: URL?
    
    weak var delegate: SaveNoteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.textView.delegate = self
        setUpNavigation()
        setup()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.becomeFirstResponder()
    }
    
    func setUpNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addNoteAction))
    }
    
    func setup() {
        self.view.backgroundColor = .white
        self.view.addSubview(textView)
        self.view.addSubview(imageView)
        self.view.addSubview(chooseImageButton)
        
        textView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalToSuperview().multipliedBy(0.80)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.height.equalTo(82)
            $0.width.equalTo(82)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(textView.snp.bottom).offset(27)
        }
        
        chooseImageButton.addTarget(self, action: #selector(displayImagePIcker), for: .touchUpInside)
        chooseImageButton.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.width.equalToSuperview().multipliedBy(0.80)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(27)
        }
    }
    
    @objc func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addNoteAction(){
        guard let image = image, let noteText = textView.text, noteText != "" else {
            displayError()
            return
        }
        let note = constructLocalNote(noteText: noteText)
        
        self.delegate?.saveNote(note: note, image: image)
        dismiss(animated: true, completion: nil)
    }

    func constructLocalNote(noteText: String) -> LocalNote {
        
        let uniqueID = UUID().uuidString
        let note = LocalNote()
        note.id = abs(UUID().hashValue)
        note.localId = uniqueID
        note.image_id = uniqueID
        note.noteText = noteText
        note.status = .local
        note.isLoading = true
        return note
    }

    @objc func displayImagePIcker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    func displayError() {
        let alertController = UIAlertController(title: "Please complete your note.", message: "You must enter text and include an image from your photo libary", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension NoteConstructionViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?, imgUrl: URL?) {
        self.image = image
        self.imageView.image = image
        self.imgUrl = imgUrl
    }
    
}
extension NoteConstructionViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard range.location == 0 else {
            return true
        }
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
    
    
}
