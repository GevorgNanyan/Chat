//ChatCell.swift
/*
 * ChatUI
 * Created by Gevor Nanyan on 03.04.24.
 * Is a product created by abnboys
 * For the ChatUI in the ChatUI
 
 * Here the permission is granted to this file with free of use anywhere in the IOS Projects.
*/

import UIKit
import QuickLook

class ChatCell: LKBaseCollectionViewCell {
    
    static let identifier = String(describing: ChatCell.self)
    
    private var imageCache = NSCache<NSString, UIImage>()
    var profileImageURL: URL? {
        didSet{
            self.fetchProfileImage(from: profileImageURL!)
        }
    }
    
    func fetchProfileImage(from url: URL) {
        //If image is available in cache, use it
        if let img = self.imageCache.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async {
                self.profileImageView.image = img
            }
            //Otherwise fetch from remote and cache it for futher use
        } else {
            
            let session = URLSession.init(configuration: .default)
            session.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImageView.image = img
                            self.imageCache.setObject(img, forKey: url.absoluteString as NSString)
                        }
                    }
                }
                }.resume()
        }
    }
    
    static let grayBubbleImage = UIImage(named: "bubble_frame")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_frame")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    var messageTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    var textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.textColor = #colorLiteral(red: 0.3176470588, green: 0.3490196078, blue: 0.9647058824, alpha: 1)
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        return lbl
    }()
    
    var contentImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.backgroundColor = UIColor.init(hexString: "303032")
        imgView.isHidden = true
        imgView.layer.cornerRadius = 15
        imgView.layer.borderWidth = 1
        imgView.layer.borderColor = UIColor.init(hexString: "232324").cgColor
        return imgView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textBubbleView)
        addSubview(nameLabel)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addSubview(contentImageView)
        
        profileImageView.backgroundColor = UIColor.green
        textBubbleView.addSubview(bubbleImageView)
        
        addConstraintsWithVisualStrings(format: "H:|[v0]|", views: bubbleImageView)
        addConstraintsWithVisualStrings(format: "V:|[v0]|", views: bubbleImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.profileImageView.image = nil
        self.messageTextView.text = nil
    }
}
