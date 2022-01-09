//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Nhan Nguyen on 1/7/22.
//  Copyright © 2022 Nhan Nguyen. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var queryLimit = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPosts()
    }
    
    func loadPosts() {
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = queryLimit
        
        query.findObjectsInBackground {
            (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                           
                for post in posts! {
                    self.posts.insert(post, at: 0)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    func loadMorePosts() {
        self.queryLimit += 5
        
        loadPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellTableViewCell") as! PostCellTableViewCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlStr = imageFile.url!
        let url = URL(string: urlStr)!
        
        cell.photoView.af_setImage(withURL: url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        // get the main storyboard
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        // get the UIWindow variable from SceneDelegate
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
