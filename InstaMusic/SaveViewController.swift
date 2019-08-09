//
//  SaveViewController.swift
//  InstaMusic
//
//  Created by Anirban Kumar on 8/1/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit

class SaveViewController: UIViewController {

    var imageExport: UIImage!
    var background: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = background
    }
    @IBAction func postTapped(_ sender: Any) {
        //shareBackgroundImage()
        shareToInstagramStories()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        //let imageData = UIImage.pngData(imageExport!)
        UIImageWriteToSavedPhotosAlbum(imageExport, nil, nil, nil)
        let alert = UIAlertController(title: "Saved", message: "Image saved to camera roll", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareBackgroundImage() {
        let image = imageExport

        if let pngImage = image!.pngData() {
            //backgroundImage(pngImage, attributionURL: nil)
            //backgroundImage(pngImage)//, attributionURL: nil)
        }
    }

    func backgroundImage(_ backgroundImage: Data) /*, attributionURL: String)*/ {
        // Verify app can open custom URL scheme, open if able

        guard let urlScheme = URL(string: "instagram-stories://share"),
            UIApplication.shared.canOpenURL(urlScheme) else {
                // Handle older app versions or app not installed case

                return
        }

        let pasteboardItems = [["com.instagram.sharedSticker.backgroundImage": backgroundImage /*,
                                "com.instagram.sharedSticker.contentURL": attributionURL]*/]]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [.expirationDate: Date().addingTimeInterval(60 * 5)]

        // This call is iOS 10+, can use 'setItems' depending on what versions you support
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

        UIApplication.shared.open(urlScheme)
    }
    
    private func shareToInstagramStories() {
        guard let imagePNGData = imageExport.pngData() else { return }
        guard let instagramStoryUrl = URL(string: "instagram-stories://share") else { return }
        guard UIApplication.shared.canOpenURL(instagramStoryUrl) else { return }

        let itemsToShare: [[String: Any]] = [["com.instagram.sharedSticker.backgroundImage": imagePNGData]]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [.expirationDate: Date().addingTimeInterval(60 * 5)]
        UIPasteboard.general.setItems(itemsToShare, options: pasteboardOptions)
        UIApplication.shared.open(instagramStoryUrl, options: [:], completionHandler: nil)
    }
    
}
