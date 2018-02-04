//
//  ViewController.swift
//  Chat App
//
//  Created by Siddique on 31/01/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit
import Firebase
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class MessageController: UITableViewController {

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain,
            target: self,
            action: #selector(handleLogout))
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self,
            action: #selector(handleImage))
        // user is not registered
        checkUserLoggedIn()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    func observeUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    if let toId = message.toID {
                        self.messageDictionary[toId] = message
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                        })
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell)!
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    @objc func handleImage() {
        let newMessage = NewMessageController()
        newMessage.messageController = self
        let navController = UINavigationController(rootViewController: newMessage)
        present(navController, animated: true, completion: nil)
    }
    func checkUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            userLoginAndSetBavBar()
        }
    }
    func userLoginAndSetBavBar() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = Users(dictionary: dictionary)
                    self.setupNavBarWithUser(user)
                }
            }, withCancel: nil)
    }
    func setupNavBarWithUser(_ user: Users) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessage()
        let TitleView = UIView()
        TitleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageURL {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        TitleView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: TitleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: TitleView
            .centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let nameLabel = UILabel()
        TitleView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: TitleView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: TitleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: TitleView.heightAnchor).isActive = true
        self.navigationItem.titleView = TitleView
        TitleView.isUserInteractionEnabled = true
//        TitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    @objc func showChatController(_ user: Users) {
        let chatlogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatlogController.user = user
        navigationController?.pushViewController(chatlogController, animated: true)
    }
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.messagecontroller = self
        present(loginController, animated: true, completion: nil)
    }
}
