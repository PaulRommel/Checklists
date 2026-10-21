//
//  ChecklistItemCell.swift
//  Checklists
//
//  Created by Павел Попов on 10.10.2026.
//

import UIKit

final class ChecklistItemCell: UITableViewCell {
    static let reuseID = "ChecklistItem"

    let titleLabel = UILabel()
    let checkLabel = UILabel()   // не private — контроллер обращается напрямую

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        checkLabel.font = .preferredFont(forTextStyle: .body)
        checkLabel.setContentHuggingPriority(.required, for: .horizontal)
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [checkLabel, titleLabel])
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
