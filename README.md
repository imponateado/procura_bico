# Procura Bico 

**Procura Bico** is a Flutter app designed to help users process WhatsApp chat exports shared as `.zip` files. It supports splitting chats based on a delimiter and deleting messages based on specific criteria.

## Features

- Process shared WhatsApp chat exports directly from the file sharing intent.
- Split chats into segments using a customizable delimiter.
- Delete messages that contain specific words or phrases.
- Remove the first message from the processed list.
- Intuitive UI with a real-time preview of processed messages.

## How It Works

1. **Sharing Files**: The app listens for shared `.zip` files containing WhatsApp chat exports. The `.zip` should include a `_chat.txt` file.
2. **Processing Chats**: Once a valid file is shared, the app extracts and processes the `_chat.txt` file.
3. **Editing Messages**:
   - Split the chat into segments using a custom delimiter.
   - Filter out messages containing specific keywords.
   - Remove the first message from the list.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/chat-processor.git
   cd chat-processor
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an emulator or physical device:
   ```bash
   flutter run
   ```

## Dependencies

- **Flutter**: A UI toolkit for building natively compiled apps.
- **receive_sharing_intent**: For handling shared files.
- **archive**: For extracting `.zip` files.

## Usage

1. Export a WhatsApp chat as `.zip` (including media is optional).
2. Share the `.zip` file with the Procura Bico app.
3. Use the provided controls to split and clean the chat messages.

## Screenshots

*(Include screenshots here to show the app in action.)*

## Future Improvements

- Support for additional file formats.
- Advanced filtering options with regex support.
- Exporting processed chats as new text files.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
