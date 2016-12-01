//
//  NewMessageVC.swift
//  ChetChat
//
//  Created by Martyn Cheatle on 29/11/2016.
//  Copyright © 2016 Martyn Cheatle. All rights reserved.
//

import UIKit
import Firebase


class NewMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [Users]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let user = Users(postKey: key, postData: postDict)
                        self.users.append(user)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func fetchUser() {
        
        DataService.ds.REF_USERS.observe(.childAdded, with: { (snapshot) in
            
        }, withCancel: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        print("USERS: \(user.username)")
         return tableView.dequeueReusableCell(withIdentifier: "MessagesCell")as! MessagesCell
    }
    
}
