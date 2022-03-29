//
//  ViewController.swift
//  LearnCoreData
//
//  Created by Sungur on 27.03.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var notes: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        setNoteBtnToView()
        getFetchRequest()
        // Do any additional setup after loading the view.
    }
    
    func setNoteBtnToView() {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "customButton"), for: .normal)
        view.addSubview(button)
        button.addTarget(self, action: #selector(handlerCreateNewBtnPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }

    @objc func handlerCreateNewBtnPressed() {
        let alert = UIAlertController(title: "Create Note", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter note..."
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
        let create = UIAlertAction(title: "create", style: .cancel) { [unowned self] action in
            guard let textField = alert.textFields?.first, let noteSave = textField.text else { return }
            save(text: noteSave)
            
            tableView.reloadData()
        }
        alert.addAction(create)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
        
    }
    
    func save(text: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        note.setValue(text, forKey: "noteName")
        
        try! managedContext.save()
        notes.append(note)
    }
    
    func getFetchRequest() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        notes = try! managedContext.fetch(fetchRequest)
    }
    
    func editNote(_ index: IndexPath) {
        let alert = UIAlertController(title: "Edit note", message: "", preferredStyle: .alert)
        
        
        let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
        let edit = UIAlertAction(title: "edit", style: .cancel) { [unowned self] action in
            guard let textField = alert.textFields?.first, let noteSave = textField.text else { return }
            let oldText = self.notes[index.row].value(forKey: "noteName") as! String
            self.update(oldText, noteSave)
            tableView.reloadData()
        }
        
        alert.addTextField { textField in
            textField.text = self.notes[index.row].value(forKey: "noteName") as? String
        }
        
        alert.addAction(cancel)
        alert.addAction(edit)
        
        present(alert, animated: true)
    }
    
    func update(_ oldValue: String, _ newValue: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "noteName = %@", oldValue)
        let results = try! managedContext.fetch(fetchRequest) as? [NSManagedObject]
        
        if results?.count != 0 {
            results![0].setValue(newValue, forKey: "noteName")
        }
        try! managedContext.save()
    }
    
    func delete(by indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(notes[indexPath.row])
        notes.remove(at: indexPath.row)
        try! managedContext.save()
        tableView.reloadData()
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = notes[indexPath.row].value(forKeyPath: "noteName") as? String
        cell.textLabel?.textColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 0.9600886703, green: 0.9261525273, blue: 0.8534681797, alpha: 1)
        cell.textLabel?.font = UIFont(name: "System", size: 20)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(by: indexPath)
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        editNote(indexPath)

    }

}

