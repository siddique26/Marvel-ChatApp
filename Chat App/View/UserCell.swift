//
//  UserCell.swift
//  Chat App
//
//  Created by Siddique on 04/02/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
        var message: Message? {
            didSet {
               setNameandProfileImage()
                detailTextLabel?.text = message?.messages
                if let seconds = message?.timestamp?.doubleValue {
                    let timeStamp = NSDate(timeIntervalSince1970: seconds)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "hh:mm:ss a"
                    timeLabel.text = dateFormatter.string(from: timeStamp as Date)
                }
            }
        }
    private func setNameandProfileImage() {
        let ChatpartnerId: String?
        if message?.fromID == Auth.auth().currentUser?.uid {
            ChatpartnerId = message?.toID
        } else {
            ChatpartnerId = message?.fromID
        }
        if let id = ChatpartnerId {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
                //                                        print(snapshot)
            }, withCancel: nil)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64,
                                  y: textLabel!.frame.origin.y+2,
                                  width: textLabel!.frame.width,
                                  height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64,
                                        y: detailTextLabel!.frame.origin.y-2,
                                        width: detailTextLabel!.frame.width,
                                        height: detailTextLabel!.frame.height)
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(named: "nedstark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
//        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        //Constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 85).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
