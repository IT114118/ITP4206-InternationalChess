//
//  MatchRecord.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 7/1/2021.
//

class MatchRecord: Encodable, Decodable {
    var from: Int
    var to: Int
    var chessBoard: [Int]
    
    init(from: Int, to: Int, chessBoard: [Int]) {
        self.from = from
        self.to = to
        self.chessBoard = chessBoard
    }
}
