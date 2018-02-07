//
//  chatViewCell.swift
//  Chat App
//
//  Created by Siddique on 06/02/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit

class ChatViewCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        return tv
    }()
    static var blueColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)

    let bubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        return image
    }()
    var bubbleWidth: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubble)
        addSubview(textView)
        addSubview(profileImage)
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 32).isActive = true
        bubbleRightAnchor = bubble.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubble.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8)
        bubbleLeftAnchor?.isActive = false
        bubble.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidth = bubble.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        bubble.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubble.rightAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubble.leftAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}
