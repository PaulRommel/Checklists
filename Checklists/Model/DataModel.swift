//
//  DataModel.swift
//  Checklists
//

import Foundation

class DataModel {

    var lists = [Checklist]()

    // -1 означает "ни один список не выбран"
    var indexOfSelectedChecklist: Int {
        get {
            UserDefaults.standard.object(forKey: "ChecklistIndex") as? Int ?? -1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }

    init() {
        loadChecklists()
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
