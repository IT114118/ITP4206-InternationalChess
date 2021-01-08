//
//  SavedMatchesTableViewController.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 6/1/2021.
//

import UIKit
import CoreData

class SavedMatchesTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    var savedMatches: [SavedMatch] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let managedObjectContext = managedObjectContext {
            let fetchRequest = NSFetchRequest<SavedMatch>(entityName: "SavedMatch")
            
            do {
                savedMatches = try! managedObjectContext.fetch(fetchRequest).reversed()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMatches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)

        let savedMatch = savedMatches[indexPath.row]
        cell.textLabel?.text = savedMatch.title!
        
        if let matchRecord: [MatchRecord] = try? JSONDecoder().decode([MatchRecord].self, from: savedMatch.matchRecordsJson!.data(using: .utf8)!) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy h:mm a"
            let created = formatter.string(from: savedMatch.create_at!)
            
            var detailText = "Created: \(created) | Round: \(matchRecord.count)"
            let lastMove = matchRecord.last!.to
            if matchRecord.last!.chessBoard.count > lastMove && lastMove > 0 {
                detailText += " (\(Chess.getNotationString(cell: lastMove)))"
                let lastMovePiece = matchRecord.last!.chessBoard[lastMove]
                cell.imageView?.image = UIImage(named: Chess.pieceImages[lastMovePiece]!)
            } else {
                cell.imageView?.image = UIImage(named: "96x96-Nil")
            }
            
            cell.detailTextLabel?.text = detailText
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            if let context = managedObjectContext {
                context.delete(savedMatches[indexPath.row])
                
                do {
                    try context.save()
                    savedMatches.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = self.navigationController?.viewControllers[0] as? ViewController {
            if let matchRecord: [MatchRecord] = try? JSONDecoder().decode([MatchRecord].self, from: savedMatches[indexPath.row].matchRecordsJson!.data(using: .utf8)!) {
                viewController.loadSavedMatch(matchRecords: matchRecord)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}
