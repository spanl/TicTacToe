//
//  AI.swift
//  TicTacToe
//
//  Created by span on 8/19/18.
//

protocol AI {
    func nextMove(on board: Board) -> BoardIndex
}

extension AI {
    func search(target: Cell, lane: BoardIndex, board: Board) -> BoardIndex {
        if lane.row == -1 {
            for i in 0..<board.size where board[i, lane.column] == target {
                return BoardIndex(row: i, column: lane.column)
            }
        } else if lane.column == -1 {
            for j in 0..<board.size where board[lane.row, j] == target {
                return BoardIndex(row: lane.row, column: j)
            }
        } else if lane.row == board.size {
            for i in 0..<board.size where board[i, i] == target {
                return BoardIndex(row: i, column: i)
            }
        } else if lane.row == -board.size {
            for i in 0..<board.size where board[board.size - 1 - i, i] == target {
                return BoardIndex(row: i, column: i)
            }
        }
        return BoardIndex(row: -1, column: -1)
    }
}

/// Next avaiable strategy
struct StupidAI: AI {
    func nextMove(on board: Board) -> BoardIndex {
        for (i, cell) in board.enumerated() where cell == .S {
            return BoardIndex(row: i / board.size, column: i % board.size)
        }
        return BoardIndex(row: -1, column: -1)
    }
}

/// Fill lane with most counts without blocked strategy
struct FineAI: AI {
    func nextMove(on board: Board) -> BoardIndex {
        var move = BoardIndex(row: -1, column: -1)

        let lanes = board.allLanes
            .filter { self.search(target: .X, lane: $0, board: board).row == -1 }
            .map { (key: $0, value: board.lanes[$0] ?? 0) }

        if let lane = lanes.sorted(by: { $0.value < $1.value }).first {
            move = search(target: .S, lane: lane.key, board: board)
        }

        if move.row == -1 {
            move = StupidAI().nextMove(on: board)
        }

        return move
    }
}

/// Blocking opponent first strategy
struct EnhancedAI: AI {
    func nextMove(on board: Board) -> BoardIndex {
        var move = BoardIndex(row: -1, column: -1)

        if let opponentMax = board.lanes.max(by: { $0.value < $1.value })?.value {
            let lanes = board.lanes
                .filter({ $0.value == opponentMax && self.search(target: .O, lane: $0.key, board: board).row == -1 })
            let xDia = BoardIndex(row: board.size, column: board.size)
            let yDia = BoardIndex(row: -board.size, column: -board.size)

            if lanes[xDia] != nil {
                move = search(target: .S, lane: xDia, board: board)
            } else if lanes[yDia] != nil {
                move = search(target: .S, lane: yDia, board: board)
            } else if !lanes.isEmpty {
                move = search(target: .S, lane: lanes.first!.key, board: board)
            }
        }

        let winMove = FineAI().nextMove(on: board)

        if winMove.row != -1,
            let finishLane = board.lanesForCell(winMove)
                .first(where: { board.lanes[$0] == 1 - board.size && self.search(target: .X, lane: $0, board: board).row == -1 }) {
            move = search(target: .S, lane: finishLane, board: board)
        }

        if move.row == -1 {
            move = winMove
        }

        return move
    }
}
