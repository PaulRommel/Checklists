//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Павел Попов on 10.10.2026.
//

import UIKit
import UserNotifications

class ChecklistViewController: UITableViewController {

    // MARK: - Model
    var items = [ChecklistItem]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checklists"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addItem))

        tableView.register(ChecklistItemCell.self,
                           forCellReuseIdentifier: ChecklistItemCell.reuseID)

        loadChecklistItems()
    }

    // MARK: - Actions
    @objc func addItem() {
        let addItemViewController = AddItemViewController()
        addItemViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: addItemViewController)
        present(navigationController, animated: true)
    }

    func editItem(at indexPath: IndexPath) {
        let addItemViewController = AddItemViewController()
        addItemViewController.delegate = self
        addItemViewController.itemToEdit = items[indexPath.row]

        let navigationController = UINavigationController(rootViewController: addItemViewController)
        present(navigationController, animated: true)
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

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        removeNotification(for: items[indexPath.row])

        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        saveChecklistItems()
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChecklistItemCell {
            let item = items[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)

        saveChecklistItems()
    }

    override func tableView(_ tableView: UITableView,
                            accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editItem(at: indexPath)
    }

    // MARK: - Helpers
    func configureCheckmark(for cell: ChecklistItemCell, with item: ChecklistItem) {
        cell.checkLabel.text = item.checked ? "√" : ""
        cell.accessoryType = .detailDisclosureButton
    }

    func configureText(for cell: ChecklistItemCell, with item: ChecklistItem) {
        cell.titleLabel.text = item.text
    }

    // MARK: - Saving and Loading
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func dataFilePath() -> URL {
        documentsDirectory().appendingPathComponent("Checklists.plist")
    }

    func saveChecklistItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }

    func loadChecklistItems() {
        let path = dataFilePath()
        guard let data = try? Data(contentsOf: path) else { return }

        let decoder = PropertyListDecoder()
        do {
            items = try decoder.decode([ChecklistItem].self, from: data)
        } catch {
            print("Error decoding item array: \(error.localizedDescription)")
        }
    }

    // MARK: - Notifications
    func scheduleNotification(for item: ChecklistItem) {
        removeNotification(for: item)

        guard item.shouldRemind, item.dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Reminder:"
        content.body = item.text
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                                  from: item.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: item.itemID,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removeNotification(for item: ChecklistItem) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [item.itemID])
    }
}

// MARK: - AddItemViewControllerDelegate
extension ChecklistViewController: AddItemViewControllerDelegate {

    func addItemViewControllerDidCancel(_ controller: AddItemViewController) {
        dismiss(animated: true)
    }

    func addItemViewController(_ controller: AddItemViewController,
                               didFinishAdding item: ChecklistItem) {
        let newRowIndex = items.count
        items.append(item)

        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        dismiss(animated: true)
        saveChecklistItems()
        scheduleNotification(for: item)
    }

    func addItemViewController(_ controller: AddItemViewController,
                               didFinishEditing item: ChecklistItem) {
        if let index = items.firstIndex(where: { $0 === item }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ChecklistItemCell {
            configureText(for: cell, with: item)
        }
        dismiss(animated: true)
        saveChecklistItems()
        scheduleNotification(for: item)
    }
}
