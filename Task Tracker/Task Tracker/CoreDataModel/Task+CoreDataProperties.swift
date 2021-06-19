import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var finishDate: Date
    @NSManaged public var note: String
    @NSManaged public var repeatType: Int
    @NSManaged public var startDate: Date
    @NSManaged public var state: Int
    @NSManaged public var title: String
    @NSManaged public var isCloned: Bool

}

extension Task : Identifiable {

}
