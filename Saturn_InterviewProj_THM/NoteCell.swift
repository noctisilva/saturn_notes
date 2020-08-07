//
//  NoteCell.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/6/20.
//  Copyright © 2020 Interview. All rights reserved.
//

import UIKit
import SDWebImage

class NoteCell: UITableViewCell {
    
    var noteImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.image = nil
        imageView.backgroundColor = .darkGray
        return imageView
    }()
    
    var noteText: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat", size: 10)
        label.textColor = .black
        label.text = "For this task, you’ll increase the height of the countdown timer in landscape orientation and also increase the font size. In this specific context, you need to update the constant of the timer label’s height constraint."
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    var statusViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 219/256, green: 219/256, blue: 219/256, alpha: 1.0)
        return view
    }()
    
    var statusDot: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    var loadingView:UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.style = .medium
        loadingView.isHidden = true
        return loadingView
    }()
    
    static let reuseIdentifier = "NoteCell"
    var note: LocalNote?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        //refactor later
        contentView.addSubview(noteImage)
        contentView.addSubview(noteText)
        contentView.addSubview(statusViewContainer)
        statusViewContainer.addSubview(statusDot)
        statusViewContainer.addSubview(loadingView)
        noteImage.image = nil
        noteImage.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(4)
            $0.leading.equalToSuperview()
        }
        
        noteText.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
            $0.leading.equalTo(noteImage.snp.trailing)
        }
        
        statusViewContainer.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(4)
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(noteText.snp.trailing)
        }
        
        statusDot.snp.makeConstraints {
            $0.height.width.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints {
            $0.center.equalTo(statusViewContainer)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
    }
    
    /*
     CANNOT USE note.imageURL AS KEY DUE TO THE SAME URL FOR DIFFERENT POSTS SOMETIMES
     */
    func bind(_ note: LocalNote){
        self.note = note
        self.noteText.text = note.noteText
        
        // Check to see if note has an image
        // Check to see if the image exists from local
        // if not, download from URL and cache to device with image_id as the key
        
        if note.image_id.count > 0 {
            if let image = SDImageCache.shared.imageFromCache(forKey: note.image_id) {
                DispatchQueue.main.async {
                    self.noteImage.image = image
                }
            } else if let imgURL = URL(string: note.imageURL) {
                SDWebImageDownloader.shared.downloadImage(with: imgURL) { (image, data, error, finish) in
                    guard let image = image, let imgData = image.jpegData(compressionQuality: 0.3) else { return }
                    let optimalImage = UIImage(data: imgData)
                    if self.note?.id == note.id {
                        DispatchQueue.main.async {
                            self.noteImage.image = optimalImage
                        }
                    }
                    SDImageCache.shared.store(optimalImage, forKey: note.image_id, toDisk: true, completion: nil)
                    
                }
            } else {
                noteImage.sd_cancelCurrentImageLoad()
                noteImage.image = nil
            }
        }

        
        if note.isLoading {
            loadingView.isHidden = false
            loadingView.startAnimating()
            statusDot.isHidden = true
        } else {
            switch note.status {
                case .local:
                    statusDot.backgroundColor = .red
                case .server:
                    statusDot.backgroundColor = .green
            }
            statusDot.isHidden = false
            loadingView.isHidden = false
            loadingView.stopAnimating()
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        noteImage.sd_cancelCurrentImageLoad() //This is necessary
        noteText.text = ""
        noteImage.image = nil //This is used as an extra precaution in case .sd_cancelCurrentImageLoad isn't called asynchronously
        self.note = nil
    }
    
    // There should be better error logging
    func downloadImage(_ url: URL, completion: @escaping(UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .highPriority,
            progress: nil,
            completed: { [weak self] (image, data, error, cacheType, finished, url) in
                guard let self = self else { return }

                if let err = error {
                    print("SDWebImageManager in cell: err: \(err)")
                    return
                }

                guard let img = image else {
                    print("SDWebImageManager in cell: img error")
                    return
                }

                completion(img)
            }
        )
    }
    
}
