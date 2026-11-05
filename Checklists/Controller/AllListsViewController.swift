//
//  AllListsViewController.swift
//  Checklists
//

import UIKit

class AllListsViewController: UITableViewController {

    var dataModel: DataModel!
    private let listCellReuseID = "ListCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checklists"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addList))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: listCellReuseID)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Если этот экран снова единственный в стеке — значит, мы вернулись
        // сюда назад (или это первый запуск без восстановления). В обоих
        // случаях больше нет "выбранного" списка для автоперехода.
        if navigationController?.viewControllers.count == 1 {
            dataModel.indexOfSelectedChecklist = -1
        }
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
        detailViewController.checklistToEdit = dataModel.lists[indexPath.row]

        let navigationController = UINavigationController(rootViewController: detailViewController)
        present(navigationController, animated: true)
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listCellReuseID, for: indexPath)
        let checklist = dataModel.lists[indexPath.row]

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
        dataModel.lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        // Удалили как раз тот список, что был "запомнен" как последний
        // открытый — без этого при следующем запуске индекс указывал бы
        // в пустоту или не на тот список.
        if dataModel.indexOfSelectedChecklist == indexPath.row {
            dataModel.indexOfSelectedChecklist = -1
        }

        dataModel.saveChecklists()
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.indexOfSelectedChecklist = indexPath.row

        let checklistViewController = ChecklistViewController()
        checklistViewController.checklist = dataModel.lists[indexPath.row]
        checklistViewController.delegate = self
        navigationController?.pushViewController(checklistViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editList(at: indexPath)
    }
}

// MARK: - ListDetailViewControllerDelegate
extension AllListsViewController: ListDetailViewControllerDelegate {

    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        dismiss(animated: true)
    }

    func listDetailViewController(_ controller: ListDetailViewController,
                                  didFinishAdding checklist: Checklist) {
        let newRowIndex = dataModel.lists.count
        dataModel.lists.append(checklist)

        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        dismiss(animated: true)
        dataModel.saveChecklists()
    }

    func listDetailViewController(_ controller: ListDetailViewController,
                                  didFinishEditing checklist: Checklist) {
        if let index = dataModel.lists.firstIndex(where: { $0 === checklist }) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        dismiss(animated: true)
        dataModel.saveChecklists()
    }
}

// MARK: - ChecklistViewControllerDelegate
extension AllListsViewController: ChecklistViewControllerDelegate {
    func checklistViewControllerDidChangeChecklist(_ controller: ChecklistViewController) {
        tableView.reloadData()   // чтобы счётчик пунктов в строке обновился
        dataModel.saveChecklists()
    }
}
