//
//  IconPickerViewController.swift
//  Checklists
//

import UIKit

protocol IconPickerViewControllerDelegate: AnyObject {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String)
}

class IconPickerViewController: UITableViewController {

    weak var delegate: IconPickerViewControllerDelegate?

    let icons: [(title: String, symbolName: String)] = [
        ("Нет иконки", ""),
        ("Список", "list.bullet"),
        ("Покупки", "cart"),
        ("Путешествие", "airplane"),
        ("Подарки", "gift"),
        ("Дом", "house"),
        ("Избранное", "heart"),
        ("Важное", "star"),
        ("Цели", "flag"),
        ("Напоминания", "bell"),
        ("Работа", "briefcase"),
        ("Книги", "book"),
        ("Авто", "car"),
        ("Спорт", "sportscourt"),
        ("Еда", "fork.knife"),
        ("Здоровье", "heart.text.square"),
        ("Разное", "square.grid.2x2")
    ]

    private let reuseID = "IconCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Icon"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        icons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        let icon = icons[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = icon.title
        content.image = icon.symbolName.isEmpty ? nil : UIImage(systemName: icon.symbolName)
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.iconPicker(self, didPick: icons[indexPath.row].symbolName)
    }
}
