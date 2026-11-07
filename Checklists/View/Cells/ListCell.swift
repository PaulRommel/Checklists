//
//  ListCell.swift
//  Checklists
//

import UIKit

// Обычная UITableViewCell со стилем .default не показывает secondaryText —
// это ограничение UIKit, а не configuration API. Чтобы подпись с количеством
// невыполненных пунктов была видна ПОД названием списка (как в книге),
// ячейке нужен стиль .subtitle, а задать его можно только через свой init.
final class ListCell: UITableViewCell {
    static let reuseID = "ListCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
