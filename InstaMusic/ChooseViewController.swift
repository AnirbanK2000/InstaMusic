//
//  ChooseViewController.swift
//  InstaMusic
//
//  Created by Anirban Kumar on 7/31/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import MediaPlayer

class ChooseViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var simpleContent: SimpleColorView!
    @IBOutlet weak var continueButton: UIButton!
    
    var titleOfSong : String?
    var imageOfSong : UIImage?
    var artistOfSong : String?
    
    let player = MPMusicPlayerController.systemMusicPlayer

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
            case .authorized:
                print("authorized")
                setUp()
                getSong()
                break
            case .notDetermined:
                MPMediaLibrary.requestAuthorization() { status in
                        if status == .authorized {
                            DispatchQueue.main.async {
                                self.setUp()
                                self.getSong()
                            }
                        }
                    }
                break
        case .denied:
            break
        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    func setUp() {
        player.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self,selector: #selector(songChanged),name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,object: nil)
    }
    
    func getSong() {
        //print(player.nowPlayingItem?.title)
        //titleOfSong = trimSong(song: (player.nowPlayingItem?.title)!)
        titleOfSong = player.nowPlayingItem?.title
        artistOfSong = player.nowPlayingItem?.artist
        imageOfSong = player.nowPlayingItem?.artwork?.image(at: simpleContent.songImage.bounds.size)
        
        if titleOfSong == nil {
            simpleContent.isHidden = true
            segmentedControl.isEnabled = false
            continueButton.isHidden = true
        } else {
            titleOfSong = trimSong(song: (player.nowPlayingItem?.title)!)
            segmentedControl.isEnabled = true
            continueButton.isHidden = false
            instantiateSimple()
        }
        
    }
    @objc func songChanged(_ notification: Notification){
        getSong()
        if segmentedControl.selectedSegmentIndex == 0 {
            instantiateSimple()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            instantiateArtworkBackground()
        }
    }
    
    
    @IBAction func backgroundStyleChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            instantiateSimple()
        case 1:
            instantiateArtworkBackground()
        default:
            break
        }
    }
    @IBAction func nextTapped(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "saveVC") as! SaveViewController
    
        self.present(newViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let colors = imageOfSong?.getColors()

        if segue.destination is SaveViewController
        {
            
            let renderer = UIGraphicsImageRenderer(size: simpleContent.bounds.size)
            let export = renderer.image { ctx in
                simpleContent.drawHierarchy(in: simpleContent.bounds, afterScreenUpdates: true)
            }
            let vc = segue.destination as? SaveViewController
            vc?.imageExport = export
            vc?.background = colors?.background
            vc?.textColor = colors?.detail
        }
    }
    
    func instantiateSimple() {
        instantiate()
        let colors = imageOfSong?.getColors()
        
        simpleContent.backgroundImage.isHidden = true
        simpleContent.backgroundColor = colors?.background
    }
    func instantiateArtworkBackground() {
        instantiate()

        simpleContent.backgroundImage.isHidden = false
        simpleContent.backgroundImage.image = imageOfSong!
        simpleContent.backgroundImage.blurView.setup(style: UIBlurEffect.Style.light, alpha: 0.99).enable()
        
        simpleContent.backgroundImage.contentMode = .scaleAspectFill
    }
    
    func instantiate() {
        simpleContent.isHidden = false

        let colors = imageOfSong?.getColors()
        
        simpleContent.layer.shadowPath = UIBezierPath(roundedRect: simpleContent.layer.bounds, cornerRadius: 0).cgPath
        simpleContent.layer.shadowColor = colors?.primary.cgColor
        simpleContent.layer.shadowOpacity = 0.3
        simpleContent.layer.shadowOffset = CGSize(width: 10, height: 10)
        simpleContent.layer.shadowRadius = 15
        simpleContent.layer.masksToBounds = false
        
        simpleContent.artistLabel.text = "by " + artistOfSong!
        simpleContent.songTitle.text = titleOfSong!
        simpleContent.songImage.image = imageOfSong!
        simpleContent.songImage.layer.shadowPath = UIBezierPath(roundedRect: simpleContent.songImage.bounds, cornerRadius: 0).cgPath
        simpleContent.songImage.layer.shadowColor = colors?.detail.cgColor
        simpleContent.songImage.layer.shadowOpacity = 0.5
        simpleContent.songImage.layer.shadowOffset = CGSize(width: 10, height: 10)
        simpleContent.songImage.layer.shadowRadius = 17
        simpleContent.songImage.layer.masksToBounds = false
        simpleContent.songTitle.textColor = colors?.primary
        simpleContent.artistLabel.textColor = colors?.secondary
        simpleContent.appleMusic.textColor = colors?.detail
        
        continueButton.backgroundColor = colors?.primary
    }
    
    func trimSong(song: String) -> String {
        if let index = song.index(of: "(feat.") {
            let substring = song[..<index]   // ab
            let string = String(substring)
            return string
        } else if let index = song.index(of: "(with") {
            let substring = song[..<index]   // ab
            let string = String(substring)
            return string
        }
        return song
        
    }
}
extension StringProtocol { // for Swift 4.x syntax you will needed also to constrain the collection Index to String Index - `extension StringProtocol where Index == String.Index`
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}


