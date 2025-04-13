# ♟️ CheckNote
CheckNote is an iOS app designed to revolutionize **chess scorekeeping** for both casual players and tournament use. It integrates a clean, responsive chessboard interface with a digital scoresheet that tracks moves in real-time — optimized for touch interaction and visual clarity.

The app also features an innovative **Arbiter Mode**, a restricted-access view that allows referees to step through move history without interfering with active gameplay. A unique **Security Code System** ensures the app remains compliant with tournament regulations, tracking user interactions and safeguarding against unauthorized access.

### ✨ Features
- 📋 **Digital Scoresheet**: Automatically logs moves in PGN-like format and displays them in a clean UI with side-by-side move columns for White and Black.

- ⬅️➡️ **Move Replay Controls**: Navigate forward and backward through the game using intuitive buttons.

- 🔒 **Tournament-Safe Security Code**: Detects app backgrounding, ensuring integrity by generating a new code anytime the app exits focus.

- ⚠️ **Arbiter Mode Lock-In**: Displays a warning before allowing access to Arbiter Mode, ensuring proper usage during tournaments.

- 🧠 **Smart Legal Move System**: Enforces legal chess moves, including special cases like castling.

- 🎨 **Custom UI**: Built entirely in SwiftUI with a polished aesthetic, including rounded buttons, colored squares, and clean layout for readability.

### 📱 Preview

![ChessMotion Demo](assets/chessmotion_demo_small.gif)

### Figure 1: The chess player will have a device beside them during a tournament. For every move they make on the chess board, they make the identical move on CheckNote

<p align="center">
  <img src="Asset/Settings.png" alt="ChessMotion demo of move tracking" width="300" height="600">
</p>

### Figure 2: Settings page allows for configuration of appearance and access to Arbitor Mode

<p align="center">
  <img src="Asset/Export.png" alt="ChessMotion demo of move tracking" width="300" height="600">
</p>

### Figure 3: A standard chess scoresheet can be exported after the game
