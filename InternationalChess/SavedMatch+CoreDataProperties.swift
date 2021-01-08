//
//  SavedMatch+CoreDataProperties.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 7/1/2021.
//
//

import Foundation
import CoreData


extension SavedMatch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedMatch> {
        return NSFetchRequest<SavedMatch>(entityName: "SavedMatch")
    }

    @NSManaged public var matchRecordsJson: String?
    @NSManaged public var create_at: Date?
    @NSManaged public var title: String?
    @NSManaged public var update_at: Date?

}

extension SavedMatch : Identifiable {

}
