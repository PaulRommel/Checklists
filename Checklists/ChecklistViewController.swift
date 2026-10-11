//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Павел Попов on 10.10.2026.
//

import UIKit

class ChecklistViewController: UITableViewController {
    
    // Временные данные, чтобы было что показать
       var items: [ChecklistItem] = [
           ChecklistItem(text: "Walk the dog", checked: false),
           ChecklistItem(text: "Brush my teeth", checked: true),
           ChecklistItem(text: "Learn iOS development", checked: true),
           ChecklistItem(text: "Soccer practice", checked: false),
           ChecklistItem(text: "Eat ice cream", checked: true)
       ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checklists"
        
        // Регистрируем ячейку
        tableView.register(ChecklistItemCell.self, forCellReuseIdentifier: ChecklistItemCell.reuseID)
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChecklistItemCell.reuseID, for: indexPath) as! ChecklistItemCell

        cell.configure(with: items[indexPath.row])
        return cell
    }
    
    // MARK: - Table View Delegate
    
    // Тап по строке переключает галочку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].checked.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
