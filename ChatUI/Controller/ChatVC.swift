//ViewController.swift
/*
 * ChatUI
 * Created by Gevor Nanyan on 03.04.24.
 * Is a product created by abnboys
 * For the  in the ChatUI
 
 * Here the permission is granted to this file with free of use anywhere in the IOS Projects.
*/
import UIKit

class ChatVC: UIViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var chatCollView: UICollectionView!
    @IBOutlet var inputViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var chatTF: UITextField!
    @IBOutlet var sendBTN: UIButton!
    @IBOutlet var topLine: UIView!
    @IBOutlet var bottomLine: UIView!
    
    private var currentPage = 0
    private let pageSize = 20
    private var isLoading = false
    private var isLastPage = false
    
    
    private(set) var chatsArray: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialFetch()
        
        chatTF.setLeftPaddingPoints(13)
        chatTF.setRightPaddingPoints(13)
        chatTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
            self.view.backgroundColor = UIColor.white
            topLine.backgroundColor = UIColor.init(hexString: "E8E9ED")
            bottomLine.backgroundColor = UIColor.init(hexString: "E8E9ED")
        case .dark:
            self.view.backgroundColor = UIColor.init(hexString: "19191B")
            topLine.backgroundColor = UIColor.init(hexString: "303032")
            bottomLine.backgroundColor = UIColor.init(hexString: "303032")
        @unknown default:
            break
        }
        
        self.assignDelegates()
        self.manageInputEventsForTheSubViews()
    }

    private var totalChats: Int = 0  // Variable to store the total number of chats

    private func fetchChatData(page: Int) {
        let spinner = Spinner()
        spinner.show()
        
        if let url = Bundle.main.url(forResource: "chat", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let chats = try decoder.decode([Chat].self, from: data)
                
                // Set the totalChats count if it's not already set
                if totalChats == 0 {
                    totalChats = chats.count
                }
                
                // Calculate the range for the current page
                let startIndex = page * pageSize
                let endIndex = min(startIndex + pageSize, totalChats)
                let pageChats = Array(chats[startIndex..<endIndex])

                // Simulate fetching data asynchronously (replace with your actual data fetching mechanism)
                DispatchQueue.global().async {
                    // Simulate a delay
                    sleep(1)
                        
                        // Append the fetched chats to the chatsArray
                    DispatchQueue.main.async {
                        self.chatsArray.append(contentsOf: pageChats)
                        self.chatCollView.reloadData()
                        self.isLoading = false
                        spinner.hide()
                    }
                }
            } catch let err {
                print(err.localizedDescription)
                spinner.hide()
            }
        }
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        // Check if the scrollView is scrolled to the bottom and not currently loading more data
        if offsetY > contentHeight - scrollViewHeight, !isLoading, !isLastPage {
            isLoading = true
            currentPage += 1
            fetchChatData(page: currentPage)
        }
    }

    // Call this method initially to fetch the first page of chats
    private func initialFetch() {
        fetchChatData(page: currentPage)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle // Either .unspecified, .light, or .dark
        if userInterfaceStyle == .dark || userInterfaceStyle == .unspecified {
            self.view.backgroundColor = UIColor.init(hexString: "19191B")
            topLine.backgroundColor = UIColor.init(hexString: "303032")
            bottomLine.backgroundColor = UIColor.init(hexString: "303032")
        } else {
            self.view.backgroundColor = UIColor.white
            topLine.backgroundColor = UIColor.init(hexString: "E8E9ED")
            bottomLine.backgroundColor = UIColor.init(hexString: "E8E9ED")
        }
        
        self.chatCollView.reloadData()
        // Update your user interface based on the appearance
    }
    
    private func manageInputEventsForTheSubViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotfHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotfHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardFrameChangeNotfHandler(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            inputViewContainerBottomConstraint.constant = isKeyboardShowing ? keyboardFrame.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    let lastItem = self.chatsArray.count - 1
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    private func assignDelegates() {
        self.chatCollView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.identifier)
        self.chatCollView.dataSource = self
        self.chatCollView.delegate = self
        self.chatTF.delegate = self
    }
    
    @IBAction func onSendChat(_ sender: UIButton?) {
        
        guard let chatText = chatTF.text, chatText.count >= 1 else { return }
        chatTF.text = ""
        let chat = Chat.init(user_name: "Krish", user_image_url: "https://images.unsplash.com/photo-1529665253569-6d01c0eaf7b6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2552&q=80", is_sent_by_me: false, text: chatText, type: .text, file_url: "", estimated_Height: 0)
        
        self.chatsArray.append(chat)
        self.chatCollView.reloadData()
        
        let lastItem = self.chatsArray.count - 1
        let indexPath = IndexPath(item: lastItem, section: 0)
        self.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
}

extension ChatVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = chatCollView.dequeueReusableCell(withReuseIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell {
            
            let chat = chatsArray[indexPath.item]
            
            cell.messageTextView.text = chat.text
            cell.nameLabel.text = chat.user_name
            cell.profileImageURL = URL.init(string: chat.user_image_url)!
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            var estimatedFrame = NSString(string: chat.text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
            estimatedFrame.size.height += 18
            
            let nameSize = NSString(string: chat.user_name).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)
            
            let maxValue = max(estimatedFrame.width, nameSize.width)
            estimatedFrame.size.width = maxValue
            
            if chat.is_sent_by_me {
                cell.nameLabel.textAlignment = .left
                cell.profileImageView.frame = CGRect(x: 13, y: 5, width: 30, height: 30)
                cell.textBubbleView.frame = CGRect(x: cell.profileImageView.frame.width + 25, y: -4, width: estimatedFrame.width + 52, height: estimatedFrame.height + 26)
                cell.nameLabel.frame = CGRect(x: cell.textBubbleView.frame.origin.x + 16, y: 5, width: estimatedFrame.width + 16, height: 18)
                cell.messageTextView.frame = CGRect(x: cell.textBubbleView.frame.origin.x + 13, y: 22, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                
                
                switch traitCollection.userInterfaceStyle {
                    case .light, .unspecified:
                    cell.bubbleImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                        // light mode detected
                    cell.messageTextView.textColor = UIColor.black
                    self.chatTF.backgroundColor = UIColor.init(hexString: "F1F2F6")
                    case .dark:
                        // dark mode detected
                    cell.bubbleImageView.backgroundColor = UIColor.init(hexString: "232324")
                    cell.messageTextView.textColor = UIColor.white
                    self.chatTF.backgroundColor = UIColor.init(hexString: "232324")
                @unknown default:
                    break
                }
                
            } else {
                
                cell.nameLabel.textAlignment = .right
                    cell.profileImageView.frame = CGRect(x: cell.bounds.width - 43, y: 5, width: 30, height: 30)
                    cell.textBubbleView.frame = CGRect(x: cell.profileImageView.frame.origin.x - estimatedFrame.width - 62, y: -4, width: estimatedFrame.width + 52, height: estimatedFrame.height + 26)
                    cell.nameLabel.frame = CGRect(x: cell.textBubbleView.frame.origin.x + 20, y: 5, width: estimatedFrame.width + 16, height: 18)
                    cell.messageTextView.frame = CGRect(x: cell.textBubbleView.frame.origin.x + 32, y: 22, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                switch traitCollection.userInterfaceStyle {
                    case .light, .unspecified:
                    cell.bubbleImageView.backgroundColor = UIColor.init(hexString: "E3E7FD")
                    cell.messageTextView.textColor = UIColor.black
                    self.chatTF.backgroundColor = UIColor.init(hexString: "F1F2F6")
                        // light mode detected
                    case .dark:
                        // dark mode detected
                    cell.bubbleImageView.backgroundColor = UIColor.init(hexString: "212237")
                    cell.messageTextView.textColor = UIColor.white
                    self.chatTF.backgroundColor = UIColor.init(hexString: "232324")
                @unknown default:
                    break
                }
            }
            
            if chat.type == .photo {
                cell.textBubbleView.frame.size.height = CGFloat(chat.estimated_Height) + estimatedFrame.height
                cell.textBubbleView.frame.size.width = collectionView.frame.width / 1.3
                if !chat.is_sent_by_me {
                    cell.textBubbleView.frame.origin.x = collectionView.frame.width - collectionView.frame.width / 1.3 - 48
                }
                cell.messageTextView.frame.size.width = cell.textBubbleView.frame.size.width - 38
                cell.contentImageView.frame = cell.textBubbleView.frame
                cell.contentImageView.frame.origin.y = estimatedFrame.height + 30
                cell.contentImageView.frame.size.height -= estimatedFrame.height + 30
                cell.contentImageView.isHidden = false
                cell.contentImageView.image = UIImage.init(named: "\(chat.file_url)")
            } else if chat.type == .text {
                cell.bubbleImageView.image = nil
                cell.contentImageView.isHidden = true
            }
            
            return cell
        }
        return ChatCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let chat = chatsArray[indexPath.item]
        if let chatCell = cell as? ChatCell {
            chatCell.profileImageURL = URL.init(string: chat.user_image_url)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let chat = chatsArray[indexPath.item]
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        var estimatedFrame = NSString(string: chat.text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
        estimatedFrame.size.height += 18
        return CGSize(width: chatCollView.frame.width, height: estimatedFrame.height + 20 + CGFloat(chat.estimated_Height))
    }
    
}

extension ChatVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
        textField.reloadInputViews()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 > 0 {
            textField.returnKeyType = .send
            textField.reloadInputViews()
        } else {
            textField.returnKeyType = .done
            textField.reloadInputViews()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.returnKeyType == .done {
            return true
        } else {
            onSendChat(nil)
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        onSendChat(nil)
    }
}
