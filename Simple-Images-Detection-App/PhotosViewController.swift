//
//  PhotosViewController.swift
//  Simple-Images-Detection-App
//
//  Created by 佐伯小遥 on 2025/05/19.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generatedTextLabel: UILabel!
    
    var takenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = takenImage
    }
}
