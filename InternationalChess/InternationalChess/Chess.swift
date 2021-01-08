//
//  Chess.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 5/1/2021.
//

import UIKit

class Chess {
    static let colorNotation: [CGFloat] = [208, 224, 229]
    static let colorBoardBlack: [CGFloat] = [156, 70, 37]
    static let colorBoardWhite: [CGFloat] = [237, 203, 155]
    
    static let boardWidth = 8
    static let circleImage = "Circle"
    static let pieceImages: [Int: String] = [
        1: "King-white", -1: "King-black",
        2: "Queen-white", -2: "Queen-black",
        3: "Rook-white", -3: "Rook-black",
        4: "Bishop-white", -4: "Bishop-black",
        5: "Knight-white", -5: "Knight-black",
        6: "Pawn-white", -6: "Pawn-black",
    ]
    
    static func getAllowedMoves(selectedCell: Int, matchRecords: [MatchRecord], checkSpecialCases: Bool = true) -> [Int] {
        let cells: [Int] = matchRecords.last!.chessBoard
        let piece: Int = cells[selectedCell]
        let playerTurn = getPlayerTurn(roundCount: matchRecords.count)
        var allowedMoves = [Int]()
        
        // Return if selected nothing or selected opponent piece
        if piece == 0 || (!playerTurn && piece < 0) || (playerTurn && piece > 0) {
            return allowedMoves
        }
        
        switch abs(piece) {
        
        // King ✅ - Special Cases: Castling
        case 1:
            allowedMoves += getVertical(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells, limit: true)
            allowedMoves += getHorizontal(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells, limit: true)
            allowedMoves += getDiagonals(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells, limit: true)
            
            if checkSpecialCases {
                // Castling
                var isRookTopLeftNeverMove = true, isRookTopRightNeverMove = true, isRookBottomLeftNeverMove = true, isRookBottomRightNeverMove = true
                var isBlackKingNeverMove = true, isWhiteKingNeverMove = true
                for matchRecord in matchRecords {
                    if matchRecord.chessBoard[0] != -3 { isRookTopLeftNeverMove = false }
                    if matchRecord.chessBoard[boardWidth - 1] != -3 { isRookTopRightNeverMove = false }
                    if matchRecord.chessBoard[boardWidth * (boardWidth-1)] != 3 { isRookBottomLeftNeverMove = false }
                    if matchRecord.chessBoard[boardWidth * boardWidth - 1] != 3 { isRookBottomRightNeverMove = false }
                    if matchRecord.chessBoard[4] != -1 { isBlackKingNeverMove = false }
                    if matchRecord.chessBoard[boardWidth * (boardWidth-1) + 4] != 1 { isWhiteKingNeverMove = false }
                }
                if isWhiteTurn(turn: playerTurn) {
                    if isWhiteKingNeverMove {
                        if isRookBottomLeftNeverMove {
                            let rookPos = boardWidth * (boardWidth-1)
                            if cells[rookPos+1] == 0 && cells[rookPos+2] == 0 && cells[rookPos+3] == 0 {
                                if !isCellCheck(checkCell: rookPos+2, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos+3, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos+4, playerTurn: playerTurn, matchRecords: matchRecords) {
                                    allowedMoves.append(boardWidth * (boardWidth-1) + 2)
                                }
                            }
                        }
                        if isRookBottomRightNeverMove {
                            let rookPos = boardWidth * boardWidth - 1
                            if cells[rookPos-1] == 0 && cells[rookPos-2] == 0 {
                                if !isCellCheck(checkCell: rookPos-1, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos-2, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos-3, playerTurn: playerTurn, matchRecords: matchRecords) {
                                    allowedMoves.append(rookPos - 1)
                                }
                            }
                        }
                    }
                } else {
                    if isBlackKingNeverMove {
                        if isRookTopLeftNeverMove {
                            let rookPos = 0
                            if cells[rookPos+1] == 0 && cells[rookPos+2] == 0 && cells[rookPos+3] == 0 {
                                if !isCellCheck(checkCell: rookPos+2, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos+3, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos+4, playerTurn: playerTurn, matchRecords: matchRecords) {
                                    allowedMoves.append(2)
                                }
                            }
                        }
                        if isRookTopRightNeverMove {
                            let rookPos = boardWidth - 1
                            if cells[rookPos-1] == 0 && cells[rookPos-2] == 0 {
                                if !isCellCheck(checkCell: rookPos-1, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos-2, playerTurn: playerTurn, matchRecords: matchRecords)
                                && !isCellCheck(checkCell: rookPos-3, playerTurn: playerTurn, matchRecords: matchRecords) {
                                    allowedMoves.append(rookPos - 1)
                                }
                            }
                        }
                    }
                }
            }
        
        // Queen ✅
        case 2:
            allowedMoves += getVertical(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
            allowedMoves += getHorizontal(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
            allowedMoves += getDiagonals(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
        
        // Rook ✅
        case 3:
            allowedMoves += getVertical(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
            allowedMoves += getHorizontal(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
        
        // Bishop ✅
        case 4:
            allowedMoves += getDiagonals(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
        
        // Knight ✅
        case 5:
            allowedMoves += getL(playerTurn: playerTurn, selectedCell: selectedCell, cells: cells)
            
        // Pawn ✅ - Special Cases: Promotion, En Passant ✅
        case 6:
            // White Turn
            if !playerTurn && cells[selectedCell - 8] == 0 {
                allowedMoves.append(selectedCell - 8)
                if 48 <= selectedCell && selectedCell < 56 && cells[selectedCell - 8*2] == 0 {
                    allowedMoves.append(selectedCell - 8*2)
                }
            }
            
            // Black Turn
            if playerTurn && cells[selectedCell + 8] == 0 {
                allowedMoves.append(selectedCell + 8)
                if 8 <= selectedCell && selectedCell < 16 && cells[selectedCell + 8*2] == 0 {
                    allowedMoves.append(selectedCell + 8*2)
                }
            }
            
            // Eat
            let col: Int = selectedCell % boardWidth
            
            let leftTop = selectedCell - boardWidth - 1
            if col != 0 && leftTop >= 0 && isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[leftTop]) { allowedMoves.append(leftTop) }
            let rightTop = selectedCell - boardWidth + 1
            if col != boardWidth - 1 && rightTop >= 0 && isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[rightTop]) { allowedMoves.append(rightTop) }
            let leftBottom = selectedCell + boardWidth - 1
            if col != 0 && leftBottom >= 0 && isBlackTurn(turn: playerTurn) && isWhite(piece: cells[leftBottom]) { allowedMoves.append(leftBottom) }
            let rightBottom = selectedCell + boardWidth + 1
            if col != boardWidth - 1 && rightBottom >= 0 && isBlackTurn(turn: playerTurn) && isWhite(piece: cells[rightBottom]) { allowedMoves.append(rightBottom) }
            
            if checkSpecialCases {
                // En Passant
                let lastFrom = matchRecords.last!.from
                let lastTo = matchRecords.last!.to
                if matchRecords.count > 2 && abs(cells[lastTo]) == 6 && abs(lastFrom / boardWidth - lastTo / boardWidth) == 2 {
                    let currentRow: Int = selectedCell / boardWidth
                    if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[lastTo]) && currentRow == 3 {
                        let expectedPawn = matchRecords.suffix(2).first!.chessBoard[lastFrom]
                        if isBlack(piece: expectedPawn) {
                            if selectedCell - 1 == lastTo && col != 0 { allowedMoves.append(leftTop) }
                            if selectedCell + 1 == lastTo && col != boardWidth - 1 { allowedMoves.append(rightTop) }
                        }
                    }
                    else if isBlackTurn(turn: playerTurn) && isWhite(piece: cells[lastTo]) && currentRow == boardWidth - 4 {
                        let expectedPawn = matchRecords.suffix(2).first!.chessBoard[lastFrom]
                        if isWhite(piece: expectedPawn) {
                            if selectedCell - 1 == lastTo && col != 0 { allowedMoves.append(leftBottom) }
                            if selectedCell + 1 == lastTo && col != boardWidth - 1 { allowedMoves.append(rightBottom) }
                        }
                    }
                }
            }
        
        default:
            return allowedMoves
        }
        
        allowedMoves.removeAll(where: { $0 < 0 || $0 >= boardWidth * boardWidth })
        return allowedMoves
    }
    
    static func getInitialBoardCells() -> [Int] {
        var chessBoardCells = [Int](repeating: 0, count: boardWidth * boardWidth)
        
        // Add Kings
        chessBoardCells[4] = -1
        chessBoardCells[60] = 1
        
        // Add Queens
        chessBoardCells[3] = -2
        chessBoardCells[59] = 2
        
        // Add Rooks
        chessBoardCells[0] = -3
        chessBoardCells[7] = -3
        chessBoardCells[56] = 3
        chessBoardCells[63] = 3
        
        // Add Bishop
        chessBoardCells[2] = -4
        chessBoardCells[5] = -4
        chessBoardCells[58] = 4
        chessBoardCells[61] = 4
        
        // Add Knight
        chessBoardCells[1] = -5
        chessBoardCells[6] = -5
        chessBoardCells[57] = 5
        chessBoardCells[62] = 5
        
        // Add Pawn
        for i in 8..<16 {
            chessBoardCells[i] = -6
            chessBoardCells[i + 40] = 6
        }
        
        return chessBoardCells
    }
    
    static func movePiece(from: Int, to: Int, cells: [Int]) -> [Int] {
        var cells = cells
        
        // En Passant - Check is Pawn and is not go straight and going to empty location
        if abs(cells[from]) == 6 && abs(from - to) != boardWidth && cells[to] == 0 {
            cells[to + (isWhite(piece: cells[from]) ? boardWidth : -boardWidth)] = 0
        }
        
        // Castling
        if abs(cells[from]) == 1 && abs(from - to) == 2 {
            if isWhite(piece: cells[from]) {
                if from > to {
                    cells[to + 1] = 3
                    cells[boardWidth * (boardWidth-1)] = 0
                } else {
                    cells[to - 1] = 3
                    cells[boardWidth * boardWidth-1] = 0
                }
            } else {
                if from > to {
                    cells[to + 1] = -3
                    cells[0] = 0
                } else {
                    cells[to - 1] = -3
                    cells[boardWidth - 1] = 0
                }
            }
        }
        
        // Normal move
        cells[to] = cells[from]
        cells[from] = 0
        
        return cells
    }
    
    static func tryGetWinner(cells: [Int]) -> Bool? {
        if !cells.contains(1) {
            return true
        } else if !cells.contains(-1) {
            return false
        }
        return nil
    }
    
    // Get player turn by round count, false = white, true = black
    static func getPlayerTurn(roundCount: Int) -> Bool {
        return roundCount % 2 == 0
    }
    
    static func isWhite(piece: Int) -> Bool {
        return piece > 0
    }
    
    static func isBlack(piece: Int) -> Bool {
        return piece < 0
    }
    
    static func isEmpty(piece: Int) -> Bool {
        return piece == 0
    }
    
    static func isWhiteTurn(turn: Bool) -> Bool {
        return !turn
    }
    
    static func isBlackTurn(turn: Bool) -> Bool {
        return turn
    }
    
    static func isPromotion(cell: Int, cells: [Int]) -> Bool {
        let pawnRow: Int = cell / boardWidth
        let pawn = cells[cell]
        
        if isWhite(piece: pawn) {
            if pawnRow != 0 || pawn != 6 {
                return false
            }
        } else {
            if pawnRow != boardWidth - 1 || pawn != -6 {
                return false
            }
        }
        
        return true
    }
    
    static func isCellCheck(checkCell: Int, playerTurn: Bool, matchRecords: [MatchRecord]) -> Bool {
        var allowedMoves = [Int]()
        var matchRecords = matchRecords
        matchRecords.removeFirst()
        for (index, _) in matchRecords.last!.chessBoard.enumerated() {
            allowedMoves += getAllowedMoves(selectedCell: index, matchRecords: matchRecords, checkSpecialCases: false)
        }
        
        return allowedMoves.contains(checkCell)
    }
    
    static func getNotationString(cell: Int) -> String {
        let chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let number: Int = boardWidth - (cell / boardWidth)
        let string: String = String(chars[chars.index(chars.startIndex, offsetBy: cell % boardWidth)])
        return "\(string)\(number)"
    }
    
    static func getVertical(playerTurn: Bool, selectedCell: Int, cells: [Int], limit: Bool = false) -> [Int] {
        var allowedMoves = [Int]()
        var i = selectedCell + boardWidth
        var lim = limit ? i + boardWidth : boardWidth * boardWidth
        lim = lim > boardWidth * boardWidth ? boardWidth * boardWidth : lim
        
        while i < lim {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i += boardWidth
        }
        
        i = selectedCell - boardWidth
        lim = limit ? i - 1 : 0
        lim = lim < 0 ? 0 : lim
        while i >= lim {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i -= boardWidth
        }
        
        return allowedMoves
    }
    
    static func getHorizontal(playerTurn: Bool, selectedCell: Int, cells: [Int], limit: Bool = false) -> [Int] {
        var allowedMoves = [Int]()
        let currentRow: Int = selectedCell / boardWidth
        var i = selectedCell + 1
        var lim = limit ? i + 1 : currentRow * boardWidth + boardWidth
        
        while i < lim {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i += 1
        }
        
        i = selectedCell - 1
        lim = limit ? i : currentRow * boardWidth
        while i >= lim {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i -= 1
        }
        
        return allowedMoves
    }
    
    static func getL(playerTurn: Bool, selectedCell: Int, cells: [Int]) -> [Int] {
        var allowedMoves = [Int]()
        
        let topLeft = selectedCell - boardWidth - 1
        let topRight = selectedCell - boardWidth + 1
        let bottomLeft = selectedCell + boardWidth - 1
        let bottomRight = selectedCell + boardWidth + 1
        
        allowedMoves.append(topLeft - boardWidth)
        allowedMoves.append(topLeft - 1)
        allowedMoves.append(topRight - boardWidth)
        allowedMoves.append(topRight + 1)
        allowedMoves.append(bottomLeft + boardWidth)
        allowedMoves.append(bottomLeft - 1)
        allowedMoves.append(bottomRight + boardWidth)
        allowedMoves.append(bottomRight + 1)
        allowedMoves.removeAll(where: { $0 < 0 || $0 >= boardWidth * boardWidth })
        
        if selectedCell % boardWidth <= 1 {
            allowedMoves.removeAll(where: { $0 == topLeft - 1 || $0 == bottomLeft - 1 })
            if selectedCell % boardWidth < 1 {
                allowedMoves.removeAll(where: { $0 == topLeft - boardWidth || $0 == bottomLeft + boardWidth })
            }
        }
        
        if selectedCell % boardWidth >= boardWidth - 2 {
            allowedMoves.removeAll(where: { $0 == topRight + 1 || $0 == bottomRight + 1 })
            if selectedCell % boardWidth > boardWidth - 2 {
                allowedMoves.removeAll(where: { $0 == topRight - boardWidth || $0 == bottomRight + boardWidth })
            }
        }
        
        for allowedMove in allowedMoves {
            if isWhiteTurn(turn: playerTurn) && isWhite(piece: cells[allowedMove])
            || isBlackTurn(turn: playerTurn) && isBlack(piece: cells[allowedMove]) {
                allowedMoves.removeAll(where: { $0 == allowedMove })
            }
        }
        
        return allowedMoves
    }
    
    static func getDiagonals(playerTurn: Bool, selectedCell: Int, cells: [Int], limit: Bool = false) -> [Int] {
        var allowedMoves = [Int]()
        
        // Mid to Top-Left
        var i = selectedCell - boardWidth - 1
        while i >= 0 && i < boardWidth*boardWidth && i % boardWidth < boardWidth - 1 {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i -= boardWidth + 1
            if limit { break }
        }
        
        // Mid to Top-Right
        i = selectedCell - boardWidth + 1
        while i >= 0 && i < boardWidth*boardWidth && i % boardWidth != 0 {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i -= boardWidth - 1
            if limit { break }
        }
        
        // Mid to Bottom-Left
        i = selectedCell + boardWidth - 1
        while i >= 0 && i < boardWidth*boardWidth && i % boardWidth < boardWidth - 1 {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i += boardWidth - 1
            if limit { break }
        }
        
        // Mid to Bottom-Right
        i = selectedCell + boardWidth + 1
        while i >= 0 && i < boardWidth*boardWidth && i % boardWidth != 0 {
            if !isEmpty(piece: cells[i]) {
                if isWhiteTurn(turn: playerTurn) && isBlack(piece: cells[i])
                || isBlackTurn(turn: playerTurn) && isWhite(piece: cells[i]) {
                    allowedMoves.append(i)
                }
                break
            }
            
            allowedMoves.append(i)
            i += boardWidth + 1
            if limit { break }
        }
        
        return allowedMoves
    }
}
