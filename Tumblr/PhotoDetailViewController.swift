//
//  PhotoDetailViewController.swift
//  Tumblr
//
//  Created by Huang Edison on 1/17/17.
//  Copyright © 2017 Edison. All rights reserved.
//

import UIKit
import AFNetworking

class PhotoDetailViewController: UIViewController {

    
    @IBOutlet weak var posterView: UIImageView!
    
    var post: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let photos = post["photos"] as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                posterView.setImageWith(imageUrl)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
