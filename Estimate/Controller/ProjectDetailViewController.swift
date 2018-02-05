//
//  ProjectDetailViewController.swift
//  Estimate
//
//  Created by Thong Tran on 1/22/18.
//  Copyright © 2018 Thong Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ProjectDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceTotal: UIBarButtonItem!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var EstimateId: UILabel!
    @IBOutlet weak var addressName: UILabel!
    var totalAmount = "0"
    var itemsId: String!
    @IBOutlet weak var customerName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch_data()

        projectName.text = "Project Name: " + aProject.projectName
        EstimateId.text = "Estimate Id: " + aProject.projectId
        addressName.text = "Address: " + aProject.customerAddress
        customerName.text = "Customer Name: " + aProject.customerName
    }

    

    // Creating List array
    
    var aProject = Project()

    @IBAction func addDetailListBtn(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let NameField = alertController.textFields![0] as UITextField
            let priceField = alertController.textFields![1] as UITextField
            if NameField.text != "", priceField.text != "" {
                var item = List()
                item.itemName = NameField.text
                if let price = priceField.text {
                    item.itemPrice = Double(price)
                } 
                
                let id = NSUUID().uuidString
                let values = ["ItemName" : item.itemName, "ItemPrice" : item.itemPrice] as [String : Any]
                self.load_data(values: values as [String : AnyObject], itemsId: self.itemsId, id: id)
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
            textField.placeholder = "Item Name"
            textField.textAlignment = .center
        })
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Price"
            textField.keyboardType = .decimalPad
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func fetch_data () {
    Database.database().reference().child("Items").child(itemsId).observe(.value, with: { (snapshot) in
        if snapshot.childrenCount > 0 {
            self.aProject.itemsList.removeAll()
            
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let value = item.value as? [String:AnyObject]
                var list = List()
                list.itemName = value!["ItemName"] as? String ?? ""
                let price = value!["ItemPrice"] as! Double
                list.itemPrice = price
                self.aProject.itemsList.append(list)
            }
            
            self.tableView.reloadData()
            self.displayTotalPrice()
        
            
        }
        
      
        
            })
    }
    
    func load_data ( values: [String : AnyObject], itemsId: String, id: String)
    {
        let ref: DatabaseReference!
        ref = Database.database().reference(fromURL: "https://estimate-26ca5.firebaseio.com/")
        let childRef = ref.child("Items").child(itemsId).child(id)
        childRef.updateChildValues(values) { (err, ref) in
            if (err != nil)
            {
                
            }
        }
    }
    
    // Calculate the amount added
    func calculateAmount () {
        var total = 0.0
        for item in aProject.itemsList {
            total += item.itemPrice
        }
        totalAmount = String(total)
    }
    func displayTotalPrice () {
        calculateAmount()
        self.priceTotal.title = "$" + totalAmount
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "preview"
        {
            if let destination = segue.destination as? PreviewViewController{
                destination.aProject = self.aProject
            }
        }
    }
    
    func update_values ( value : [String:AnyObject]) {
        let userid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Projects").child(userid!)
        ref.setValue(value)
    }
    
    @IBAction func editBtn(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit ", message: "Choose item you want to edit?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Change Customer Name", style: .destructive, handler: {
            (alert:UIAlertAction!) in
            
            let changeNameAlert = UIAlertController(title: "Change Name", message: nil, preferredStyle: .alert)
            
            changeNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertName) in
                let NameField = changeNameAlert.textFields![0] as UITextField
                if NameField.text != ""{
                    self.aProject.customerName = NameField.text
                    self.customerName.text = "Customer Name: " + NameField.text!
                  
                    let values = ["projectName": self.aProject.projectName, "projectId" : self.aProject.projectId, "CustomerName" : self.aProject.customerName, "CustomerAdd" : self.aProject.customerAddress, "Date" : self.aProject.day, "Items": self.aProject.itemsId]
                    self.update_values(value: values as [String : AnyObject])
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter info fully", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                        alert -> Void in
                        self.present(changeNameAlert, animated: true, completion: nil)
                    }))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }))
            
            changeNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertNameCancel) in
                self.present(alertController, animated: true, completion: nil)
            }))
            changeNameAlert.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "New Customer Name"
                textField.textAlignment = .center
            })
            self.present(changeNameAlert, animated: true, completion: nil)
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Change Customer Address", style: .destructive, handler: {
            (alert:UIAlertAction!) in
            
            
            let changeNameAlert = UIAlertController(title: "Change Address", message: nil, preferredStyle: .alert)
            
            changeNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertName) in
                let NameField = changeNameAlert.textFields![0] as UITextField
                if NameField.text != ""{
                    self.aProject.customerAddress = NameField.text
                    self.addressName.text = "Address: " + NameField.text!
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter info fully", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                        alert -> Void in
                        self.present(changeNameAlert, animated: true, completion: nil)
                    }))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }))
            
            changeNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertNameCancel) in
                self.present(alertController, animated: true, completion: nil)
            }))
            changeNameAlert.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "New Customer Address"
                textField.textAlignment = .center
            })
            self.present(changeNameAlert, animated: true, completion: nil)
            
        }))
        
        
        
        alertController.addAction(UIAlertAction(title: "Change Project Name", style: .destructive, handler: {
            (alert:UIAlertAction!) in
            let changeNameAlert = UIAlertController(title: "Change Project Name", message: nil, preferredStyle: .alert)
            
            changeNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertName) in
                let NameField = changeNameAlert.textFields![0] as UITextField
                if NameField.text != ""{
                    self.aProject.projectName = NameField.text
                    self.projectName.text = "Project Name: " + NameField.text!
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter info fully", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                        alert -> Void in
                        self.present(changeNameAlert, animated: true, completion: nil)
                    }))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }))
            
            changeNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertNameCancel) in
                self.present(alertController, animated: true, completion: nil)
            }))
            changeNameAlert.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "New Project Name"
                textField.textAlignment = .center
            })
            self.present(changeNameAlert, animated: true, completion: nil)
            
        }))
     
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension ProjectDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aProject.itemsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "projectDetail", for: indexPath) as! ProjectDetailTableViewCell
        // cell.project = projects[indexPath.row]
        cell.list = aProject.itemsList[indexPath.row]
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this Item?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {
                (alert:UIAlertAction!) in
                
                let ref = Database.database().reference().child("Items").child(self.itemsId!)
                
                ref.queryOrdered(byChild: "ItemName").queryEqual(toValue: self.aProject.itemsList[indexPath.row].itemName).observe(.childAdded, with: { (snapshot) in               
                    snapshot.ref.removeValue(completionBlock: { (error, reference) in
                        if error != nil {
                            print("There has been an error:\(error)")
                        }
                    })
                })
                
                
                
                self.aProject.itemsList.remove(at: indexPath.row)
                self.displayTotalPrice()
                self.tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
}







