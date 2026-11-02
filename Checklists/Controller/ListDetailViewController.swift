//
//  ListDetailViewController.swift
//  Checklists
//

import UIKit

protocol ListDetailViewControllerDelegate: AnyObject {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController,
                                  didFinishAdding checklist: Checklist)
    func listDetailViewController(_ controller: ListDetailViewController,
                                  didFinishEditing checklist: Checklist)
}

class ListDetailViewController: UITableViewController {

    weak var delegate: ListDetailViewControllerDelegate?
    var checklistToEdit: Checklist?

    let textField = UITextField()
    var iconName = "list.bullet"

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

        textField.placeholder = "List name"
        textField.borderStyle = .none
        textField.autocapitalizationType = .words
        textField.delegate = self

        if let checklist = checklistToEdit {
            title = "Edit Checklist"
            textField.text = checklist.name
            iconName = checklist.iconName
            doneButton.isEnabled = true
        } else {
            title = "Add Checklist"
            doneButton.isEnabled = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int { 1 }

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

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = "Icon"
        content.image = UIImage(systemName: iconName)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }

        let iconPicker = IconPickerViewController()
        iconPicker.delegate = self
        navigationController?.pushViewController(iconPicker, animated: true)
    }

    // MARK: - Actions

    @objc func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }

    @objc func done() {
        let text = textField.text ?? ""

        if let checklist = checklistToEdit {
            checklist.name = text
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditing: checklist)
        } else {
            let checklist = Checklist(name: text, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAdding: checklist)
        }
    }
}

// MARK: - IconPickerViewControllerDelegate
extension ListDetailViewController: IconPickerViewControllerDelegate {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        self.iconName = iconName
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        navigationController?.popViewController(animated: true)
    }
}

extension ListDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = (textField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        return true
    }
}
