//
//  ChessMotionApp.swift
//  ChessMotion
//
//  Created by 张博亚 on 2025/3/31.
//
import SwiftUI

class MovesViewModel: ObservableObject {
    static var moves: [String] = []
}

struct ChessBoardView: View {
    @State private var selectedSquares: [String] = []
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let cream = Color.init(red: 237/255, green: 237/255, blue: 213/255)
    let lime = Color.init(red: 124/255, green: 149/255, blue: 93/255)
    let olive = Color.init(red: 189/255, green: 201/255, blue: 94/255)
    //Animation
    @State private var animateSelected = false
    @State private var scaleFactor: CGFloat = 1.0

    
    var body: some View {
        VStack(spacing: 0) {
            // Chessboard: 8 rows x 8 columns with no gaps between squares
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        let coordinate = "\(8 - row)\(letters[col])"
                        
                        Rectangle()
                            .fill(colorForSquare(at: coordinate, row: row, col: col))
                            .frame(width: 50, height: 50)
                            .scaleEffect(selectedSquares.contains(coordinate) && animateSelected ? scaleFactor : 1.0)
                            .onTapGesture {
                                selectSquare(coordinate)
            
                            }
                    }
                }
            }
            
            // Button to export moves
            
            // Button that navigates to the MoveListView showing the full move log
            NavigationLink(destination: MoveListView(moves: MovesViewModel.moves)) {
                Text("Show Moves")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 20)
            }
            .padding([.leading, .trailing, .bottom])
        }
    }
    
    //Determines the color fil for each square
    private func colorForSquare(at coordinate: String, row: Int, col: Int) -> Color {
        // If the square is selected, change its color.
        if selectedSquares.contains(coordinate) {
            return olive
        }
        // Otherwise, use the default chessboard color.
        return (row + col) % 2 == 0 ? cream : lime
    }
    
    // Records the square tap. When two squares are selected, a move is logged.
    private func selectSquare(_ coordinate: String) {
        // If the selected square is tapped again, the selection is cancelled
        if selectedSquares.contains(coordinate) {
            selectedSquares.removeAll()
            return
        }
        
        selectedSquares.append(coordinate)
        if selectedSquares.count == 2 {
            let moveStr = "(\(selectedSquares[0]), \(selectedSquares[1]))"
            MovesViewModel.moves.append(moveStr)
            
            // Start animation sequence.
            animateSelected = true
            // Phase 1: Expand over 0.25 seconds.
            withAnimation(Animation.easeOut(duration: 0.25)) {
                scaleFactor = 1.1
            }
            
            // Phase 2: After 0.25 sec, shrink over next 0.25 sec.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(Animation.easeIn(duration: 0.25)) {
                    scaleFactor = 0.0
                }
                // After the shrink animation, reset values.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    // Reset animation state and clear selected squares.
                    scaleFactor = 1.0
                    animateSelected = false
                    selectedSquares.removeAll()
                }
            }
        }
    }
}

struct MoveListView: View {
    let moves: [String]
    @State private var navigate = false
    
    var body: some View {
        List(moves, id: \.self) { move in
            Text(move)
        }
        .navigationTitle("Move List")
        
        NavigationLink(destination: ExitView()) {
            ZStack{
            Text("Export Moves")
            .padding()
            .buttonStyle(.bordered)
            //export moves
            .onTapGesture {
                    do{
                        try moves.joined(separator: "\n").write(to: URL(fileURLWithPath: "Users/zhangboya/Desktop/moves.txt"), atomically: true, encoding: .utf8)
                    }catch{
                        print("An error occurred: \(error)")
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            ChessBoardView()
                .navigationTitle("Tournament Mode")
        }
    }
}

struct ExitView: View {
    var body: some View {
        NavigationView {
            ZStack{
                Color.black.opacity(0.001) // Invisible background to catch taps
                    .ignoresSafeArea()
                    .onTapGesture {
                        exit(0) // Force quit the app
                    }
                VStack{
                    Text("Tournament Over")
                        .bold(true)
                        .font(.largeTitle)
                        .padding(.bottom, 5)
                    Text("Press anywhere to exit")
                        .padding(.bottom, 10)
                }
            }
        }
    }
}


@main
struct ChessMotion: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
