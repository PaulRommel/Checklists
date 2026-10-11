//
//  ChecklistItemCell.swift
//  Checklists
//
//  Created by Павел Попов on 10.10.2026.
//

import UIKit

final class ChecklistItemCell: UITableViewCell {
    static let reuseID = "ChecklistItemCell"

    private let checkLabel = UILabel()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        checkLabel.font = .systemFont(ofSize: 22)
        checkLabel.textColor = .tintColor
        checkLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [checkLabel, titleLabel])
        stack.spacing = 12
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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with item: ChecklistItem) {
        titleLabel.text = item.text
        checkLabel.text = item.checked ? "✓" : ""
    }
}
