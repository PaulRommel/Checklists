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
    
    func toggleChecked() {
        checked.toggle()
    }
}
