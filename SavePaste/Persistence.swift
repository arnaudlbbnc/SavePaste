//
//  Persistence.swift
//  SavePaste
//
//  Created by Arnaud LE BOURBLANC on 03/04/2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SavePaste")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func saveText(_ text: String) {
        let context = self.container.viewContext

        let newPaste = Paste(context: context)
        newPaste.text = text

        try? context.save()
    }

    func getTexts() -> [Paste] {
        let fetchRequest = Paste.fetchRequest()
        return (try? self.container.viewContext.fetch(fetchRequest)) ?? []
    }

    func resetTexts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Paste.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        _ = try? self.container.viewContext.execute(deleteRequest)
    }

    func removeText(_ text: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Paste.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "text == %@", text)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        _ = try? self.container.viewContext.execute(deleteRequest)
    }
}
