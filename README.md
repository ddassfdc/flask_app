# Animal Gallery & File Upload Flask App

A modern web application built with Flask that features:
- Animal selection with image display (Cat, Dog, Elephant)
- File upload functionality with drag-and-drop support
- Beautiful, responsive UI with modern CSS

## Features

### 🐾 Animal Gallery
- Select from three animals: Cat, Dog, or Elephant
- Beautiful radio button interface
- Instant image display upon selection
- Images are embedded as SVG data URLs (no external dependencies)

### 📁 File Upload
- Drag and drop file upload
- Click to upload alternative
- Supports multiple file types: TXT, PDF, Images, Documents, Archives
- File information display: Name, Size, Type
- Error handling and validation
- Maximum file size: 16MB

## Installation & Setup

1. **Clone or download the project files**

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the Flask application:**
   ```bash
   python app.py
   ```

4. **Open your browser and navigate to:**
   ```
   http://localhost:5000
   ```

## Project Structure

```
flask_app/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── README.md             # This file
├── templates/
│   └── index.html        # Main HTML template
├── static/
│   ├── style.css         # CSS styling
│   ├── script.js         # JavaScript functionality
│   └── images/           # Image storage (created automatically)
└── uploads/              # File upload directory (created automatically)
```

## Usage

### Animal Selection
1. Click on any of the three radio buttons (Cat, Dog, Elephant)
2. The corresponding animal image will appear below the selection

### File Upload
1. **Drag and Drop:** Drag a file from your computer and drop it onto the upload area
2. **Click to Upload:** Click on the upload area to open a file browser
3. After successful upload, you'll see:
   - File name
   - File size (formatted in appropriate units)
   - File type/MIME type

## Technical Details

- **Backend:** Flask (Python web framework)
- **Frontend:** HTML5, CSS3, Vanilla JavaScript
- **File Handling:** Secure file uploads with size limits and type validation
- **Responsive Design:** Mobile-friendly interface
- **No External Dependencies:** All images are embedded SVG data URLs

## Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge
- Modern mobile browsers

## Security Features

- File type validation
- File size limits (16MB max)
- Secure filename handling
- Upload directory isolation

## Customization

You can easily customize the application by:
- Adding more animals and images
- Modifying the color scheme in `static/style.css`
- Adding new file type support in `app.py`
- Changing the maximum file size limit

## Troubleshooting

- **Port already in use:** Change the port in `app.py` line 47
- **File upload errors:** Check file type and size limits
- **Images not showing:** Ensure JavaScript is enabled in your browser

## License

This project is open source and available under the MIT License.
