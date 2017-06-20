//
//  songsList.swift
//  playlist
//
//  Created by Sushanth on 6/14/17.
//  Copyright © 2017 SuProject. All rights reserved.
//
//---------------------------------------------------
// - The model for this view Controller is songs
//    which contains the data to be displayed
//---------------------------------------------------
// * Files Required:
//   - UIKit
//   -Firebase Database
// * Pods required
//   - Firebase/Database

import UIKit
import FirebaseDatabase


//model for song list
struct songs{
    let name:String
    let length:String
}
class songsList: UITableViewController {
    var playlistFromSpngsInPlaylist:String! = nil
    
    var songList = [songs]()
    override func viewDidLoad() {
        super.viewDidLoad()
        populateTableUSingJSON()
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songList.count
    }
    //getting the songs from a JSON file "music"
    func populateTableUSingJSON(){
        if let path = Bundle.main.path(forResource: "music", ofType: "json"){
            do{
                let data1 =  try Data(contentsOf: URL(fileURLWithPath:path), options: .alwaysMapped)
                do{
                    let jsonResult = try JSONSerialization.jsonObject(with: data1, options: .mutableContainers) as! [NSDictionary]
                    for i in 0..<jsonResult.count{
                        let each = jsonResult[i] //as! NSDictionary
                        let album = each["albums"] as! NSArray

                        for j in 0..<album.count{
                            let songsInAlbum = album[j] as! NSDictionary
                            let songofablbumList = songsInAlbum["songs"] as! NSArray
                            for k in 0..<songofablbumList.count{
                                
                                let oneSong = songofablbumList[k] as! NSDictionary
                                print(oneSong)
                                songList.append(songs.init(name: oneSong["title"] as? String ?? "", length: oneSong["length"] as? String ?? ""))
                                
                            }
                            
                        }
                        
                        
                    }
                }catch{
                    print(error)
                }
            }catch{
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneSong", for: indexPath) as? EachSong
        let songInfo = songList[indexPath.row]
        
        cell?.songLabel.text = songInfo.name
        
        // Configure the cell...
        
        return cell!
    }
    
    
    
    
    private var listOfPlay = [String]()

    @IBAction func reactiontoLongPress(_ sender: UILongPressGestureRecognizer) {
        
        let touchLocation = sender.location(in: tableView)
        let indexPath : IndexPath? = tableView.indexPathForRow(at: touchLocation)
        if sender.state == .began{
            if let indexOfRow = indexPath{
                let dbReference = FIRDatabase.database().reference()
                
                dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
                    if snapshot.childrenCount == 0{
                        
                        let alertController = UIAlertController(title: "Playlist", message: "No playlist Created", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Create new playlist", style: .default, handler: { (action) in
                            let song_name = self.songList[indexOfRow.row].name
                        self.newPlaylist(name: song_name)
                        }))
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else{
                        
                        let pLists = snapshot.value as! [String:Any]
                        self.listOfPlay = Array(pLists.keys)
                        self.displayOptionsWhenLongPress(index: indexOfRow.row)
                        
                        
                    }
                    
                })
                
            }else{
                print("Long press on table")
            }
        }
        
    }
    func newPlaylist(name:String){
    
            
            let alertController = UIAlertController(title: "Create PlayList", message: "Provide a name for the playlist", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                
            }
            //saves the text in the text field of the alert window
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (Action) in
                let playlistName = alertController.textFields![0] as UITextField
                
                self.addToPlaylistDatabase(pName: playlistName.text!)
                self.addToTheListOfPlaylist(name: name, playlistName: playlistName.text!)
                self.dismiss(animated: true, completion: nil)
                let aC = UIAlertController(title: "Added ", message: "\(name) to \(playlistName.text!)", preferredStyle: .alert)
                aC.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(aC, animated: true, completion: nil)
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
            
        
    }
    func addToPlaylistDatabase(pName:String){
        let dbReference = FIRDatabase.database().reference()
        let playlistID = UUID().uuidString
        // checks if there are exisitng playlist and saves it
        dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount == 0{
                let withoutSpaces = pName.replacingOccurrences(of: " ", with: "%20")
                dbReference.child("playlists").setValue([withoutSpaces:playlistID])
                
                
            }
            else{
                var pLists = snapshot.value as! [String:Any]
                let array = Array(pLists.keys)
                let withoutSpaces = pName.replacingOccurrences(of: " ", with: "%20")
                let itemExists = array.contains(where: {
                    $0.range(of: withoutSpaces, options: .caseInsensitive) != nil
                })
                if(itemExists){
                    
                    let alertController = UIAlertController(title: "Error!", message: "The playlist already Exists", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                    
                }else{
                    
                    pLists[withoutSpaces] = playlistID
                    dbReference.child("playlists").setValue(pLists)
    
                }
            }
            
        })
        
        
    }

    private func displayOptionsWhenLongPress(index:Int){
        if playlistFromSpngsInPlaylist == nil{
        let alertController = UIAlertController(title: "Choose", message: "Select your preference", preferredStyle: .actionSheet)
     
        alertController.addAction(UIAlertAction(title: "Create New playlist", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            let temp = self.songList[index]
            
            self.newPlaylist(name: temp.name)
            
        }))
        alertController.addAction(UIAlertAction(title: "Add to existing playlist", style: .default, handler: { (action) in
            self.displayAllPlaylist(index: index)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        }else{
        
            let temp = self.songList[index]
            self.addToPlaylistDatabase(pName: playlistFromSpngsInPlaylist)
            self.addToTheListOfPlaylist(name: temp.name, playlistName: playlistFromSpngsInPlaylist)
             let alertController = UIAlertController(title: "Added", message: "\(temp.name) added to \(playlistFromSpngsInPlaylist!)", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    private func displayAllPlaylist(index : Int){
        
        let alertController = UIAlertController(title: "Add to PlayList", message: "Select the playlist to be added to", preferredStyle: .alert)
        for i in 0..<listOfPlay.count{
            alertController.addAction(UIAlertAction(title: listOfPlay[i].replacingOccurrences(of: "%20", with: " "), style: .default, handler: { (Action) in
                let temp = self.songList[index]
                
                self.addToTheListOfPlaylist(name: temp.name, playlistName: self.listOfPlay[i].replacingOccurrences(of: "%20", with: " "))
                self.dismiss(animated: true, completion: nil)
                let aC = UIAlertController(title: "Added", message: "\(temp.name) to playlis: \(self.listOfPlay[i].replacingOccurrences(of: "%20", with: " "))", preferredStyle: .alert)
                aC.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(aC, animated: true, completion: nil)
                
                
            }))
        }
     
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func addToTheListOfPlaylist(name:String,playlistName:String){
        let dbReference = FIRDatabase.database().reference()
        
        dbReference.child("playlistsDatabase").observeSingleEvent(of: .value, with: {(snapshot) in
            
            var pLists = snapshot.value as? [String:Any] ?? [:]
            let arrayOfSongs = pLists[playlistName] ?? [String]()
            var songList : [String] = arrayOfSongs as! [String]
            songList.append(name)
            
            dbReference.child("playlistsDatabase/\(playlistName)").setValue(songList)
            self.tableView.reloadData()
            
            
        })
    }

   
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
}
