//
//  Board.swift
//  TicTacToe
//
//  Created by span on 8/19/18.
//

struct BoardIndex: Hashable, Comparable {
    let row: Int
    let column: Int

    static func < (lhs: BoardIndex, rhs: BoardIndex) -> Bool {
        if lhs.row == rhs.row {
            return lhs.column < rhs.column
        }
        return lhs.row < rhs.row
    }
}


// MARK: -
enum Cell: String {
    case S = "-"
    case X
    case O
}

extension Cell: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}


// MARK: -
struct Board {
    let size: Int
    private var cells: [[Cell]]

    init?(size: Int) {
        guard size > 0 else {
            return nil
        }
        self.size = size
        self.cells = Array(repeating: Array(repeating: Cell.S, count: size), count: size)
        self.allLanes = {
            var lanes = Array(0..<size).map({ BoardIndex(row: $0, column: -1) })
            lanes.append(contentsOf: Array(0..<size).map({ BoardIndex(row: -1, column: $0) }))
            lanes.append(BoardIndex(row: size, column: size))
            lanes.append(BoardIndex(row: -size, column: -size))
            return lanes
        }()
    }

    mutating func reset() {
        self.cells = Array(repeating: Array(repeating: Cell.S, count: size), count: size)
        self.lanes = [:]
    }

    var isFull: Bool {
        for cell in self where cell == .S {
            return false
        }
        return true
    }

    subscript(row: Int, column: Int) -> Cell {
        get {
            return cells[row][column]
        }
        set {
            cells[row][column] = newValue
        }
    }

    let allLanes: [BoardIndex]

    /// dictionary records lane occupation status
    /// horizontals: (x, -1)
    /// verticals: (-1, y)
    /// diagonals: (size, size), (-size, -size)
    /// Memory O(2n + 2)
    private(set) var lanes: [BoardIndex: Int] = [:]

    mutating func move(_ index: BoardIndex, to cell: Cell) -> (success: Bool, win: Bool) {
        guard 0..<size ~= index.row, 0..<size ~= index.column, self[index] == .S else {
            return (false, false)
        }
        self[index] = cell

        var win = false

        for lane in lanesForCell(index) {
            lanes[lane] = (lanes[lane] ?? 0) + (cell == .X ? 1 : -1)
            if abs(lanes[lane]!) >= size {
                win = true
            }
        }

        return (true, win)
    }

    func lanesForCell(_ index: BoardIndex) -> [BoardIndex] {
        var lanesForCell = [BoardIndex(row: index.row, column: -1), BoardIndex(row: -1, column: index.column)]
        if index.row == index.column {
            lanesForCell.append(BoardIndex(row: size, column: size))
        }
        if index.row + index.column == size - 1 {
            lanesForCell.append(BoardIndex(row: -size, column: -size))
        }
        return lanesForCell
    }

    func hasWinner() -> Cell? {
        for lane in lanes where abs(lane.value) >= size {
            return lane.value > 0 ? .X : .O
        }
        return nil
    }
}

extension Board: MutableCollection {

    typealias Index = BoardIndex
    typealias Element = Cell

    var startIndex: Index {
        return BoardIndex(row: 0, column: 0)
    }

    var endIndex: Index {
        return BoardIndex(row: size, column: 0)
    }

    subscript(position: Index) -> Element {
        get {
            return self[position.row, position.column]
        }
        set {
            self[position.row, position.column] = newValue
        }
    }

    func index(after i: Index) -> Index {
        var row = i.row
        var col = i.column + 1
        if col == size {
            col = 0
            row += 1
        }
        return BoardIndex(row: row, column: col)
    }
}

extension Board: CustomStringConvertible {
    var description: String {
        var des = ""
        for (i, cell) in enumerated() {
            des.append(cell.description)
            if (i + 1) % size == 0 {
                des.append("\n")
            } else {
                des.append("|")
            }
        }
        return des
    }
}
