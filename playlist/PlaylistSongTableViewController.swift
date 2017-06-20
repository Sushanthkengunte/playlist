//
//  PlaylistSongTableViewController.swift
//  playlist
//
//  Created by Sushanth on 6/15/17.
//  Copyright © 2017 SuProject. All rights reserved.
//---------------------------------------------------
// - The model for this view Controller is playlistName
//    which contains the data to be displayed
//---------------------------------------------------
// * Files Required:
//   - UIKit
//   -Firebase Database
// * Pods required
//   - Firebase/Database


import UIKit

import FirebaseDatabase

class PlaylistSongTableViewController: UITableViewController {
    // when playlistName is set the table is populated by getting the songs against that playlist
    var playlistName : String! = nil
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        populateTable(playlistNameIs: playlistName)
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    //gets the songs for a particular playlist
    func populateTable(playlistNameIs:String){
        let dbReference = FIRDatabase.database().reference()
        
        dbReference.child("playlistsDatabase").observeSingleEvent(of: .value, with: {(snapshot) in
            
            var pLists = snapshot.value as? [String:Any] ?? [:]
            let arrayOfSongs = pLists[playlistNameIs] ?? [String]()
            
            let songList : [String] = arrayOfSongs as! [String]
            
            //songList.append(name)
            self.songsInPlaylist = songList
            if(self.songsInPlaylist.count == 0){
                let alertController = UIAlertController(title: "Empty playlist", message: "Please add songs by selecting from the songs tab", preferredStyle: .alert)
                
              
                alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alertController, animated: true, completion: nil)
                
            }
          //  dbReference.child("playlistsDatabase/\(playlistName)").setValue(songList)
            self.tableView.reloadData()
            
            
        })
        
    }
    // Override to support editing the table view.
    
  
    private var songsInPlaylist = [String]()
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //   tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            let dbReference = FIRDatabase.database().reference()
            // let playlistID = UUID().uuidString
            dbReference.child("playlistsDatabase").observeSingleEvent(of: .value, with: {(snapshot) in
                var pLists = snapshot.value as? [String:Any] ?? [:]
                let arrayOfSongs = pLists[self.playlistName] ?? [String]()
                
                var songList1 : [String] = arrayOfSongs as! [String]
                let deletedSong = songList1[indexPath.row]
              
                songList1.remove(at: indexPath.row)
               self.songsInPlaylist = songList1
                dbReference.child("playlistsDatabase/\(self.playlistName!)").setValue(songList1)
                let alertController = UIAlertController(title: "Delete", message: "Successfully deleted:\(deletedSong)", preferredStyle: .alert)
                
                
                alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertController, animated: true, completion: nil)

                self.tableView.reloadData()
                
            })
            
        }
    }
    //let rightTopButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightTopButton = UIBarButtonItem.init(title: "Add", style: .done, target: self, action: #selector(rightButtonAcion))
        self.navigationItem.rightBarButtonItem = rightTopButton
    }
    func rightButtonAcion(sender:UIBarButtonItem){
        performSegue(withIdentifier: "addSongToPlaylist", sender: sender)
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSongToPlaylist"{
            let vC = segue.destination as! songsList
            vC.playlistFromSpngsInPlaylist = playlistName
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songsInPlaylist.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsInPlaylist", for: indexPath) as! PlaylistSongTableViewCell
        cell.SongsList.text = songsInPlaylist[indexPath.row]

        // Configure the cell...

        return cell
    }


   

}
