//
//  ChessBoard.swift
//  ChessMotion
//
//  Created by 张博亚 on 2025/4/7.
//
import SwiftUI

struct ChessBoardView: View {
    @State private var securityCode: String = ChessBoardView.generateCode()

    @State private var boardPieces: [String: String] = [
        // White
        "1a": "♖", "1b": "♘", "1c": "♗", "1d": "♕", "1e": "♔", "1f": "♗", "1g": "♘", "1h": "♖",
        "2a": "♙", "2b": "♙", "2c": "♙", "2d": "♙", "2e": "♙", "2f": "♙", "2g": "♙", "2h": "♙",
        // Black
        "8a": "♜", "8b": "♞", "8c": "♝", "8d": "♛", "8e": "♚", "8f": "♝", "8g": "♞", "8h": "♜",
        "7a": "♟", "7b": "♟", "7c": "♟", "7d": "♟", "7e": "♟", "7f": "♟", "7g": "♟", "7h": "♟"
    ]
    
    @State private var invalidSquares: [String] = []
    @State private var selectedSquares: [String] = []
    @State private var selectedPiece: String? = nil
    
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let cream = Color(red: 237/255, green: 237/255, blue: 213/255)
    let lime = Color(red: 124/255, green: 149/255, blue: 93/255)
    let olive = Color(red: 189/255, green: 201/255, blue: 94/255)
    let redSquare = Color.red
    
    @State private var animateSelected = false
    @State private var scaleFactor: CGFloat = 1.0
    
    let squareSize: CGFloat = 50.0
    let rankLabelWidth: CGFloat = 20.0
    let fileLabelHeight: CGFloat = 20.0
    
    //Button navigation
    @State private var showMoveList = false
    @State private var showSettings = false
    @State private var showArbiterAlert = false
    @State private var showArbiterView = false
    
    // We rely on the environment object from ChessMotionApp.swift
    @EnvironmentObject var movesVM: MovesViewModel
    
    // For the document picker sheet
    @State private var showDocumentExporter = false
    @State private var documentURL: URL?
    

    var body: some View {
        NavigationStack{
            ZStack {
                Color(red: 62/255, green: 60/255, blue: 60/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 5) {
                    Text("Tournament Mode")
                        .font(.custom("InriaSerif-Regular", size: 25))
                        .foregroundColor(.white)
                    Text("\(securityCode)")
                        .font(.custom("InriaSerif-Regular", size: 22))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
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
                        
                        // Rank labels on the left
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
                        
                        // File labels at the bottom
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
                    
                    // Small "score sheet" area below the board
                    let last14 = Array(movesVM.moves.suffix(14))
                    let movelistlength = movesVM.moves.count
                    let k = (movelistlength <= 14) ? 0 : movelistlength - 14
                    let listpad: CGFloat = 42
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 160)
                        .cornerRadius(12)
                        .overlay(
                            HStack(alignment: .top) {
                                // Left column: White
                                VStack(alignment: .leading) {
                                    Text("White")
                                        .padding(.bottom, 1)
                                        .padding(.leading, listpad)
                                        .font(.custom("InriaSerif-Regular", size: 14))
                                    ForEach(last14.indices, id: \.self) { i in
                                        if (last14[i].hasPrefix("w")) {
                                            Text("\((k + i + 2)/2): \(last14[i].suffix(8))")
                                                .font(.custom("InriaSerif-Regular", size: 14))
                                                .padding(.leading, listpad)
                                        }
                                    }
                                }
                                Spacer()
                                // Right column: Black
                                VStack(alignment: .leading) {
                                    Text("Black")
                                        .padding(.bottom, 1)
                                        .padding(.trailing, listpad)
                                        .font(.custom("InriaSerif-Regular", size: 14))
                                    ForEach(last14.indices, id: \.self) { i in
                                        if (last14[i].hasPrefix("b")) {
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
                    
                    // Bottom button row
                    HStack(spacing: 20) {
                        // ---- UNDO Button ----
                        Button(action: {
                            undoMove()  // <<< ADDED
                        }, label: {
                            VStack {
                                Image(systemName: "arrow.uturn.left")
                                Text("Undo")
                            }
                        })
                        .foregroundColor(.white)
                        
                        // Export
                        Button(action: {
                            exportMoves()
                        }, label: {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export")
                            }
                        })
                        .foregroundColor(.white)
                        
                        // Settings
                        Button(action: {
                            showSettings = true// show settings
                        }, label: {
                            VStack {
                                Image(systemName: "gearshape")
                                Text("Setting")
                            }
                        })
                        .foregroundColor(.white)
                        
                        // Draw offer
                        Button(action: {
                            // draw offer logic
                        }, label: {
                            VStack(spacing: -3) {
                                Image(systemName: "hand.raised.fill")
                                Text("Draw")
                                Text("offer")
                            }
                        })
                        .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
            }
            
            .navigationDestination(isPresented: $showArbiterView) {
                ArbiterModeView()
            }
        }
        .sheet(isPresented: $showMoveList) {
            MoveListView(onExport: {
                // Provide or reference your export logic
            })
            .environmentObject(movesVM)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            securityCode = ChessBoardView.generateCode()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            securityCode = ChessBoardView.generateCode()
        }
        // Show the settings as a bottom sheet
        .sheet(isPresented: $showSettings) {
            // The bottom sheet
            VStack(spacing: 0) {
                
                Button("Arbiter Mode") {
                    // Show an alert to confirm
                    showArbiterAlert = true
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                
                Divider()
                    .padding(.horizontal, 5)
                    .background(Color.gray)
                
                Button("Appearance") {
                    // ...
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                
                Spacer()
            }
            .font(.custom("Inter-VariableFont_opsz,wght", size: 17))
            .foregroundColor(.black)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            .presentationDetents([.fraction(0.33)])
            
            // Show the alert on top of the sheet
            .alert("Accessing arbiter mode during a tournament is illegal. Are you sure?", isPresented: $showArbiterAlert) {
                Button("No", role: .cancel) {
                    // If No, just close the alert and remain here
                }
                Button("Yes") {
                    // If Yes, dismiss the sheet, then navigate
                    showSettings = false       // close the bottom sheet
                    showArbiterView = true     // push ArbiterModeView
                    securityCode = ChessBoardView.generateCode() //SecurityCode changes
                }
            }
        }
        
    }
    
    // MARK: - Undo Function
    private func undoMove() {
        // Pop the last move from the moveHistory
        guard let lastMove = movesVM.moveHistory.popLast() else {
            return // no moves to undo
        }
        // Remove the corresponding text from moves
        if !movesVM.moves.isEmpty {
            movesVM.moves.removeLast()
        }
        
        // Revert the board
        boardPieces[lastMove.fromCoord] = lastMove.piece
        if let captured = lastMove.capturedPiece {
            boardPieces[lastMove.toCoord] = captured
        } else {
            boardPieces[lastMove.toCoord] = nil
        }
    }
    
    // MARK: - Export Moves
        private func exportMoves() {
            let fileName = "moves.txt"
            let fileManager = FileManager.default
            
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Could not find Documents directory.")
                return
            }
            
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                // Write all moves to file
                let fileContents = movesVM.moves.joined(separator: "\n")
                try fileContents.write(to: fileURL, atomically: true, encoding: .utf8)
                
                // Store this URL for the DocumentExporter
                documentURL = fileURL
                // Show the DocumentExporter sheet
                showDocumentExporter = true
                
                print("File written to \(fileURL). Now presenting picker.")
            } catch {
                print("Error writing file: \(error)")
            }
        }
    
    // MARK: - Square Selection / Moving
    private func selectSquare(_ coordinate: String) {
        if selectedSquares.isEmpty {
            // First tap: select a piece
            guard boardPieces[coordinate] != nil else { return }
            selectedSquares.append(coordinate)
            selectedPiece = boardPieces[coordinate]
        }
        else if selectedSquares.count == 1 {
            let fromCoord = selectedSquares[0]
            let toCoord = coordinate
            if fromCoord == toCoord {
                resetSelection()
                return
            }
            
            if let piece = selectedPiece, isLegalMove(piece, fromCoord, toCoord) {
                // Capture info about any piece that’s on the destination square
                let captured = boardPieces[toCoord]  // could be nil
                
                // Move the piece
                boardPieces[toCoord] = piece
                boardPieces[fromCoord] = nil
                
                // Handle castling (unchanged from your code)
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
                
                // --- Record Move in moveHistory (NEW) ---
                let color = (movesVM.moves.count % 2 == 0) ? "w" : "b"
                movesVM.moveHistory.append(
                    MovesViewModel.Move(
                        color: color,
                        piece: piece,
                        fromCoord: fromCoord,
                        toCoord: toCoord,
                        capturedPiece: captured
                    )
                )
                
                // Keep your existing text-based record for display
                if color == "w" {
                    movesVM.moves.append("w: (\(fromCoord), \(toCoord))")
                } else {
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
        }
        else {
            resetSelection()
        }
    }
    
    // MARK: - Helper Methods
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
    
    private func colorForSquare(at coordinate: String, row: Int, col: Int) -> Color {
        if invalidSquares.contains(coordinate) {
            return redSquare
        }
        if selectedSquares.contains(coordinate) {
            return olive
        }
        return (row + col) % 2 == 0 ? cream : lime
    }
    
    static func generateCode() -> String {
        (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
    
    // Check move legality, plus parseCoord, same as your existing code
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
              let (trank, tfile) = parseCoord(to) else { return false }
        let rowDiff = abs(frank - trank)
        let colDiff = abs(ffile - tfile)
        // normal king move
        if rowDiff <= 1 && colDiff <= 1 { return true }
        // castling check
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
        // single advance
        if frank + 1 == trank && ffile == tfile && boardPieces[to] == nil {
            return true
        }
        // double advance from rank 2
        if frank == 2 && trank == 4 && ffile == tfile {
            let oneStep = "\(frank+1)\(letters[ffile-1])"
            let twoStep = "\(frank+2)\(letters[ffile-1])"
            if boardPieces[oneStep] == nil && boardPieces[twoStep] == nil {
                return true
            }
        }
        // capture
        if frank + 1 == trank && abs(ffile - tfile) == 1 && boardPieces[to] != nil {
            return true
        }
        return false
    }
    
    private func isLegalBlackPawnMove(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (trank, tfile) = parseCoord(to) else { return false }
        // single advance
        if frank - 1 == trank && ffile == tfile && boardPieces[to] == nil {
            return true
        }
        // double advance from rank 7
        if frank == 7 && trank == 5 && ffile == tfile {
            let oneStep = "\(frank-1)\(letters[ffile-1])"
            let twoStep = "\(frank-2)\(letters[ffile-1])"
            if boardPieces[oneStep] == nil && boardPieces[twoStep] == nil {
                return true
            }
        }
        // capture
        if frank - 1 == trank && abs(ffile - tfile) == 1 && boardPieces[to] != nil {
            return true
        }
        return false
    }
    
    private func rookMoveValid(_ from: String, _ to: String) -> Bool {
        guard let (frank, ffile) = parseCoord(from),
              let (trank, tfile) = parseCoord(to) else { return false }
        // same rank
        if frank == trank {
            let step = ffile < tfile ? 1 : -1
            for col in stride(from: ffile + step, to: tfile, by: step) {
                let testCoord = "\(frank)\(letters[col-1])"
                if boardPieces[testCoord] != nil { return false }
            }
            return true
        }
        // same file
        else if ffile == tfile {
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
