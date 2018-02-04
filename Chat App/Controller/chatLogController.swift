//
//  chatLogController.swift
//  Chat App
//
//  Created by Siddique on 03/02/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit
import Firebase
class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
        }
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
        setupLoad()
    }
    func setupLoad() {
        let containerView = UIView()
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
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childID = ref.childByAutoId()
        let fromID = Auth.auth().currentUser!.uid
        let toID = user!.id!
        let timestamp = Int(Date().timeIntervalSince1970)
        let values = ["messages": inputTextfield.text!, "FromID": fromID ,
                      "ToID": toID, "timestamp": timestamp ]
                        as [String: Any]
//        childID.updateChildValues(values)
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
