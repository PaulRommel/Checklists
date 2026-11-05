//
//  DataModel.swift
//  Checklists
//

import Foundation
import UserNotifications

class DataModel {

    var lists = [Checklist]()

    var indexOfSelectedChecklist: Int {
        get {
            UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }

    init() {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
        validateIndexOfSelectedChecklist()
        updateBadgeNumber()
    }

    // MARK: - Defaults
    func registerDefaults() {
        let dictionary: [String: Any] = [
            "ChecklistIndex": -1,
            "FirstTime": true
        ]
        UserDefaults.standard.register(defaults: dictionary)
    }

    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")

        // Создаём список по умолчанию только при реально первом запуске
        // и только если на диске ещё ничего не было загружено — чтобы
        // не плодить пустые списки у тех, кто уже пользовался приложением.
        if firstTime && lists.isEmpty {
            let checklist = Checklist(name: "List")
            lists.append(checklist)

            indexOfSelectedChecklist = 0
            saveChecklists()
        }

        userDefaults.set(false, forKey: "FirstTime")
    }

    // MARK: - Defensive programming
    // Сохранённый индекс мог протухнуть: список удалили, файл повредился,
    // данные подменили синхронизацией. Проверяем границы один раз при
    // старте, а не ждём, пока где-то в коде произойдёт краш на lists[index].
    func validateIndexOfSelectedChecklist() {
        if indexOfSelectedChecklist >= lists.count || indexOfSelectedChecklist < 0 {
            indexOfSelectedChecklist = -1
        }
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
        updateBadgeNumber()
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

    // MARK: - Badges
    func countUncheckedReminders() -> Int {
        lists.reduce(0) { count, checklist in
            count + checklist.items.filter { $0.shouldRemind && !$0.checked }.count
        }
    }

    func updateBadgeNumber() {
        let count = countUncheckedReminders()
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error = error {
                print("Error setting badge count: \(error.localizedDescription)")
            }
        }
    }
}
