//
//  CategoryViewControllerTableViewController.swift
//  ToDo
//
//  Created by Asif's Mac on 27/7/20.
//  Copyright © 2020 Asif's Mac. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewControllerTableViewController: UITableViewController {

    var Arrayvalues = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist"))
        
        readData()
        
          }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Arrayvalues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = Arrayvalues[indexPath.row].name
        
        return cell
    }
    
    //MARK:- Table View delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        
        if let indexpath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = Arrayvalues[indexpath.row]
        }
    }

    
//MARK:- Add Button Pressed
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController.init(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Done", style: .default) { (action) in
            
            let addName = Category(context: self.context)
            addName.name = textField.text
            self.Arrayvalues.append(addName)
            self.createData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Enter Category Name"
            
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- Data Manipulation , Coredata- CRUD
    
    func createData() {
        do{
           try context.save()
        }catch{
            print("Error creating data::- \(error)")
        }
        tableView.reloadData()

    }
    
    func readData() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do{
           Arrayvalues = try context.fetch(request)
        }catch{
            print("Error Read Data::- \(error)")
        }
        tableView.reloadData()
    }
    

}
