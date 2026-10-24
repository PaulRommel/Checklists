//
//  ChecklistViewController.swift
//  Checklists
//

import UIKit
import UserNotifications

protocol ChecklistViewControllerDelegate: AnyObject {
    func checklistViewControllerDidChangeChecklist(_ controller: ChecklistViewController)
}

class ChecklistViewController: UITableViewController {

    var checklist: Checklist!
    weak var delegate: ChecklistViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addItem))

        tableView.register(ChecklistItemCell.self,
                           forCellReuseIdentifier: ChecklistItemCell.reuseID)
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
        addItemViewController.itemToEdit = checklist.items[indexPath.row]

        let navigationController = UINavigationController(rootViewController: addItemViewController)
        present(navigationController, animated: true)
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChecklistItemCell.reuseID,
            for: indexPath) as! ChecklistItemCell

        let item = checklist.items[indexPath.row]
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        removeNotification(for: checklist.items[indexPath.row])

        checklist.items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        delegate?.checklistViewControllerDidChangeChecklist(self)
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChecklistItemCell {
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)

        delegate?.checklistViewControllerDidChangeChecklist(self)
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
        let newRowIndex = checklist.items.count
        checklist.items.append(item)

        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        dismiss(animated: true)
        delegate?.checklistViewControllerDidChangeChecklist(self)
        scheduleNotification(for: item)
    }

    func addItemViewController(_ controller: AddItemViewController,
                               didFinishEditing item: ChecklistItem) {
        if let index = checklist.items.firstIndex(where: { $0 === item }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ChecklistItemCell {
            configureText(for: cell, with: item)
        }
        dismiss(animated: true)
        delegate?.checklistViewControllerDidChangeChecklist(self)
        scheduleNotification(for: item)
    }
}
