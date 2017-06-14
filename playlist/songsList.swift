//
//  songsList.swift
//  playlist
//
//  Created by Sushanth on 6/14/17.
//  Copyright © 2017 SuProject. All rights reserved.
//

import UIKit

//model for song list
struct songs{
    let name:String
    let length:String
}
class songsList: UITableViewController {

    var songList = [songs]()
    override func viewDidLoad() {
        super.viewDidLoad()
        populateTableUSingJSON()
        
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
        return songList.count
    }
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
                    print(jsonResult)
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
