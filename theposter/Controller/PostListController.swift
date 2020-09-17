//
//  PostTableViewController.swift
//  theposter
//
//  Created by Admin on 15/09/2017.
//  Copyright © 2017 pavbox. All rights reserved.
//

import UIKit

class PostListController: UITableViewController {

    typealias postDictionary = [[String: Any?]]
    
    // MARK: Properties

    private var postCollection: postDictionary = []
    private var fetch_data: FetchData?

    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        navigationItem.rightBarButtonItem = editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshControl?.endRefreshing()
        tableView.setEditing(false, animated: false)
    }

    // MARK: - TableView Data Source
    
    @objc func refresh(_ sender: Any) {
        fetch_data = FetchData();
        fetch_data!.downloadPostList() { postList in
            self.postCollection = postList
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        };
    }
    
    @IBAction func refreshList(_ sender: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(postCollection.count, 0);
    }

    // MARK: Override Default Cell view
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell else {
            fatalError("The dequeued cell is not an instance of PostTableViewCell.")
        }
        
        if postCollection.count < 1 { return cell }
        
        let post = postCollection[indexPath.row]
        cell.titleCell.text = post["title"] as? String
        cell.imageURL = URL(string: "\((fetch_data?.API_ADDR)!)/post/\(post["id"] as! String)/upload_thumbs")
        return cell
    }

    @IBAction func editPosts(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        refreshControl?.beginRefreshing()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fetch_data?.removePostById(postCollection[indexPath.row]["id"] as! String)
            postCollection.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - Navigation segues
    
    var seguePost: [String: Any?]?
    
    @IBAction func addPost(_ sender: UIButton) {
        seguePost = nil
        self.performSegue(withIdentifier: "segue_global", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        seguePost = postCollection[indexPath.row]
        
        // create new segue (needs available on board)
        self.performSegue(withIdentifier: "segue_global", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segue_global" && seguePost != nil) {
            let viewController = segue.destination as! PostPageController
            viewController.seguePost = seguePost
        }
    }
}

extension UIViewController {
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = style == .lightContent ? UIColor.black : .white
            statusBar.setValue(style == .lightContent ? UIColor.white : .black, forKey: "foregroundColor")
        }
    }
}
