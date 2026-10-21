//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Павел Попов on 20.10.2026.
//

import UIKit

protocol AddItemViewControllerDelegate: AnyObject {
    func addItemViewControllerDidCancel(_ controller: AddItemViewController)
    func addItemViewController(_ controller: AddItemViewController,
                               didFinishAdding item: ChecklistItem)
    func addItemViewController(_ controller: AddItemViewController,
                               didFinishEditing item: ChecklistItem)
}

class AddItemViewController: UITableViewController {

    weak var delegate: AddItemViewControllerDelegate?
    var itemToEdit: ChecklistItem?          // nil = режим добавления, не nil = редактирование

    let textField = UITextField()

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

        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            doneButton.isEnabled = true          // текст уже есть — Done сразу активен
        } else {
            title = "Add Item"
            doneButton.isEnabled = false         // поле пустое — Done неактивен
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    // MARK: - Actions

    @objc func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
    }

    @objc func done() {
        let text = textField.text ?? ""

        if let item = itemToEdit {
            item.text = text
            delegate?.addItemViewController(self, didFinishEditing: item)
        } else {
            let item = ChecklistItem()
            item.text = text
            item.checked = false
            delegate?.addItemViewController(self, didFinishAdding: item)
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
