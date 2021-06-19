import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {

    func postNotification(_ name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
    }
}
