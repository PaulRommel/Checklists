//
//  Checklist.swift
//  Checklists
//

import Foundation

class Checklist: Codable {
    var name = ""
    var items = [ChecklistItem]()
    var iconName = "list.bullet"

    init(name: String, iconName: String = "list.bullet") {
        self.name = name
        self.iconName = iconName
    }

    private enum CodingKeys: String, CodingKey {
        case name, items, iconName
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        items = try container.decode([ChecklistItem].self, forKey: .items)
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName) ?? "list.bullet"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(items, forKey: .items)
        try container.encode(iconName, forKey: .iconName)
    }

    // MARK: - Sorting
    func sortChecklistItems() {
        items.sort { item1, item2 in
            item1.text.localizedStandardCompare(item2.text) == .orderedAscending
        }
    }

    // MARK: - Counts
    func countUncheckedItems() -> Int {
        items.reduce(0) { count, item in
            item.checked ? count : count + 1
        }
    }

    func countLabelText() -> String {
        if items.isEmpty {
            return "(No Items)"
        } else {
            return "\(countUncheckedItems()) Remaining"
        }
    }
}
