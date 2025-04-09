import SwiftUI

@MainActor
class MovesViewModel: ObservableObject {
    /// A structured record of one move.
    struct Move {
        let color: String        // "w" or "b"
        let piece: String        // e.g. "♔", "♟", etc.
        let fromCoord: String
        let toCoord: String
        let capturedPiece: String?
    }
    
    /// Textual list for display (unchanged).
    @Published var moves: [String] = []
    
    /// History of moves with enough data to revert.
    @Published var moveHistory: [Move] = []
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
                
                Text("Your Game Code")
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

struct MoveListView: View {
    @EnvironmentObject var movesVM: MovesViewModel
    let onExport: () -> Void

    var body: some View {
        List(movesVM.moves, id: \.self) { move in
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
                Text("Your Game Code")
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
//
//struct AppView: View {
//    @State private var path = [Screen]()
//    @State private var securityCode: String = ""
//    
//    init() {
//        _securityCode = State(initialValue: Self.generateCode())
//    }
//    
//    static func generateCode() -> String {
//        (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
//    }
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            // SecurityCodeView displays the current securityCode.
//            SecurityCodeView(securityCode: securityCode) {
//                path.append(.chess)
//            }
//            .navigationDestination(for: Screen.self) { screen in
//                switch screen {
//                case .chess:
//                    ChessBoardView{
//                        path.append(.moveList)
//                    }
//                case .moveList:
//                    MoveListView(moves: MovesViewModel.moves) {
//                        exportMoves()
//                        // Capture the current code so ExitView gets this value.
//                        let currentCode = securityCode
//                        path.append(.exit)
//                        // Optionally, you could set securityCode = currentCode here to “freeze” it.
//                    }
//                case .exit:
//                    ExitView(securityCode: securityCode)
//                case .security:
//                    SecurityCodeView(securityCode: securityCode) {
//                        path.append(.chess)
//                    }
//                }
//            }
//        }
//        // Update the security code on background/foreground changes,
//        // unless the ExitView is active.
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
//            if path.last != .exit {
//                securityCode = Self.generateCode()
//            }
//        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//            if path.last != .exit {
//                securityCode = Self.generateCode()
//            }
//        }
//    }
    
@MainActor private func exportMoves() {
        let fileName = "moves.txt"
        let fileManager = FileManager.default
    @EnvironmentObject var movesVM: MovesViewModel
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try movesVM.moves.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
                print("File exported to \(fileURL)")
            } catch {
                print("An error occurred during file export: \(error)")
            }
        }
    }


@main
struct ChessMotion: App {
    @StateObject private var movesVM = MovesViewModel()
    var body: some Scene {
        WindowGroup {
            ChessBoardView()
                .environmentObject(movesVM)
        }
    }
}


//The following is true for diamand cubic crystsal structure
//8 atoms
//4 interstitial atoms
//4 lattice atoms
//Carbon is shiny
