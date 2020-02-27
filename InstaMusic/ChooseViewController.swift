//
//  ChooseViewController.swift
//  InstaMusic
//
//  Created by Anirban Kumar on 7/31/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import MediaPlayer

class ChooseViewController: UIViewController, UIPopoverPresentationControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var simpleContent: SimpleColorView!
    @IBOutlet weak var postButton: UIButton!
    
    var song : String?
    var artwork : UIImage?
    var artist : String?
    
    let music_player = MPMusicPlayerController.systemMusicPlayer
    
    var exportImage: UIImage?
    
    @IBOutlet weak var noSongPlayingLabel: UILabel!
    
    var count = 100
    
    let messages : [String] = ["Please go to the Music app and begin playing your music or search for a song in the app.", "If music is playing and image isn't showing up, please add the song to your library, clear the music app and try again.","You have disabled access to Music, please go to Settings, Privacy, Media & Apple Music, and enable Music access or use the search feature in the app."]

    var searchController = UISearchController(searchResultsController: nil)

    let queryService = QueryService()
    var searchResults: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noSongPlayingLabel.sizeToFit()
        noSongPlayingLabel.adjustsFontSizeToFitWidth = true
        noSongPlayingLabel.textAlignment = .center
        
        let status = MPMediaLibrary.authorizationStatus()
        simpleContent.isHidden = true
        switch status {
        case .authorized:
            simpleContent.isHidden = false
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
            let alert = UIAlertController(title: "Music Access Denied", message: "Please go to Settings, Privacy, Media & Apple Music, and enable Music access.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Gotchu!", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            hideAndDisable_2()
            break
        case .restricted:
            break
        @unknown default:
            break
        }
        let backgroundTapped = UITapGestureRecognizer(target: self, action: #selector(self.handleBackgroundTapped(_:)))
        simpleContent.addGestureRecognizer(backgroundTapped)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //            self.screenshotPurposes()
        //        }
        self.tableView.isHidden = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    @objc func handleBackgroundTapped(_ sender: UITapGestureRecognizer? = nil) {
        let location = sender?.location(in: simpleContent).x
        let halfway_X = simpleContent.frame.width / 2
        if location! < halfway_X {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = simpleContent.backgroundImage.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.tag = count
            simpleContent.backgroundImage.addSubview(blurEffectView)
            count += 1
        } else if location! > halfway_X {
            self.simpleContent.viewWithTag(count)?.removeFromSuperview()
            count -= 1
        }
        
    }
    
    func setUp() {
        music_player.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self,selector: #selector(songChanged),name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,object: nil)
    }
    func screenshotPurposes() {
        song = "BUTTERFLY EFFECT"
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
    func saveTapped() {
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
        unhideAndEnable()
        let colors = artwork?.getColors()
        
        if value == true {
            simpleContent.backgroundImage.isHidden = true
            simpleContent.backgroundColor = colors?.background
        } else if value == false {
            simpleContent.backgroundImage.isHidden = false
            simpleContent.backgroundImage.image = artwork!
            
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = simpleContent.backgroundImage.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            simpleContent.backgroundImage.addSubview(blurEffectView)
            
            simpleContent.backgroundImage.contentMode = .scaleAspectFill
        }
        simpleContent.isHidden = false
        
        simpleContent.artistLabel.text = "by " + artist!
        simpleContent.songTitle.text = song!
        
        simpleContent.songImage.image = artwork
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.simpleContent.layer.shadowPath = UIBezierPath(roundedRect: self.simpleContent.layer.bounds, cornerRadius: 0).cgPath
            self.simpleContent.layer.shadowColor = colors?.primary.cgColor
            self.simpleContent.layer.shadowOpacity = 0.3
            self.simpleContent.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.simpleContent.layer.shadowRadius = 15
            self.simpleContent.layer.masksToBounds = false
            
            self.self.simpleContent.songImage.layer.shadowPath = UIBezierPath(roundedRect: self.simpleContent.songImage.bounds, cornerRadius: 0).cgPath
            self.simpleContent.songImage.layer.shadowColor = colors?.detail.cgColor
            self.simpleContent.songImage.layer.shadowOpacity = 0.5
            self.simpleContent.songImage.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.simpleContent.songImage.layer.shadowRadius = 17
            self.simpleContent.songImage.layer.masksToBounds = false
        }
        
        simpleContent.songTitle.textColor = colors?.primary
        simpleContent.artistLabel.textColor = colors?.secondary
        simpleContent.appleMusic.textColor = colors?.detail
        
        postButton.backgroundColor = colors?.primary
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Songs"
        
        searchController.obscuresBackgroundDuringPresentation = false
        present(searchController, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func hideAndDisable() {
        noSongPlayingLabel.isHidden = false
        simpleContent.isHidden = true
        segmentedControl.isHidden = true
        postButton.isHidden = true
        noSongPlayingLabel.text = messages[0]
    }
    func hideAndDisable_2() {
        noSongPlayingLabel.isHidden = false
        simpleContent.isHidden = true
        segmentedControl.isHidden = true
        postButton.isHidden = true
        noSongPlayingLabel.text = messages[2]
    }
    func hideAndDisableWithTips() {
        noSongPlayingLabel.isHidden = false
        simpleContent.isHidden = true
        segmentedControl.isHidden = true
        postButton.isHidden = true
        noSongPlayingLabel.text = messages[1]
    }
    func unhideAndEnable() {
        noSongPlayingLabel.isHidden = true
        simpleContent.isHidden = false
        segmentedControl.isHidden = false
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
        guard UIApplication.shared.canOpenURL(instagramStoryUrl) else {
            let alertController = UIAlertController(title: "Couldn't share", message: "In order to share to Instagram, you need to have it downloaded. You can save it to your camera roll for now.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Gotchu!", style: .cancel, handler: nil)
            let saveImage = UIAlertAction(title: "Save to Camera Roll", style: .default, handler: { action in
                self.saveTapped()
            })
            
            alertController.addAction(alertAction)
            alertController.addAction(saveImage)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let itemsToShare: [[String: Any]] = [["com.instagram.sharedSticker.backgroundImage": imagePNGData]]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [.expirationDate: Date().addingTimeInterval(60 * 5)]
        UIPasteboard.general.setItems(itemsToShare, options: pasteboardOptions)
        UIApplication.shared.open(instagramStoryUrl, options: [:], completionHandler: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchingTerms = searchController.searchBar.text else { return }
        if searchingTerms.count == 0 {
            self.tableView.isHidden = true
        }
        if searchingTerms.count > 0 {
            self.tableView.isHidden = false
            
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            queryService.getSearchResults(searchTerm: searchingTerms) { [weak self] results, errorMessage in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if let results = results {
                    self?.searchResults = results
                    self?.tableView.reloadData()
                    self?.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
                
                if !errorMessage.isEmpty {
                    print("Search error: " + errorMessage)
                }
            }
            
        }
    }
    
}

extension ChooseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier,
                                                            for: indexPath) as! TrackCell
        
        let track = searchResults[indexPath.row]
        cell.configure(track: track)

        return cell
    }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
    
  }
}
extension ChooseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //When user taps cell, play the local file, if it's downloaded.
    
        let track = searchResults[indexPath.row]
        song = searchResults[indexPath.row].name
        artist = searchResults[indexPath.row].artist
        var imageURL = URL(string: searchResults[indexPath.row].enlargedURL)
            
        downloadImage_2(from: imageURL!)
        
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.isActive = false
        tableView.isHidden = true
    }
    func getData_2(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage_2(from url: URL) {
        print("Download Started")
        getData_2(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.artwork = UIImage(data: data)
                self.instantiateSimple()
            }
        }
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


