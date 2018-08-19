//
//  Board.swift
//  TicTacToe
//
//  Created by span on 8/19/18.
//

import Foundation

class Game {

    init(boardSize: Int = 3, ai: AI = EnhancedAI()) {
        self.board = Board(size: boardSize) ?? Board(size: 3)!
        self.ai = ai
    }

    private(set) var board: Board
    let ai: AI
    private var steps = 0

    func on() {
        print(board)

        while true {
            let isPlayerMove = steps % 2 == 0
            let move: BoardIndex

            if isPlayerMove {
                let input = readLine()
                let parameters = input?.components(separatedBy: CharacterSet(charactersIn: ", ")).filter({ !$0.isEmpty })
                if parameters?.count == 2,
                    let toIndex = parameters?.compactMap({ Int($0) }), toIndex.count == 2 {
                    move = BoardIndex(row: toIndex[0] - 1, column: toIndex[1] - 1)
                } else {
                    move = BoardIndex(row: -1, column: -1)
                }
            } else {
                move = ai.nextMove(on: board)
            }

            let (success, win) = board.move(move, to: isPlayerMove ? .X : .O)

            guard success else {
                if isPlayerMove {
                    print("Invalid move")
                    continue
                } else {
                    print("AI trolls, \(move)")
                    break
                }
            }

            print("\(isPlayerMove ? "Player moved:" : "AI moved:")\n" + board.description)

            if win {
                print("\(isPlayerMove ? "Player" : "AI") win!")
                break
            }

            if board.isFull {
                print("draw game!")
                break
            }

            steps += 1
        }
    }

    func over() {
        board.reset()
        steps = 0
    }
}
