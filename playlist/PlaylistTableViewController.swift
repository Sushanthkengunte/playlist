//
//  PlaylistTableViewController.swift
//  playlist
//
//  Created by Sushanth on 6/14/17.
//  Copyright © 2017 SuProject. All rights reserved.
//---------------------------------------------------
// - The model for this view Controller is listOfPlaylist
//    which contains the data to be displayed
//---------------------------------------------------
// * Files Required: 
//   - UIKit
//   -Firebase Database
// * Pods required
//   - Firebase/Database

import UIKit
import FirebaseDatabase

class PlaylistTableViewController: UITableViewController {
    var listOfPlaylist = [String]()
    //when '+' button is clicked a alert controller with a text field is popped
    @IBAction func creatingPlaylistName(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Create PlayList", message: "Provide a name for the playlist", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            
        }
        //saves the text in the text field of the alert window
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (Action) in
            let playlistName = alertController.textFields![0] as UITextField
            
            self.addToPlaylistDatabase(pName: playlistName.text!)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
  
    @IBOutlet weak var createNewPlaylist: UIBarButtonItem!
    // adds the playlist to the database checking if its already there by replacing space with %20
    func addToPlaylistDatabase(pName:String){
        let dbReference = FIRDatabase.database().reference()
        let playlistID = UUID().uuidString
        // checks if there are exisitng playlist and saves it
        dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount == 0{
                let withoutSpaces = pName.replacingOccurrences(of: " ", with: "%20")
                dbReference.child("playlists").setValue([withoutSpaces:playlistID])
                
                self.populateTable()
                
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
                    self.populateTable()
                }
            }
            
        })
        
       
    }
    //displays the data in the table
    func populateTable(){
        let dbReference = FIRDatabase.database().reference()
        // let playlistID = UUID().uuidString
        dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount == 0{
                self.listOfPlaylist.append("No Playlist added")
                
            }
            else{
                self.listOfPlaylist.removeAll()
                var pLists = snapshot.value as! [String:Any]
                var array1 = Array(pLists.keys)
                
                for i in 0..<array1.count{
                    var newWithSpace = array1[i].replacingOccurrences(of: "%20", with: " ")
                    self.listOfPlaylist.append(newWithSpace)
                }
                self.tableView.reloadData()
                
            }
            
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        populateTable()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfPlaylist.count
    }

    // sets each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as! PlaylistTableViewCell
        cell.playlistLabel.text = listOfPlaylist[indexPath.row]



        return cell
    }
    // hides the status Bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
    //while segueing to display the songs the playlist name is passed to the next view-Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSongs"{
            let rowSelected = tableView.indexPathForSelectedRow?.row
            let destinationVC = segue.destination as! PlaylistSongTableViewController
            destinationVC.playlistName = listOfPlaylist[rowSelected!]
            destinationVC.navigationItem.title = listOfPlaylist[rowSelected!]
            
        }
    }
    

}
