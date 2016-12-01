//
//  Users.swift
//  ChetChat
//
//  Created by Martyn Cheatle on 29/11/2016.
//  Copyright © 2016 Martyn Cheatle. All rights reserved.
//

import Foundation

class Users {
    private var _username: String!
    private var _imageUrl: String!
    private var _postKey: String!
    
    var username: String {
        return _username
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(username: String, imageUrl: String) {
        self._username = username
        self._imageUrl = imageUrl
    }
    
    init(postKey: String, postData: Dictionary<String, Any>){
        self._postKey = postKey
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
    }
}
