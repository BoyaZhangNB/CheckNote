import SwiftUI

@MainActor
class MovesViewModel: ObservableObject {
    static var moves: [String] = []
}

enum Screen: Hashable {
    case security
    case chess
    case moveList
    case exit
}

struct SecurityCodeView: View {
    let securityCode: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text("Your Secure Code")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                Text(securityCode)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .padding()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            // Invisible overlay to catch taps.
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    onTap()
                    print("Navigating to Chess Board")
                }
        }
    }
}

struct ChessBoardView: View {
    @State private var selectedSquares: [String] = []
    let onShowMoves: () -> Void
    
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let cream = Color(red: 237/255, green: 237/255, blue: 213/255)
    let lime = Color(red: 124/255, green: 149/255, blue: 93/255)
    let olive = Color(red: 189/255, green: 201/255, blue: 94/255)
    
    // Animation states
    @State private var animateSelected = false
    @State private var scaleFactor: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Chessboard: 8 rows x 8 columns.
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
            
            Button("Show Moves") {
                onShowMoves()
            }
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
            .padding([.leading, .trailing, .bottom])
        }
        .navigationTitle("Tournament Mode")
    }
    
    private func colorForSquare(at coordinate: String, row: Int, col: Int) -> Color {
        if selectedSquares.contains(coordinate) {
            return olive
        }
        return (row + col) % 2 == 0 ? cream : lime
    }
    
    private func selectSquare(_ coordinate: String) {
        if selectedSquares.contains(coordinate) {
            selectedSquares.removeAll()
            return
        }
        selectedSquares.append(coordinate)
        if selectedSquares.count == 2 {
            let moveStr = "(\(selectedSquares[0]), \(selectedSquares[1]))"
            MovesViewModel.moves.append(moveStr)
            
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
                    selectedSquares.removeAll()
                }
            }
        }
    }
}

struct MoveListView: View {
    let moves: [String]
    let onExport: () -> Void
    
    var body: some View {
        List(moves, id: \.self) { move in
            Text(move)
        }
        .navigationTitle("Move List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Export Moves") {
                    onExport()
                }
            }
        }
    }
}

struct ExitView: View {
    let securityCode: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
           
                    exit(0) // Force quit the app (use with caution)
                }
            VStack(spacing: 20) {
                Text("Your Secure Code")
                    .font(.headline)
                Text(securityCode)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                
                Text("Tournament Over")
                    .bold()
                    .font(.largeTitle)
                Text("Press anywhere to exit")
                    .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AppView: View {
    @State private var path = [Screen]()
    @State private var securityCode: String = ""
    
    init() {
        _securityCode = State(initialValue: Self.generateCode())
    }
    
    static func generateCode() -> String {
        (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            // SecurityCodeView displays the current securityCode.
            SecurityCodeView(securityCode: securityCode) {
                path.append(.chess)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .chess:
                    ChessBoardView {
                        path.append(.moveList)
                    }
                case .moveList:
                    MoveListView(moves: MovesViewModel.moves) {
                        exportMoves()
                        // Capture the current code so ExitView gets this value.
                        let currentCode = securityCode
                        path.append(.exit)
                        // Optionally, you could set securityCode = currentCode here to “freeze” it.
                    }
                case .exit:
                    ExitView(securityCode: securityCode)
                case .security:
                    SecurityCodeView(securityCode: securityCode) {
                        path.append(.chess)
                    }
                }
            }
        }
        // Update the security code on background/foreground changes,
        // unless the ExitView is active.
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if path.last != .exit {
                securityCode = Self.generateCode()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if path.last != .exit {
                securityCode = Self.generateCode()
            }
        }
    }
    
    private func exportMoves() {
        let fileName = "moves.txt"
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try MovesViewModel.moves.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
                print("File exported to \(fileURL)")
            } catch {
                print("An error occurred during file export: \(error)")
            }
        }
    }
}

@main
struct ChessMotion: App {
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
