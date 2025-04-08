//
//  ChessBoard.swift
//  ChessMotion
//
//  Created by 张博亚 on 2025/4/7.
//
import SwiftUI

struct ChessBoardView: View {
    @State private var securityCode: String = ChessBoardView.generateCode()
    // Dictionary of positions -> piece symbol.
    @State private var boardPieces: [String: String] = [
        // White pieces
        "1a": "♖", "1b": "♘", "1c": "♗", "1d": "♕", "1e": "♔", "1f": "♗", "1g": "♘", "1h": "♖",
        "2a": "♙", "2b": "♙", "2c": "♙", "2d": "♙", "2e": "♙", "2f": "♙", "2g": "♙", "2h": "♙",
        // Black pieces
        "8a": "♜", "8b": "♞", "8c": "♝", "8d": "♛", "8e": "♚", "8f": "♝", "8g": "♞", "8h": "♜",
        "7a": "♟", "7b": "♟", "7c": "♟", "7d": "♟", "7e": "♟", "7f": "♟", "7g": "♟", "7h": "♟"
    ]
    
    // For temporarily marking illegal moves.
    @State private var invalidSquares: [String] = []
    @State private var selectedSquares: [String] = []
    @State private var selectedPiece: String? = nil
    
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let cream = Color(red: 237/255, green: 237/255, blue: 213/255)
    let lime = Color(red: 124/255, green: 149/255, blue: 93/255)
    let olive = Color(red: 189/255, green: 201/255, blue: 94/255)
    let redSquare = Color.red
    
    // Animation state.
    @State private var animateSelected = false
    @State private var scaleFactor: CGFloat = 1.0
    
    let squareSize: CGFloat = 50.0
    let rankLabelWidth: CGFloat = 20.0
    let fileLabelHeight: CGFloat = 20.0
    
    //display moves
    @State private var showMoveList = false
    @EnvironmentObject var movesVM: MovesViewModel
    
    var body: some View {
        // Use a ZStack to set a consistent background.
        ZStack {
            // Background color matching the reference.
            Color(red: 62/255, green: 60/255, blue: 60/255)
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                // Display the current security code at the top.
                Text("Tournament Mode")
                    .font(.custom("InriaSerif-Regular", size: 25))
                    .foregroundColor(.white)
                Text("\(securityCode)")
                    .font(.custom("InriaSerif-Regular", size: 22))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Chess board grid.
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<8, id: \.self) { col in
                                    let coordinate = "\(8 - row)\(letters[col])"
                                    ZStack {
                                        Rectangle()
                                            .fill(colorForSquare(at: coordinate, row: row, col: col))
                                            .frame(width: squareSize, height: squareSize)
                                            .scaleEffect(selectedSquares.contains(coordinate) && animateSelected ? scaleFactor : 1.0)
                                        
                                        if let pieceSymbol = boardPieces[coordinate] {
                                            Text(pieceSymbol)
                                                .font(.largeTitle)
                                        }
                                    }
                                    .onTapGesture {
                                        selectSquare(coordinate)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: squareSize * 8, height: squareSize * 8)
                    
                    // Rank labels on the left.
                    VStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { row in
                            let baseColor = (row % 2 == 0) ? cream : lime
                            let labelColor = baseColor == lime ? cream : lime
                            Text("\(8 - row)")
                                .font(.caption)
                                .foregroundColor(labelColor)
                                .frame(width: rankLabelWidth, height: squareSize)
                                .padding(.leading, 2)
                        }
                    }
                    .offset(x: 0, y: -15)
                    
                    // File labels at the bottom.
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer().frame(width: rankLabelWidth)
                            ForEach(0..<8, id: \.self) { col in
                                let baseColor = ((7 + col) % 2 == 0) ? cream : lime
                                let labelColor = baseColor == lime ? cream : lime
                                Text(letters[col])
                                    .font(.caption)
                                    .foregroundColor(labelColor)
                                    .frame(width: squareSize, height: fileLabelHeight)
                            }
                            Spacer()
                        }
                    }
                    .frame(width: squareSize * 8 + rankLabelWidth, height: squareSize * 8)
                }
                .padding(.leading, 20)
                
                // ---- 1) NEW WHITE SQUARE BELOW THE BOARD ----
                let last14 = Array(movesVM.moves.suffix(14))
                let movelistlength = movesVM.moves.count
                let k = (movelistlength <= 14) ? 0 : movelistlength-14
                let listpad: CGFloat = 42
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 160)
                    .cornerRadius(12)
                    .overlay(
                        HStack(alignment: .top) {
                            // Left column
                            VStack(alignment: .leading) {
                                Text("White")
                                    .padding(.bottom, 1)
                                    .padding(.leading, listpad)
                                    .font(.custom("InriaSerif-Regular", size: 14))
                                ForEach(last14.indices, id: \.self) { i in
                                    if (last14[i].prefix(1) == "w"){
                                        Text("\((k + i + 2)/2): \(last14[i].suffix(8))")
                                            .font(.custom("InriaSerif-Regular", size: 14))
                                            .padding(.leading, listpad)
                                            .frame(alignment: .top)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Right column
                            VStack(alignment: .leading) {
                                Text("Black")
                                    .padding(.bottom, 1)
                                    .font(.custom("InriaSerif-Regular", size: 14))
                                    .padding(.trailing, listpad)
                                ForEach(last14.indices, id: \.self) { i in
                                    if (last14[i].prefix(1) == "b"){
                                        Text("\((k + i + 2)/2): \(last14[i].suffix(8))")
                                            .font(.custom("InriaSerif-Regular", size: 14))
                                            .padding(.trailing, listpad)
                                    }
                                }
                            }
                        }
                            .foregroundColor(.black)
                            .padding()
                    )
                    .gesture(
                        TapGesture(count: 2).onEnded {
                            showMoveList = true
                        }
                    )
                    .padding(.horizontal, 40)
                // ------- BUTTONS WITH ICONS (NO BACKGROUND) -------
                HStack(spacing: 20) {
                    // Undo
                    Button(action: {
                        // Undo logic goes here
                    }, label: {
                        VStack {
                            // SF Symbol icon (placeholder)
                            Image(systemName: "arrow.uturn.left")
                            Text("Undo")
                        }
                    })
                    .foregroundColor(.white) // text/icon color
                    // Optionally, font styling
                    //.font(.headline)

                    // Export
                    Button(action: {
                        // Export logic goes here
                    }, label: {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export")
                        }
                    })
                    .foregroundColor(.white)

                    // Setting
                    Button(action: {
                        // Show your Setting view here
                    }, label: {
                        VStack {
                            Image(systemName: "gearshape")
                            Text("Setting")
                        }
                    })
                    .foregroundColor(.white)
                    
                    // Draw Offer
                    Button(action: {
                        // Offer draw logic
                    }, label: {
                        VStack(spacing: -3) {
                            Image(systemName: "hand.raised.fill")
                            Text("Draw")
                            Text("offer")
                        }
                    })
                    .foregroundColor(.white)
                }
                .padding(.top, 20) // Space above
                .padding(.bottom, 10) // Space below
            }
        }
        .sheet(isPresented: $showMoveList) {
            // MovesViewModel.moves is a static array in the sample code:
            MoveListView(onExport: {
                // Provide export logic or reference it from your App struct
            })
        }
        // Update the security code when the app goes into background/foreground.
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            securityCode = ChessBoardView.generateCode()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            securityCode = ChessBoardView.generateCode()
        }
        .navigationTitle("Tournament Mode")
    }
    
    // MARK: - Security Code Generation
    
    static func generateCode() -> String {
        (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
    
    // MARK: - Chess Board Helpers
    
    private func colorForSquare(at coordinate: String, row: Int, col: Int) -> Color {
        if invalidSquares.contains(coordinate) {
            return redSquare
        }
        if selectedSquares.contains(coordinate) {
            return olive
        }
        return (row + col) % 2 == 0 ? cream : lime
    }
    
    private func selectSquare(_ coordinate: String) {
        // First tap: select a piece.
        if selectedSquares.isEmpty {
            guard boardPieces[coordinate] != nil else { return }
            selectedSquares.append(coordinate)
            selectedPiece = boardPieces[coordinate]
        }
        // Second tap: attempt move.
        else if selectedSquares.count == 1 {
            let fromCoord = selectedSquares[0]
            let toCoord = coordinate
            
            if fromCoord == toCoord {
                resetSelection()
                return
            }
            
            if let piece = selectedPiece, isLegalMove(piece, fromCoord, toCoord) {
                boardPieces[toCoord] = piece
                boardPieces[fromCoord] = nil
                
                // Handle castling.
                if (piece == "♔" || piece == "♚"),
                   let (_, fromFile) = parseCoord(fromCoord),
                   let (_, toFile) = parseCoord(toCoord),
                   abs(fromFile - toFile) == 2 {
                    if piece == "♔" && fromCoord == "1e" {
                        if toCoord == "1g" {
                            boardPieces["1f"] = boardPieces["1h"]
                            boardPieces["1h"] = nil
                        } else if toCoord == "1c" {
                            boardPieces["1d"] = boardPieces["1a"]
                            boardPieces["1a"] = nil
                        }
                    }
                    if piece == "♚" && fromCoord == "8e" {
                        if toCoord == "8g" {
                            boardPieces["8f"] = boardPieces["8h"]
                            boardPieces["8h"] = nil
                        } else if toCoord == "8c" {
                            boardPieces["8d"] = boardPieces["8a"]
                            boardPieces["8a"] = nil
                        }
                    }
                }
                
                // Record move (if needed).
                if movesVM.moves.count%2 == 0 {
                    movesVM.moves.append("w: (\(fromCoord), \(toCoord))")
                }
                else if movesVM.moves.count%2 == 1 {
                    movesVM.moves.append("b: (\(fromCoord), \(toCoord))")
                }

                
                animateSelection()
            } else {
                invalidSquares = [fromCoord, toCoord]
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.invalidSquares = []
                }
            }
            resetSelection()
        } else {
            resetSelection()
        }
    }
    
    private func resetSelection() {
        selectedSquares.removeAll()
        selectedPiece = nil
    }
    
    private func animateSelection() {
        animateSelected = true
        withAnimation(.easeOut(duration: 0.25)) {
            scaleFactor = 1.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeIn(duration: 0.25)) {
                scaleFactor = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                scaleFactor = 1.0
                animateSelected = false
            }
        }
    }
    
    // Expanded move legality checks (same as before) ...
    private func isLegalMove(_ piece: String, _ fromCoord: String, _ toCoord: String) -> Bool {
        if let targetPiece = boardPieces[toCoord], sameColor(piece, targetPiece) {
            return false
        }
        switch piece {
        case "♙":
            return isLegalWhitePawnMove(fromCoord, toCoord)
        case "♟":
            return isLegalBlackPawnMove(fromCoord, toCoord)
        case "♖", "♜":
            return rookMoveValid(fromCoord, toCoord)
        case "♘", "♞":
            return knightMoveValid(fromCoord, toCoord)
        case "♗", "♝":
            return bishopMoveValid(fromCoord, toCoord)
        case "♕", "♛":
            return rookMoveValid(fromCoord, toCoord) || bishopMoveValid(fromCoord, toCoord)
        case "♔", "♚":
            return kingMoveValid(fromCoord, toCoord)
        default:
            return false
        }
    }
    
    private func sameColor(_ piece1: String, _ piece2: String) -> Bool {
        let whiteSet: Set<String> = ["♙", "♖", "♘", "♗", "♕", "♔"]
        return (whiteSet.contains(piece1) && whiteSet.contains(piece2)) ||
        (!whiteSet.contains(piece1) && !whiteSet.contains(piece2))
    }
    
    private func kingMoveValid(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (_, tfile) = parseCoord(to) else { return false }
        let rowDiff = abs(frank - (parseCoord(to)?.0 ?? 0))
        let colDiff = abs(ffile - tfile)
        if rowDiff <= 1 && colDiff <= 1 { return true }
        if rowDiff == 0 && colDiff == 2 {
            let kingStartWhite = "1e"
            let kingStartBlack = "8e"
            if from != kingStartWhite && from != kingStartBlack { return false }
            let isKingside = tfile > ffile
            if from == kingStartWhite {
                if isKingside {
                    if boardPieces["1f"] == nil && boardPieces["1g"] == nil && boardPieces["1h"] == "♖" {
                        return true
                    }
                } else {
                    if boardPieces["1d"] == nil && boardPieces["1c"] == nil && boardPieces["1b"] == nil && boardPieces["1a"] == "♖" {
                        return true
                    }
                }
            } else if from == kingStartBlack {
                if isKingside {
                    if boardPieces["8f"] == nil && boardPieces["8g"] == nil && boardPieces["8h"] == "♜" {
                        return true
                    }
                } else {
                    if boardPieces["8d"] == nil && boardPieces["8c"] == nil && boardPieces["8b"] == nil && boardPieces["8a"] == "♜" {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func isLegalWhitePawnMove(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (trank, tfile) = parseCoord(to) else { return false }
        if frank + 1 == trank && ffile == tfile && boardPieces[to] == nil {
            return true
        }
        if frank == 2 && trank == 4 && ffile == tfile {
            let oneStep = "\(frank+1)\(letters[ffile-1])"
            let twoStep = "\(frank+2)\(letters[ffile-1])"
            if boardPieces[oneStep] == nil && boardPieces[twoStep] == nil {
                return true
            }
        }
        if frank + 1 == trank && abs(ffile - tfile) == 1 && boardPieces[to] != nil {
            return true
        }
        return false
    }
    
    private func isLegalBlackPawnMove(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (trank, tfile) = parseCoord(to) else { return false }
        if frank - 1 == trank && ffile == tfile && boardPieces[to] == nil {
            return true
        }
        if frank == 7 && trank == 5 && ffile == tfile {
            let oneStep = "\(frank-1)\(letters[ffile-1])"
            let twoStep = "\(frank-2)\(letters[ffile-1])"
            if boardPieces[oneStep] == nil && boardPieces[twoStep] == nil {
                return true
            }
        }
        if frank - 1 == trank && abs(ffile - tfile) == 1 && boardPieces[to] != nil {
            return true
        }
        return false
    }
    
    private func rookMoveValid(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (_, tfile) = parseCoord(to) else { return false }
        if let (trank, _) = parseCoord(to), frank == trank {
            let step = ffile < tfile ? 1 : -1
            for col in stride(from: ffile + step, to: tfile, by: step) {
                let testCoord = "\(frank)\(letters[col-1])"
                if boardPieces[testCoord] != nil { return false }
            }
            return true
        } else if let (trank, _) = parseCoord(to), ffile == tfile {
            let step = frank < trank ? 1 : -1
            for row in stride(from: frank + step, to: trank, by: step) {
                let testCoord = "\(row)\(letters[ffile-1])"
                if boardPieces[testCoord] != nil { return false }
            }
            return true
        }
        return false
    }
    
    private func knightMoveValid(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (trank, tfile) = parseCoord(to) else { return false }
        let rowDiff = abs(frank - trank)
        let colDiff = abs(ffile - tfile)
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)
    }
    
    private func bishopMoveValid(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (trank, tfile) = parseCoord(to) else { return false }
        if abs(frank - trank) == abs(ffile - tfile) {
            let rowStep = (trank - frank) > 0 ? 1 : -1
            let colStep = (tfile - ffile) > 0 ? 1 : -1
            var row = frank + rowStep
            var col = ffile + colStep
            while row != trank && col != tfile {
                let testCoord = "\(row)\(letters[col-1])"
                if boardPieces[testCoord] != nil { return false }
                row += rowStep
                col += colStep
            }
            return true
        }
        return false
    }
    
    private func parseCoord(_ coord: String) -> (Int, Int)? {
        guard coord.count == 2,
              let rank = Int(String(coord.prefix(1))),
              let fileIndex = letters.firstIndex(of: String(coord.suffix(1))) else {
            return nil
        }
        let file = letters.distance(from: letters.startIndex, to: fileIndex) + 1
        return (rank, file)
    }
    
}
