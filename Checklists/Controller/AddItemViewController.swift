//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Павел Попов on 20.10.2026.
//

import UIKit
import UserNotifications

protocol AddItemViewControllerDelegate: AnyObject {
    func addItemViewControllerDidCancel(_ controller: AddItemViewController)
    func addItemViewController(_ controller: AddItemViewController,
                               didFinishAdding item: ChecklistItem)
    func addItemViewController(_ controller: AddItemViewController,
                               didFinishEditing item: ChecklistItem)
}

class AddItemViewController: UITableViewController {

    weak var delegate: AddItemViewControllerDelegate?
    var itemToEdit: ChecklistItem?

    let textField = UITextField()
    let remindSwitch = UISwitch()
    let datePicker = UIDatePicker()

    var shouldRemind = false
    var dueDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel))

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done))
        navigationItem.rightBarButtonItem = doneButton

        textField.placeholder = "Item name"
        textField.borderStyle = .none
        textField.autocapitalizationType = .sentences
        textField.delegate = self

        remindSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            shouldRemind = item.shouldRemind
            dueDate = item.dueDate
            doneButton.isEnabled = true
        } else {
            title = "Add Item"
            doneButton.isEnabled = false
        }

        remindSwitch.isOn = shouldRemind
        datePicker.date = dueDate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return shouldRemind ? 2 : 1
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            textField.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
                textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            return cell
        }

        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Remind Me"
            cell.selectionStyle = .none
            cell.accessoryView = remindSwitch
            return cell
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        indexPath.section == 0 ? indexPath : nil
    }

    // MARK: - Actions

    @objc func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
    }

    @objc func done() {
        let text = textField.text ?? ""

        if let item = itemToEdit {
            item.text = text
            item.shouldRemind = shouldRemind
            item.dueDate = dueDate
            delegate?.addItemViewController(self, didFinishEditing: item)
        } else {
            let item = ChecklistItem()
            item.text = text
            item.checked = false
            item.shouldRemind = shouldRemind
            item.dueDate = dueDate
            delegate?.addItemViewController(self, didFinishAdding: item)
        }
    }

    @objc func switchChanged(_ sender: UISwitch) {
        textField.resignFirstResponder()

        let wasOn = shouldRemind
        shouldRemind = sender.isOn
        guard wasOn != shouldRemind else { return }

        let indexPath = IndexPath(row: 1, section: 1)
        if shouldRemind {
            tableView.insertRows(at: [indexPath], with: .automatic)
            requestNotificationPermission()
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        dueDate = sender.date
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                DispatchQueue.main.async {
                    self.remindSwitch.isOn = false
                    self.shouldRemind = false
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = (textField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        return true
    }
}
