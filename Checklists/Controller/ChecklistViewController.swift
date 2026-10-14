//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Павел Попов on 10.10.2026.
//

import UIKit

class ChecklistViewController: UITableViewController {

    // MARK: - Model
    var items = [ChecklistItem]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checklists"

        tableView.register(ChecklistItemCell.self,
                           forCellReuseIdentifier: ChecklistItemCell.reuseID)

        // Заполнение модели, как в книге
        let item1 = ChecklistItem()
        item1.text = "Walk the dog"
        items.append(item1)

        let item2 = ChecklistItem()
        item2.text = "Brush my teeth"
        item2.checked = true
        items.append(item2)

        let item3 = ChecklistItem()
        item3.text = "Learn iOS development"
        item3.checked = true
        items.append(item3)

        let item4 = ChecklistItem()
        item4.text = "Soccer practice"
        items.append(item4)

        let item5 = ChecklistItem()
        item5.text = "Eat ice cream"
        item5.checked = true
        items.append(item5)
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChecklistItemCell.reuseID,
            for: indexPath) as! ChecklistItemCell

        let item = items[indexPath.row]
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Helpers
    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
        cell.accessoryType = item.checked ? .checkmark : .none
    }

    func configureText(for cell: ChecklistItemCell, with item: ChecklistItem) {
        cell.titleLabel.text = item.text
    }
}
