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
}

class AddItemViewController: UITableViewController {

    weak var delegate: AddItemViewControllerDelegate?

    let textField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Item"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel))

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done))

        textField.placeholder = "Item name"
        textField.borderStyle = .none
        textField.autocapitalizationType = .sentences
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()   // клавиатура появляется сразу
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
        let item = ChecklistItem()
        item.text = textField.text ?? ""
        item.checked = false

        delegate?.addItemViewController(self, didFinishAdding: item)
    }
}
