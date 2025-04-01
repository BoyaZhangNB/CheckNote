import SwiftUI

@MainActor
class MovesViewModel: ObservableObject {
    static var moves: [String] = []
}

struct ChessBoardView: View {
    @State private var selectedSquares: [String] = []
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let cream = Color(red: 237/255, green: 237/255, blue: 213/255)
    let lime = Color(red: 124/255, green: 149/255, blue: 93/255)
    let olive = Color(red: 189/255, green: 201/255, blue: 94/255)
    
    // Animation states
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
            
            // NavigationLink using NavigationStack’s new API with a value binding.
            NavigationLink("Show Moves", value: "MoveList")
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
                .padding([.leading, .trailing, .bottom])
        }
    }
    
    private func colorForSquare(at coordinate: String, row: Int, col: Int) -> Color {
        // If the square is selected, change its color.
        if selectedSquares.contains(coordinate) {
            return olive
        }
        // Otherwise, use the default chessboard color.
        return (row + col) % 2 == 0 ? cream : lime
    }
    
    private func selectSquare(_ coordinate: String) {
        // If the selected square is tapped again, cancel the selection.
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
            withAnimation(.easeOut(duration: 0.25)) {
                scaleFactor = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeIn(duration: 0.25)) {
                    scaleFactor = 0.0
                }
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
    
    var body: some View {
        List(moves, id: \.self) { move in
            Text(move)
        }
        .navigationTitle("Move List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // The "Export Moves" button navigates to ExitView and performs file export.
                NavigationLink("Export Moves", destination: ExitView())
                    .simultaneousGesture(TapGesture().onEnded {
                        exportMoves()
                    })
            }
        }
    }
    
    private func exportMoves() {
        let fileName = "moves.txt"
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try moves.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
                print("File exported to \(fileURL)")
            } catch {
                print("An error occurred during file export: \(error)")
            }
        }
    }
}

struct ExitView: View {
    var body: some View {
        // Using a ZStack to catch taps over the full screen.
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    exit(0) // Force quit the app (use cautiously)
                }
            VStack {
                Text("Tournament Over")
                    .bold()
                    .font(.largeTitle)
                    .padding(.bottom, 5)
                Text("Press anywhere to exit")
                    .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ChessBoardView()
                .navigationTitle("Tournament Mode")
                // Defining the destination for our navigation value.
                .navigationDestination(for: String.self) { value in
                    if value == "MoveList" {
                        MoveListView(moves: MovesViewModel.moves)
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
