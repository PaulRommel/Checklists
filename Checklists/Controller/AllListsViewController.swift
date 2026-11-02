//
//  AllListsViewController.swift
//  Checklists
//

import UIKit

class AllListsViewController: UITableViewController {

    var lists = [Checklist]()
    private let listCellReuseID = "ListCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checklists"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addList))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: listCellReuseID)

        loadChecklists()
    }

    // MARK: - Actions
    @objc func addList() {
        let detailViewController = ListDetailViewController()
        detailViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: detailViewController)
        present(navigationController, animated: true)
    }

    func editList(at indexPath: IndexPath) {
        let detailViewController = ListDetailViewController()
        detailViewController.delegate = self
        detailViewController.checklistToEdit = lists[indexPath.row]

        let navigationController = UINavigationController(rootViewController: detailViewController)
        present(navigationController, animated: true)
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listCellReuseID, for: indexPath)
        let checklist = lists[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = checklist.name
        content.secondaryText = "\(checklist.items.count)"
        content.image = UIImage(systemName: checklist.iconName)
        cell.contentConfiguration = content
        cell.accessoryType = .detailDisclosureButton
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveChecklists()
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checklistViewController = ChecklistViewController()
        checklistViewController.checklist = lists[indexPath.row]
        checklistViewController.delegate = self
        navigationController?.pushViewController(checklistViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editList(at: indexPath)
    }

    // MARK: - Saving and Loading
    func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func dataFilePath() -> URL {
        documentsDirectory().appendingPathComponent("Checklists.plist")
    }

    func saveChecklists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding list array: \(error.localizedDescription)")
        }
    }

    func loadChecklists() {
        let path = dataFilePath()
        guard let data = try? Data(contentsOf: path) else { return }

        let decoder = PropertyListDecoder()
        do {
            lists = try decoder.decode([Checklist].self, from: data)
        } catch {
            print("Error decoding list array: \(error.localizedDescription)")
        }
    }
}

// MARK: - ListDetailViewControllerDelegate
extension AllListsViewController: ListDetailViewControllerDelegate {

    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        dismiss(animated: true)
    }

    func listDetailViewController(_ controller: ListDetailViewController,
                                  didFinishAdding checklist: Checklist) {
        let newRowIndex = lists.count
        lists.append(checklist)

        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        dismiss(animated: true)
        saveChecklists()
    }

    func listDetailViewController(_ controller: ListDetailViewController,
                                  didFinishEditing checklist: Checklist) {
        if let index = lists.firstIndex(where: { $0 === checklist }) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        dismiss(animated: true)
        saveChecklists()
    }
}

// MARK: - ChecklistViewControllerDelegate
extension AllListsViewController: ChecklistViewControllerDelegate {
    func checklistViewControllerDidChangeChecklist(_ controller: ChecklistViewController) {
        tableView.reloadData()   // чтобы счётчик пунктов в строке обновился
        saveChecklists()
    }
}
