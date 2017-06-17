//
//  songsList.swift
//  playlist
//
//  Created by Sushanth on 6/14/17.
//  Copyright © 2017 SuProject. All rights reserved.
//

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
                        let each = jsonResult[i] as! NSDictionary
                        let album = each["albums"] as! NSArray
                        // let songs = album["songs"]
                        for j in 0..<album.count{
                            let songsInAlbum = album[j] as! NSDictionary
                            let songofablbumList = songsInAlbum["songs"] as! NSArray
                            for k in 0..<songofablbumList.count{
                                
                                let oneSong = songofablbumList[k] as! NSDictionary
                                print(oneSong)
                                songList.append(songs.init(name: oneSong["title"] as! String ?? "", length: oneSong["length"] as! String ?? ""))
                                
                            }
                            
                        }
                        
                        
                    }
                    //print(jsonResult)
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
        var indexPath : IndexPath? = tableView.indexPathForRow(at: touchLocation)
        if sender.state == .began{
            if let indexOfRow = indexPath{
                let dbReference = FIRDatabase.database().reference()
                
                dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
                    if snapshot.childrenCount == 0{
                        //TO-DO add alert controller to display no playlist yet and to create a new playlist
                        // self.listOfPlaylist.append("No Playlist added")
                        
                    }
                    else{
                        
                        var pLists = snapshot.value as! [String:Any]
                        self.listOfPlay = Array(pLists.keys)
                        //let cell : UITableViewCell = tableView.cellForRow(at: indexPath)
                        self.displayOptionsWhenLongPress(index: indexOfRow.row)
                        
                       // self.displayAllPlaylist(index: indexOfRow.row)
                        
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
                
               // self.populateTable()
                
            }
            else{
                var pLists = snapshot.value as! [String:Any]
                var array = Array(pLists.keys)
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
                    
                   // self.populateTable()
                }
            }
            
        })
        
        
    }
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     //   tableView.deleteRows(at: [indexPath], with: .fade)
     
     
     let dbReference = FIRDatabase.database().reference()
     // let playlistID = UUID().uuidString
     dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
     if snapshot.childrenCount == 0{
     //TO-DO add alert controller to display no playlist yet and to create a new playlist
     // self.listOfPlaylist.append("No Playlist added")
     
     }
     else{
     //self.listOfPlaylist.removeAll()
     var pLists = snapshot.value as! [String:Any]
     self.listOfPlay = Array(pLists.keys)
     
     self.displayAllPlaylist(index: indexPath.row)
     
     }
     
     })
     
     }
     }*/
    private func displayOptionsWhenLongPress(index:Int){
        if playlistFromSpngsInPlaylist == nil{
        let alertController = UIAlertController(title: "Choose", message: "Select your preference", preferredStyle: .actionSheet)
     
        alertController.addAction(UIAlertAction(title: "Create New playlist", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            var temp = self.songList[index]
            
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
        
            var temp = self.songList[index]
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
                var temp = self.songList[index]
                
                self.addToTheListOfPlaylist(name: temp.name, playlistName: self.listOfPlay[i].replacingOccurrences(of: "%20", with: " "))
                self.dismiss(animated: true, completion: nil)
                let aC = UIAlertController(title: "Added", message: "\(temp.name) to playlis: \(self.listOfPlay[i].replacingOccurrences(of: "%20", with: " "))", preferredStyle: .alert)
                aC.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(aC, animated: true, completion: nil)
                
                //self.addToPlaylistDatabase(pName: playlistName.text!)
                
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
            var arrayOfSongs = pLists[playlistName] ?? [String]()
            var songList : [String] = arrayOfSongs as! [String]
            songList.append(name)
            
            dbReference.child("playlistsDatabase/\(playlistName)").setValue(songList)
            self.tableView.reloadData()
            
            
        })
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "add"
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
