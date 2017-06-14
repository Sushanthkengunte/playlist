//
//  PlaylistTableViewController.swift
//  playlist
//
//  Created by Sushanth on 6/14/17.
//  Copyright © 2017 SuProject. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlaylistTableViewController: UITableViewController {
    var listOfPlaylist = [String]()
    @IBAction func creatingPlaylistName(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Create PlayList", message: "Provide a name for the playlist", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            
        }
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
    func addToPlaylistDatabase(pName:String){
        let dbReference = FIRDatabase.database().reference()
        let playlistID = UUID().uuidString
        dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount == 0{
                let withoutSpaces = pName.replacingOccurrences(of: " ", with: "%20")
                dbReference.child("playlists").setValue([withoutSpaces:playlistID])
                
                self.populateTable()
                
            }
            else{
                var pLists = snapshot.value as! [String:Any]
                var array = pLists.keys
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
        
       // print(pName)
    }
    func populateTable(){
        let dbReference = FIRDatabase.database().reference()
        // let playlistID = UUID().uuidString
        dbReference.child("playlists").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount == 0{
                self.listOfPlaylist.append("No Playlist added")
                
            }
            else{
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
        populateTable()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as! PlaylistTableViewCell
        cell.playlistLabel.text = listOfPlaylist[indexPath.row]

        // Configure the cell...

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
