//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Павел Попов on 10.10.2026.
//

import Foundation

class ChecklistItem: Codable {
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = UUID().uuidString

    init() {}

    private enum CodingKeys: String, CodingKey {
        case text, checked, dueDate, shouldRemind, itemID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        checked = try container.decode(Bool.self, forKey: .checked)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date()
        shouldRemind = try container.decodeIfPresent(Bool.self, forKey: .shouldRemind) ?? false
        itemID = try container.decodeIfPresent(String.self, forKey: .itemID) ?? UUID().uuidString
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(checked, forKey: .checked)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(shouldRemind, forKey: .shouldRemind)
        try container.encode(itemID, forKey: .itemID)
    }

    func toggleChecked() {
        checked.toggle()
    }
}
