//
//  ViewController.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 5/1/2021.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var managedObjectContext: NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    
    @IBOutlet weak var chessBoard: UICollectionView!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var vconSwitch: UISwitch!
    @IBOutlet weak var roundLabel: UILabel!
    
    var chessBoardCells = Chess.getInitialBoardCells()
    var chessBoardCellsWithNotation = [Int](repeating: 0, count: (Chess.boardWidth+2) * (Chess.boardWidth+2))
    var matchRecords: [MatchRecord] = [MatchRecord(from: -1, to: -1, chessBoard: Chess.getInitialBoardCells())]
    var allowedMoves: [Int] = [Int]()
    var selectedCell: Int = -1
    var voiceControl: VoiceControl = VoiceControl()
    var bGamePlaying: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up 8x8 Chess Board
        chessBoard.delegate = self
        chessBoard.dataSource = self
        chessBoard.register(ChessBoardCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        chessBoard.frame = CGRect(
            x: 0,
            y: (UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 2,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width)
        
        // Set up Voice Control
        if vconSwitch.isOn { startVoiceControl() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bGamePlaying = false
        print("viewWillDisappear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bGamePlaying = true
        print("viewWillAppear")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isOutOfRange(cell: indexPath.item) { return }
        selectCell(cell: getCellWithoutNotation(cellWithNotation: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChessBoardCollectionViewCell
        
        cell.label.isHidden = true
        cell.layer.borderWidth = 0
        cell.imageView.isHidden = true
        cell.circleImageView.isHidden = true
        cell.layer.backgroundColor =
            UIColor(red: Chess.colorBoardBlack[0] / 255, green: Chess.colorBoardBlack[1] / 255, blue: Chess.colorBoardBlack[2] / 255, alpha: 1.0).cgColor
        cell.label.textColor = UIColor.black
        cell.removeAllBorders()
            
        setLabels()
        
        let cellWidth = chessBoard.frame.size.width / CGFloat(Chess.boardWidth+2)
        let borderWidth: CGFloat = cellWidth / 20
        
        // Print Notations
        if isOutOfRange(cell: indexPath.item) {
            let imageSize: CGFloat = chessBoard.frame.size.width / CGFloat(Chess.boardWidth+2)
            cell.label.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
            cell.label.textAlignment = .center
            cell.label.font = cell.label.font.withSize(imageSize / 2.5)
            cell.label.textColor =
                UIColor(red: Chess.colorNotation[0] / 255, green: Chess.colorNotation[1] / 255, blue: Chess.colorNotation[2] / 255, alpha: 1.0)
            
            // Print A B C D ...
            if (0 < indexPath.item && indexPath.item < (Chess.boardWidth+1))
            || ((Chess.boardWidth+2)*(Chess.boardWidth+1) < indexPath.item
            && indexPath.item < (Chess.boardWidth+2)*(Chess.boardWidth+2) - 1) {
                let chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                cell.label.isHidden = false
                cell.label.text = String(chars[chars.index(chars.startIndex, offsetBy: indexPath.item % (Chess.boardWidth+2)-1)])
                
                if 0 < indexPath.item && indexPath.item < (Chess.boardWidth+1) {
                    cell.addBorder(
                        edge: .bottom,
                        color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                        thickness: borderWidth)
                } else if ((Chess.boardWidth+2)*(Chess.boardWidth+1) < indexPath.item && indexPath.item < (Chess.boardWidth+2)*(Chess.boardWidth+2) - 1) {
                    cell.addBorder(
                        edge: .top,
                        color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                        thickness: borderWidth)
                }
            }
            
            // Add Border Corner
            else if indexPath.item == 0 {
                cell.addBorderRightBottom(
                    color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                    thickness: borderWidth)
            } else if indexPath.item == Chess.boardWidth+1 {
                cell.addBorderLeftBottom(
                    color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                    thickness: borderWidth)
            } else if indexPath.item == (Chess.boardWidth+2)*(Chess.boardWidth+1) {
                cell.addBorderRightTop(
                    color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                    thickness: borderWidth)
            } else if indexPath.item == (Chess.boardWidth+2)*(Chess.boardWidth+2) - 1 {
                cell.addBorderLeftTop(
                    color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                    thickness: borderWidth)
            }
            
            // Print 8 7 6 5 ...
            else if indexPath.item % (Chess.boardWidth+2) == 0 || (indexPath.item+1) % (Chess.boardWidth+2) == 0 {
                let row: Int = indexPath.item / (Chess.boardWidth+2)
                cell.label.isHidden = false
                cell.label.text = String(Chess.boardWidth - row + 1)
                
                if indexPath.item % (Chess.boardWidth+2) == 0 {
                    cell.addBorder(
                        edge: .right,
                        color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                        thickness: borderWidth)
                } else if (indexPath.item+1) % (Chess.boardWidth+2) == 0 {
                    cell.addBorder(
                        edge: .left,
                        color: UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0),
                        thickness: borderWidth)
                }
            }
            
            return cell
        }
        
        let currentCell = getCellWithoutNotation(cellWithNotation: indexPath.item)
        
        cell.label.isHidden = false
        cell.label.frame = CGRect(x: borderWidth + 1, y: borderWidth + 1, width: cellWidth, height: cellWidth / 4)
        cell.label.textAlignment = .left
        cell.label.text = String(currentCell + 1)
        cell.label.font = cell.label.font.withSize(cellWidth / 4)
        
        // Set board background color
        cell.layer.backgroundColor = (currentCell % 2 + currentCell / 8 % 2) % 2 == 1 ?
            UIColor(red: Chess.colorBoardBlack[0] / 255, green: Chess.colorBoardBlack[1] / 255, blue: Chess.colorBoardBlack[2] / 255, alpha: 1.0).cgColor :
            UIColor(red: Chess.colorBoardWhite[0] / 255, green: Chess.colorBoardWhite[1] / 255, blue: Chess.colorBoardWhite[2] / 255, alpha: 1.0).cgColor
        
        // Set selectable cell border
        if selectedCell == -1 && chessBoardCells[currentCell] != 0 {
            if Chess.isWhiteTurn(turn: Chess.getPlayerTurn(roundCount: matchRecords.count)) && Chess.isWhite(piece: chessBoardCells[currentCell])
            || Chess.isBlackTurn(turn: Chess.getPlayerTurn(roundCount: matchRecords.count)) && Chess.isBlack(piece: chessBoardCells[currentCell]) {
                cell.layer.borderWidth = borderWidth
                cell.layer.borderColor = Chess.isBlack(piece: chessBoardCells[currentCell]) ? UIColor.black.cgColor : UIColor.white.cgColor
            }
        }
        
        // Set selected cell border
        if currentCell == selectedCell {
            cell.layer.borderWidth = borderWidth
            cell.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        // Set last move cell border
        if matchRecords.last!.to == currentCell {
            cell.layer.borderWidth = borderWidth
            cell.layer.borderColor = UIColor.green.cgColor
        }
        
        // Render chess piece image
        cell.imageView.isHidden = chessBoardCells[currentCell] == 0
        if !cell.imageView.isHidden {
            let imagePadding: CGFloat = borderWidth * 2
            let imageSize: CGFloat = cellWidth - imagePadding * 2.0
            cell.imageView.image = UIImage(named: Chess.pieceImages[chessBoardCells[currentCell]]!)
            cell.imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        }
        
        // Render circle(s)
        cell.circleImageView.isHidden = !allowedMoves.contains(currentCell)
        let padding: CGFloat = cellWidth / 3
        let imageSize: CGFloat = cellWidth - padding * 2.0
        cell.circleImageView.frame = CGRect(x: padding, y: padding, width: imageSize, height: imageSize)
        
        return cell
    }
    
    func isOutOfRange(cell: Int) -> Bool {
        return cell % (Chess.boardWidth+2) == 0
            || (cell+1) % (Chess.boardWidth+2) == 0
            || (0 <= cell && cell < (Chess.boardWidth+2))
            || cell > (Chess.boardWidth+2) * (Chess.boardWidth+2) - (Chess.boardWidth+2)
    }
    
    func getCellWithoutNotation(cellWithNotation: Int) -> Int {
        let row: Int = cellWithNotation / (Chess.boardWidth+2)
        let cellWithoutNotation = cellWithNotation - (Chess.boardWidth+2) - (row-1)*2 - 1
        return cellWithoutNotation
    }
    
    func setLabels() {
        if matchRecords.count == 1 {
            roundLabel.text = "\(matchRecords.count)"
            undoButton.isEnabled = false
            saveButton.isEnabled = false
        } else {
            roundLabel.text = "\(matchRecords.count) (\(Chess.getNotationString(cell: matchRecords.last!.to)))"
            undoButton.isEnabled = true
            saveButton.isEnabled = true
        }
    }
    
    func loadSavedMatch(matchRecords: [MatchRecord]) {
        self.matchRecords = matchRecords
        chessBoardCells = matchRecords.last!.chessBoard
        allowedMoves = [Int]()
        selectedCell = -1
        chessBoard.reloadData()
    }
    
    ///
    ///     Below are IBActions   (4AM 07/01/2021)
    ///
    @IBAction func onUndoClick(_ sender: Any) {
        undo()
    }
    
    @IBAction func onRestartClick(_ sender: Any) {
        loadSavedMatch(matchRecords: [MatchRecord(from: -1, to: -1, chessBoard: Chess.getInitialBoardCells())])
    }
    
    @IBAction func onSaveClick(_ sender: Any) {
        let alert = UIAlertController(title: "Save the match", message: "Enter a title", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.text = "Untitled Match" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in self.bGamePlaying = true }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            if let context = self.managedObjectContext {
                if let newMatch = NSEntityDescription.insertNewObject(forEntityName: "SavedMatch", into: context) as? SavedMatch {
                    newMatch.title = alert!.textFields![0].text
                    newMatch.create_at = Date()
                    newMatch.update_at = Date()
                    
                    if let json = try? JSONEncoder().encode(self.matchRecords) {
                        newMatch.matchRecordsJson = String(data: json, encoding: .utf8)!
                        
                        do {
                            try context.save()
                            print("Context: Saved")
                            self.performSegue(withIdentifier: "showSavedMatches", sender: nil)
                        } catch {
                            print("Context: Fail to save")
                        }
                    }
                }
            }
        }))
        
        bGamePlaying = false
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onVoiceControlToggle(_ sender: Any) {
        if vconSwitch.isOn {
            startVoiceControl()
        }
    }
    
    @IBAction func onLanguageSelected(_ sender: Any) {
        let segmentControl = sender as! UISegmentedControl
        print(segmentControl.selectedSegmentIndex)
        
        let localeIdentifiers = ["en-US", "zh-CN", "zh-HK"]
        
        // Restart Voice Control
        voiceControl.setLocale(identifier: localeIdentifiers[segmentControl.selectedSegmentIndex])
        voiceControl.stop()
    }
    
    ///
    ///     Below are all UI Settings   (5AM 05/01/2021)
    ///
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chessBoardCellsWithNotation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (chessBoard.frame.size.width) / CGFloat(Chess.boardWidth+2)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    ///
    ///     Below are all functions for voice control   (10AM 06/01/2021)
    ///
    public func undo() {
        if matchRecords.count > 1 {
            chessBoardCells = matchRecords[matchRecords.count - 2].chessBoard
            matchRecords.removeLast()
            selectedCell = -1
            allowedMoves.removeAll()
            chessBoard.reloadData()
        }
    }
    
    public func selectCell(cell: Int) {
        if cell < 0 || cell >= Chess.boardWidth * Chess.boardWidth {
            return
        }
        
        let piece: Int = chessBoardCells[cell]
        let playerTurn = Chess.getPlayerTurn(roundCount: matchRecords.count)
        
        // User select their own piece
        if (!playerTurn && piece > 0) || (playerTurn && piece < 0) {
            selectedCell = cell
            allowedMoves = Chess.getAllowedMoves(
                selectedCell: selectedCell,
                matchRecords: matchRecords)
            print("Allowed move cells: ", allowedMoves)
            chessBoard.reloadData()
            return
        }
        
        // If user has selected a piece already,
        if allowedMoves.contains(cell) {
            // Move the piece
            chessBoardCells = Chess.movePiece(from: selectedCell, to: cell, cells: chessBoardCells)
            chessBoard.reloadData()
            
            // Check Promotion - Pawn
            if Chess.isPromotion(cell: cell, cells: chessBoardCells) {
                let alert = UIAlertController(title: "Pawn Promotion", message: "Please choose a piece...", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Biship", style: .default, handler: { (_) in
                    self.chessBoardCells[cell] = self.chessBoardCells[cell] > 0 ? 4 : -4
                    self.updateMatchRecords(matchRecord: MatchRecord(from: self.selectedCell, to: cell, chessBoard: self.chessBoardCells))
                    self.bGamePlaying = true
                }))
                alert.addAction(UIAlertAction(title: "Knight", style: .default, handler: { (_) in
                    self.chessBoardCells[cell] = self.chessBoardCells[cell] > 0 ? 5 : -5
                    self.updateMatchRecords(matchRecord: MatchRecord(from: self.selectedCell, to: cell, chessBoard: self.chessBoardCells))
                    self.bGamePlaying = true
                }))
                alert.addAction(UIAlertAction(title: "Rook", style: .default, handler: { (_) in
                    self.chessBoardCells[cell] = self.chessBoardCells[cell] > 0 ? 3 : -3
                    self.updateMatchRecords(matchRecord: MatchRecord(from: self.selectedCell, to: cell, chessBoard: self.chessBoardCells))
                    self.bGamePlaying = true
                }))
                alert.addAction(UIAlertAction(title: "Queen", style: .default, handler: { (_) in
                    self.chessBoardCells[cell] = self.chessBoardCells[cell] > 0 ? 2 : -2
                    self.updateMatchRecords(matchRecord: MatchRecord(from: self.selectedCell, to: cell, chessBoard: self.chessBoardCells))
                    self.bGamePlaying = true
                }))
            
                bGamePlaying = false
                self.present(alert, animated: true, completion: nil)
            } else {
                updateMatchRecords(matchRecord: MatchRecord(from: selectedCell, to: cell, chessBoard: chessBoardCells))
            }
        }
    }
    
    func updateMatchRecords(matchRecord: MatchRecord) {
        // Update
        matchRecords.append(matchRecord)
        selectedCell = -1
        allowedMoves.removeAll()
        chessBoard.reloadData()
        
        // Check Winner
        let winner = Chess.tryGetWinner(cells: chessBoardCells)
        if let winner = winner {
            let alert = UIAlertController(title: "\(winner ? "Black" : "White") WIN!", message: "Round used: \(matchRecords.count)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play again", style: .default, handler: { (_) in
                self.loadSavedMatch(matchRecords: [MatchRecord(from: -1, to: -1, chessBoard: Chess.getInitialBoardCells())])
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func runVoiceCommand(voiceCommand: String) {
        if voiceCommand == "undo" {
            self.undo()
        } else if let cell = Int(voiceCommand) {
            self.selectCell(cell: cell - 1)
        }
    }
    
    func startVoiceControl() {
        DispatchQueue.global(qos: .background).async {
            repeat {
                self.voiceControl.start()
                var recognizedCells = [Int]()
                
                self.voiceControl.recognitionTask = self.voiceControl.speechRecognizer?.recognitionTask(with: self.voiceControl.recognitionRequest!, resultHandler: { result, error in
                    if let result = result {
                        if result.isFinal {
                            recognizedCells.removeAll()
                            self.voiceControl.stop()
                            print("Voice Control: result.isFinal")
                        }
                        
                        let formattedString = result.bestTranscription.formattedString
                        var lastString: String = ""
                        for segment in result.bestTranscription.segments {
                            let indexTo = formattedString.index(formattedString.startIndex, offsetBy: segment.substringRange.location)
                            lastString = String(formattedString[indexTo...])
                        }
                        
                        let voiceCommand = lastString.lowercased()
                        print("Voice Control: [Listen] ", voiceCommand)
                        
                        if self.bGamePlaying {
                            if voiceCommand == "undo"
                            || formattedString.range(of: "and do") != nil
                            || formattedString.range(of: "銀都") != nil
                            || formattedString.range(of: "安度") != nil
                            || formattedString.range(of: "俺都") != nil
                            || formattedString.range(of: "暗度") != nil {
                                recognizedCells.removeAll()
                                self.voiceControl.stop()
                                DispatchQueue.main.async { self.runVoiceCommand(voiceCommand: "undo") }
                            } else if let cell = VoiceControl.tryGetInt(voiceCommand: voiceCommand) {
                                if cell > 0 && cell <= Chess.boardWidth * Chess.boardWidth {
                                    recognizedCells.append(cell)
                                }
                            }
                        }
                    }
                    
                    if let error = error {
                        print("Voice Control: [ERROR] \(error.localizedDescription)")
                        
                        if error.localizedDescription == "Error"
                        || error.localizedDescription == "Retry" {
                            recognizedCells.removeAll()
                            self.voiceControl.stop()
                        } else if error.localizedDescription == "User denied access to speech recognition" {
                            self.voiceControl.stop()
                            DispatchQueue.main.async {
                                self.vconSwitch.isOn = false
                                let alert = UIAlertController(title: "ERROR", message: "User denied access to speech recognition", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                    let locale = self.voiceControl.speechRecognizer!.locale.identifier
                    if locale == "en-US" {
                        if recognizedCells.count >= 2 {
                            let voiceCommand = String(recognizedCells.max()!)
                            print("Voice Control: [Accept] ", voiceCommand)
                            recognizedCells.removeAll()
                            self.voiceControl.stop()
                            DispatchQueue.main.async { self.runVoiceCommand(voiceCommand: voiceCommand) }
                        }
                    } else {
                        if let result = result {
                            let formattedString = result.bestTranscription.formattedString
                            if formattedString.count > 3 {
                                print("Voice Control: [Restart]")
                                recognizedCells.removeAll()
                                self.voiceControl.stop()
                                return
                            }
                        }
                        
                        if recognizedCells.count >= 3 {
                            let voiceCommand = String(recognizedCells.max()!)
                            print("Voice Control: [Accept] ", voiceCommand)
                            recognizedCells.removeAll()
                            self.voiceControl.stop()
                            DispatchQueue.main.async { self.runVoiceCommand(voiceCommand: voiceCommand) }
                        }
                    }
                })
                
                var cancel = false
                repeat {
                    usleep(100)
                    DispatchQueue.main.async { cancel = !self.vconSwitch.isOn }
                    if cancel {
                        self.voiceControl.stop()
                    }
                }
                while self.voiceControl.recognitionTask != nil
                
                if cancel {
                    print("Voice Control: [Cancel]")
                    break
                }
            }
            while true
        }
    }
}
