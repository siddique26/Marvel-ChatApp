//
//  chatLogController.swift
//  Chat App
//
//  Created by Siddique on 03/02/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit
import Firebase
class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    var messages = [Message]()
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    func observeMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let childRef = Database.database().reference().child("user-message").child(uid)
        childRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)
//                message.setValuesForKeys(dictionary)
//                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
//                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    lazy var inputTextfield: UITextField = {
        let messageBody = UITextField()
        //        messageBody.layer.cornerRadius = 5
        //        messageBody.layer.masksToBounds = true
        messageBody.backgroundColor = UIColor.white
        messageBody.translatesAutoresizingMaskIntoConstraints = false
        messageBody.placeholder = "Enter Message.."
        messageBody.delegate = self
        return messageBody
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatViewCell.self, forCellWithReuseIdentifier: cellId)
        setupLoad()
    }
    func setupLoad() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let send = UIButton(type: .system)
        send.setTitle("Send", for: .normal)
        send.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        send.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(send)
        send.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        send.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        send.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        send.widthAnchor.constraint(equalToConstant: 60).isActive = true
        send.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        containerView.addSubview(inputTextfield)
        inputTextfield.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        inputTextfield.rightAnchor.constraint(equalTo: send.leftAnchor).isActive = true
        inputTextfield.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextfield.heightAnchor.constraint(equalToConstant: 25).isActive = true
        let seperateLine = UIView()
        seperateLine.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        seperateLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperateLine)
        seperateLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperateLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperateLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperateLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatViewCell)!
        let message = messages[indexPath.item]
        cell.textView.text = message.messages
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childID = ref.childByAutoId()
        let fromID = Auth.auth().currentUser!.uid
        let toID = user!.id!
        let timestamp = Int(Date().timeIntervalSince1970)
        let values = ["messages": inputTextfield.text!, "FromID": fromID ,
                      "ToID": toID, "timestamp": timestamp ]
                        as [String: Any]
        // Fanning out
        childID.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            let userMessagesref = Database.database().reference().child("user-message").child(fromID)
            let messageId = childID.key
            userMessagesref.updateChildValues([messageId: 1])
            let recipientuserMessageRef = Database.database().reference().child("user-message").child(toID)
            recipientuserMessageRef.updateChildValues([messageId: 1])
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
