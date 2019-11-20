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
    @IBOutlet weak var postButton: UIButton!
    
    var song : String?
    var artwork : UIImage?
    var artist : String?
    
    let music_player = MPMusicPlayerController.systemMusicPlayer

    var exportImage: UIImage?
    
    @IBOutlet weak var noSongPlayingLabel: UILabel!

    let messages : [String] = ["Please go to the Music app and begin playing your music.", "If music is playing and image isn't showing up, please add the song to your library, clear the music app and try again."]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        /*
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
 */
        screenshotPurposes()
    }
    
    func setUp() {
        music_player.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self,selector: #selector(songChanged),name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,object: nil)
    }
    func screenshotPurposes() {
        song = "SICKO MODE"
        artist = "Travis Scott"
        artwork = UIImage(named: "travis")
        instantiate(value: true)
    }
    func getSong() {
        song = music_player.nowPlayingItem?.title
        artist = music_player.nowPlayingItem?.artist
        artwork = music_player.nowPlayingItem?.artwork?.image(at: simpleContent.songImage.bounds.size)
        
        if song == nil {
            hideAndDisable()
        } else if artwork == nil {
            hideAndDisableWithTips()
        } else {
            song = trimSong(songTitle: song!)
            unhideAndEnable()
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
    @IBAction func instagramTapped(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: simpleContent.bounds.size)
        exportImage = renderer.image { ctx in
            simpleContent.drawHierarchy(in: simpleContent.bounds, afterScreenUpdates: true)
        }
        shareToInstagramStories()
    }
    @IBAction func saveTapped(_ sender: Any) {
        //let imageData = UIImage.pngData(imageExport!)
        UIImageWriteToSavedPhotosAlbum(exportImage!, nil, nil, nil)
        let alert = UIAlertController(title: "Saved", message: "Image saved to camera roll", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func instantiateSimple() {
        instantiate(value: true)
    }
    func instantiateArtworkBackground() {
        instantiate(value: false)
    }
    
    func instantiate(value: Bool) {
        if value == true {
            let colors = artwork?.getColors()
            
            simpleContent.backgroundImage.isHidden = true
            simpleContent.backgroundColor = colors?.background
        } else {
            simpleContent.backgroundImage.isHidden = false
            simpleContent.backgroundImage.image = artwork!
            simpleContent.backgroundImage.blurView.setup(style: UIBlurEffect.Style.light, alpha: 0.99).enable()
            
            simpleContent.backgroundImage.contentMode = .scaleAspectFill
        }
        simpleContent.isHidden = false

        let colors = artwork?.getColors()
        
        simpleContent.layer.shadowPath = UIBezierPath(roundedRect: simpleContent.layer.bounds, cornerRadius: 0).cgPath
        simpleContent.layer.shadowColor = colors?.primary.cgColor
        simpleContent.layer.shadowOpacity = 0.3
        simpleContent.layer.shadowOffset = CGSize(width: 10, height: 10)
        simpleContent.layer.shadowRadius = 15
        simpleContent.layer.masksToBounds = false
        
        simpleContent.artistLabel.text = "by " + artist!
        simpleContent.songTitle.text = song!
        
        //simpleContent.songImage.image = music_player.nowPlayingItem?.artwork?.image(at: simpleContent.songImage.bounds.size)
        simpleContent.songImage.image = artwork
        simpleContent.songImage.layer.shadowPath = UIBezierPath(roundedRect: simpleContent.songImage.bounds, cornerRadius: 0).cgPath
        simpleContent.songImage.layer.shadowColor = colors?.detail.cgColor
        simpleContent.songImage.layer.shadowOpacity = 0.5
        simpleContent.songImage.layer.shadowOffset = CGSize(width: 10, height: 10)
        simpleContent.songImage.layer.shadowRadius = 17
        simpleContent.songImage.layer.masksToBounds = false
        simpleContent.songTitle.textColor = colors?.primary
        simpleContent.artistLabel.textColor = colors?.secondary
        simpleContent.appleMusic.textColor = colors?.detail
        
        postButton.backgroundColor = colors?.primary
    }
    func hideAndDisable() {
        simpleContent.isHidden = true
        segmentedControl.isEnabled = false
        postButton.isHidden = true
        noSongPlayingLabel.text = messages[0]
    }
    func hideAndDisableWithTips() {
        simpleContent.isHidden = true
        segmentedControl.isEnabled = false
        postButton.isHidden = true
        noSongPlayingLabel.text = messages[1]
    }
    func unhideAndEnable() {
        simpleContent.isHidden = false
        segmentedControl.isEnabled = true
        postButton.isHidden = false
    }
    func trimSong(songTitle: String) -> String {
        if let index = songTitle.index(of: "(feat.") {
            let substring = songTitle[..<index]   // ab
            let string = String(substring)
            return string
        } else if let index = songTitle.index(of: "(with") {
            let substring = songTitle[..<index]   // ab
            let string = String(substring)
            return string
        }
        return songTitle
    }
    private func shareToInstagramStories() {
        guard let imagePNGData = exportImage!.pngData() else { return }
        guard let instagramStoryUrl = URL(string: "instagram-stories://share") else { return }
        guard UIApplication.shared.canOpenURL(instagramStoryUrl) else { return }

        let itemsToShare: [[String: Any]] = [["com.instagram.sharedSticker.backgroundImage": imagePNGData]]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [.expirationDate: Date().addingTimeInterval(60 * 5)]
        UIPasteboard.general.setItems(itemsToShare, options: pasteboardOptions)
        UIApplication.shared.open(instagramStoryUrl, options: [:], completionHandler: nil)
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


