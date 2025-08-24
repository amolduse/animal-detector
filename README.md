# Animal Detector & File Upload System

A modern web application with a beautiful frontend and Flask backend that allows users to:
1. Select and view images of cats, dogs, or elephants
2. Upload files and get detailed information about them

## Features

### Frontend
- **Animal Selection**: Dropdown to select cat, dog, or elephant with instant image display
- **File Upload**: Drag & drop or click to upload files
- **File Information**: Display file name, size, type, and last modified date
- **Responsive Design**: Works on desktop and mobile devices
- **Modern UI**: Beautiful gradient background with hover effects

### Backend
- **Flask Server**: Python-based REST API
- **File Upload Handling**: Secure file uploads with size and type validation
- **File Management**: List, upload, and delete files
- **Error Handling**: Comprehensive error handling for various scenarios

## Project Structure

```
detect-cat-dog-elephant/
├── index.html          # Main HTML page
├── styles.css          # CSS styling
├── script.js           # Frontend JavaScript
├── app.py              # Flask backend server
├── requirements.txt    # Python dependencies
├── README.md           # This file
└── uploads/            # Upload directory (created automatically)
```

## Installation & Setup

### Prerequisites
- Python 3.7 or higher
- pip (Python package installer)

### Backend Setup
1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the Flask server:**
   ```bash
   python app.py
   ```

3. **Access the application:**
   - Open your browser and go to: `http://localhost:5000`
   - The server will start on port 5000

### Frontend
- The frontend is served automatically by the Flask server
- No additional setup required
- All static files (HTML, CSS, JS) are served from the root directory

## Usage

### Animal Selection
1. Use the dropdown in the left box to select an animal
2. The corresponding image will be displayed instantly
3. Images are fetched from Unsplash (high-quality stock photos)

### File Upload
1. **Click Upload**: Click on the upload area in the right box
2. **Drag & Drop**: Drag files directly onto the upload area
3. **File Information**: After upload, you'll see:
   - File name
   - File size (formatted)
   - File type
   - Last modified date

### Supported File Types
- Documents: txt, pdf, doc, docx, xls, xlsx
- Images: png, jpg, jpeg, gif
- Archives: zip, rar
- Maximum file size: 16MB

## API Endpoints

- `GET /` - Main page
- `POST /upload` - Upload a file
- `GET /files` - List all uploaded files
- `DELETE /files/<filename>` - Delete a specific file

## Customization

### Adding More Animals
1. Edit `script.js` and add new entries to the `animalImages` object
2. Update the HTML dropdown in `index.html`
3. Add corresponding CSS if needed

### Changing File Types
1. Modify the `ALLOWED_EXTENSIONS` set in `app.py`
2. Update the `accept` attribute in the HTML file input if needed

### Styling
- Modify `styles.css` to change colors, fonts, and layout
- The design uses CSS Grid and Flexbox for responsive layout
- Color scheme can be easily changed in the CSS variables

## Security Features

- File type validation
- File size limits (16MB max)
- Secure filename handling
- Upload directory isolation

## Browser Compatibility

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## Troubleshooting

### Common Issues

1. **Port already in use:**
   - Change the port in `app.py` (line: `app.run(port=5001)`)
   - Or kill the process using port 5000

2. **File upload fails:**
   - Check file size (max 16MB)
   - Verify file type is in allowed extensions
   - Ensure uploads directory has write permissions

3. **Images not loading:**
   - Check internet connection (images are from Unsplash)
   - Verify the image URLs in `script.js`

### Debug Mode
The Flask server runs in debug mode by default. To disable:
```python
app.run(debug=False, host='0.0.0.0', port=5000)
```

## Development

### Adding New Features
1. **Frontend**: Modify HTML, CSS, or JavaScript files
2. **Backend**: Add new routes in `app.py`
3. **Database**: Currently uses file system; can be extended with SQLite/PostgreSQL

### Testing
- Test file uploads with various file types
- Verify responsive design on different screen sizes
- Check error handling with invalid files

## License

This project is open source and available under the MIT License.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this project!
