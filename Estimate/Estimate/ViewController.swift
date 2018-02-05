//
//  ViewController.swift
//  Estimate
//
//  Created by Thong Tran on 1/21/18.
//  Copyright © 2018 Thong Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ViewController: UIViewController {
    // Hello World
    override func viewDidLoad() {
        super.viewDidLoad()
        //filteredData = projects
        fetch_data()
   
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var projects = [Project]()
    var filteredData =  [Project]()
    
    override func viewDidAppear(_ animated: Bool) {
        
        let index = tableView.indexPathForSelectedRow
        if (index != nil){
            self.tableView.reloadRows(at: [index!], with: UITableViewRowAnimation.automatic)
        }
    }
    // Create the project btn action
    @IBAction func projectNameAddBtn(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add project Name", message: "Enter Project Name", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let NameField = alertController.textFields![0] as UITextField
            let CustomerNameField = alertController.textFields![1] as UITextField
            let AddressNameField = alertController.textFields![2] as UITextField
            if NameField.text != "", CustomerNameField.text != "", AddressNameField.text != "" {
                
                // Do stuff to add on
                let project = Project()
                project.projectName = NameField.text
                project.customerName = CustomerNameField.text
                project.customerAddress = AddressNameField.text
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let result = formatter.string(from: date)
                project.day = result
                // Generate random id
                let randomId = String(arc4random_uniform(10000000))
                project.projectId = String(randomId)
                //self.projects.append(project)
                //self.filteredData.append(project)
                
                let projectId = NSUUID().uuidString
                let itemsId = NSUUID().uuidString                
                let values = ["projectName": project.projectName, "projectId" : project.projectId, "CustomerName" : project.customerName, "CustomerAdd" : project.customerAddress, "Date" : project.day, "Items": itemsId]
                self.load_data(values: values as [String : AnyObject], id: projectId)
               // self.tableView.reloadData()
                
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter info fully", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Project Name"
            textField.textAlignment = .center
        })
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Customer Name"
            textField.textAlignment = .center
        })
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Address"
            textField.textAlignment = .center
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transit" {
            if let destination = segue.destination as? ProjectDetailViewController, let index = tableView.indexPathForSelectedRow?.row {
                destination.aProject = filteredData[index]
                destination.itemsId = filteredData[index].itemsId
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if searchBar.showsCancelButton == false {
            if editingStyle == .delete{
                let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this Item?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {
                    (alert:UIAlertAction!) in
                    /*
                     let estimateId = self.filteredData[indexPath.row].projectId
                     var removeId = 0
                     self.filteredData.remove(at: indexPath.row)
                     for index in 0..<self.projects.count{
                     if self.projects[index].projectId == estimateId {
                     removeId = index
                     }
                     }
                     */
                  
                    let userId = Auth.auth().currentUser?.uid
                    let projectId = self.filteredData[indexPath.row].projectId
                    let itemId = self.filteredData[indexPath.row].itemsId
                    let ref = Database.database().reference().child("Projects").child(userId!)
                    ref.queryOrdered(byChild: "projectId").queryEqual(toValue: projectId).observe(.childAdded, with: { (snapshot) in
                        
                        snapshot.ref.removeValue(completionBlock: { (error, reference) in
                            if error != nil {
                                print("There has been an error:\(error)")
                            }
                        })
                    })
                    
                    let reference = Database.database().reference().child("Items").child(itemId!)
                    reference.removeValue()
                    self.filteredData.remove(at: indexPath.row)
                    self.projects.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Delete Error", message: "Cannot Delete Project while Searching", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    /////////
    // Load Data to the fire base
    func load_data (values: [String: AnyObject], id: String)
    {
        let ref : DatabaseReference!
        ref = Database.database().reference(fromURL: "https://estimate-26ca5.firebaseio.com/")
        let userId = Auth.auth().currentUser?.uid
        let childRef = ref.child("Projects").child(userId!).child(id)
        childRef.updateChildValues(values)
    }
    // Fetch Data from Firebase
    func fetch_data () {
        let userId = Auth.auth().currentUser?.uid
        Database.database().reference().child("Projects").child(userId!).observe(.value, with: { (snapshot) in
                //print(snapshot)
            if snapshot.childrenCount > 0 {
                    self.projects.removeAll()
                    self.filteredData.removeAll()
                for i in snapshot.children.allObjects as! [DataSnapshot] {
                    let value = i.value as? [String:AnyObject]
                    let project = Project()
                    project.customerAddress = value!["CustomerAdd"] as? String ?? ""
                    project.customerName = value!["CustomerName"] as? String ?? ""
                    project.day = value!["Date"] as? String ?? ""
                    project.projectId = value!["projectId"] as? String ?? ""
                    project.projectName = value!["projectName"] as? String ?? ""
                    project.itemsId = value!["Items"] as? String ?? ""
                    self.projects.append(project)
                    self.filteredData.append(project)
                }
                    self.tableView.reloadData()
            }
   
        }, withCancel: nil)
    }
}




extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "projectName", for: indexPath) as! ProjectTableViewCell
        cell.project = filteredData[indexPath.row]
        return cell
    }
    
}



extension ViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? projects : projects.filter { (item: Project) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return ((item.projectId.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil) || (item.customerName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil) )
        }
        
        tableView.reloadData()
    }
    
}


