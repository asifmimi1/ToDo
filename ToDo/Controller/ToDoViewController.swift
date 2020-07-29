//
//  ViewController.swift
//  ToDo
//
//  Created by Asif's Mac on 15/7/20.
//  Copyright © 2020 Asif's Mac. All rights reserved.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {
    
    var ArrayValue = [Item]()
    
    //didSet/willSet are the property observers. it will only work when a value is set.
    var selectedCategory : Category? {
        didSet{
            readData()
        }
    }
    
    //Saving the data to coreData saveContext()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    //UserDefault - Singleton
//    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gettingDataByDecoding()
        //readData()
        
        //Creating the filepath to Document directory and creating a custom plist
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist"))
        
        //Getting the value from Userdefault
//        if let Array = defaults.array(forKey: "Item Array") as? [Item]{
//            ArrayValue = Array
//        }
    }

    //MARK:- TABLEVIEW DATASOURCE
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayValue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewidentifier", for: indexPath)
        cell.textLabel?.text = ArrayValue[indexPath.row].title
        
        //ACCESSORY TYPE- CHECKMARK
        if ArrayValue[indexPath.row].done == true{
                   cell.accessoryType = .checkmark
               }else{
                   cell.accessoryType = .none
               }
        return cell
    }
    
    // MARK:- TABLEVIEW DELEGATE
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //DESELECT ROW
        tableView.deselectRow(at: indexPath, animated: true)
        
       // var boolValue = ArrayValue[indexPath.row].done // DID THIS JUST TO SHORTEN(succinct) THE CODE
        //settingDataByEncoding()
        
        createData()
        
//        //CRUD: U:- Update Data
//        ArrayValue[indexPath.row].setValue("0", forKey: "title")
        
//        //CRUD: D:- Delete Data, In here the order is very important,the data have to delete from the context first then from the                              indexPath, otherwise the program will crash
//        context.delete(ArrayValue[indexPath.row])
//        ArrayValue.remove(at: indexPath.row)
        
           ArrayValue[indexPath.row].done = !ArrayValue[indexPath.row].done // *** Single line of code that defines as the same 5 lines below this. it says, ArrayValue[indexPath.row].done is equal the opposite of ArrayValue[indexPath.row].done ***
        
//        if ArrayValue[indexPath.row].done == false{
//            ArrayValue[indexPath.row].done = true
//        }else{
//            ArrayValue[indexPath.row].done = false
//        }
        
        tableView.reloadData()
        
        //CHECKMARK
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
       
        
    }
    //MARK:- AddButton
    @IBAction func addBarButton(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        let alert = UIAlertController.init(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: "Done", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textfield.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.ArrayValue.append(newItem)
            //self.settingDataByEncoding()
            self.createData()
            //SETTING DEFAULT VALUE
//            self.defaults.setValue(self.ArrayValue, forKey: "Item Array")
            
            //RELOAD TABLEVIEW
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textfield = alertTextField
            alertTextField.placeholder = "Enter the item name"
        }
        present(alert, animated: true, completion: nil)
        }
    
//    //MARK:-NSCoder- Archaiving Data By Encoding func
//    func settingDataByEncoding() {
//        //Coverting our Custom data to PropertyList using Ecoder
//                   let encode = PropertyListEncoder()
//                   do{
//                       let data = try encode.encode(self.ArrayValue)
//                       try data.write(to: self.dataFilePath!)
//                   }catch{
//                       print("Error in Encoding data::- \(error)")
//                   }
//    }
//
//    //MARK:-NSCoder- Distributing Data By Decosing func
//    func gettingDataByDecoding() {
//        if let data = try? Data(contentsOf: dataFilePath!){
//            let decodable = PropertyListDecoder()
//            do{
//               ArrayValue = try decodable.decode([Item].self, from: data)
//            }catch{
//                print("Error in Decoding::- \(error)")
//            }
//
//        }
    
    //MARK:- CoreData CRUD - Archaiving Data
        func createData() {
            do{
               try context.save()
            }catch{
                print("Error of SettingDataByCoreData::- \(error)")
            }
        }
    
    func readData(with request : NSFetchRequest<Item> = Item.fetchRequest(),with predicate : NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let newPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, newPredicate])
        }else{
            request.predicate = categoryPredicate
        }
            
          //  let request : NSFetchRequest<Item> = Item.fetchRequest()
                  do{
                     ArrayValue = try context.fetch(request)
                  }catch{
                      print("Error Fetching Data::- \(error)")
                  }
            tableView.reloadData()
    }
  
}
//MARK:- Search Bar
extension ToDoViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        readData(with: request, with:  predicate)
        
        //searchBar.text = ""
        
    }
    
    //Method:- textDidChange, decides what will happen when the searchbar text changes.
    //DispatchQueue:- Creates the main queue and associate with the main thread.
    //resignFirstResponder:- Notifies this object that it has been asked to relinquish its status as first responder in its window.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            readData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


