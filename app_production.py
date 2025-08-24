from flask import Flask, render_template, request, jsonify, send_from_directory
import os
from werkzeug.utils import secure_filename
import json
import logging
from logging.handlers import RotatingFileHandler

app = Flask(__name__)

# Production Configuration
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-change-in-production')

# Ensure upload directory exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Allowed file extensions
ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif', 'doc', 'docx', 'xls', 'xlsx', 'zip', 'rar'}

# Configure logging for production
if not app.debug:
    if not os.path.exists('logs'):
        os.mkdir('logs')
    file_handler = RotatingFileHandler('logs/animal-detector.log', maxBytes=10240, backupCount=10)
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)
    app.logger.info('Animal Detector startup')

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    """Serve the main HTML page"""
    return send_from_directory('.', 'index.html')

@app.route('/<path:filename>')
def serve_static(filename):
    """Serve static files (CSS, JS)"""
    return send_from_directory('.', filename)

@app.route('/upload', methods=['POST'])
def upload_file():
    """Handle file uploads"""
    try:
        # Check if file was uploaded
        if 'file' not in request.files:
            return jsonify({'error': 'No file part'}), 400
        
        file = request.files['file']
        
        # Check if file was selected
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Check if file type is allowed
        if not allowed_file(file.filename):
            return jsonify({'error': 'File type not allowed'}), 400
        
        # Secure the filename and save the file
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Get file information
        file_size = os.path.getsize(filepath)
        file_type = file.content_type or 'Unknown'
        
        # Log successful upload
        app.logger.info(f'File uploaded: {filename}, size: {file_size}, type: {file_type}')
        
        # Return file information
        file_info = {
            'message': 'File uploaded successfully',
            'filename': filename,
            'size': file_size,
            'size_formatted': format_file_size(file_size),
            'type': file_type,
            'uploaded_at': os.path.getctime(filepath)
        }
        
        return jsonify(file_info), 200
        
    except Exception as e:
        app.logger.error(f'Upload error: {str(e)}')
        return jsonify({'error': str(e)}), 500

@app.route('/files', methods=['GET'])
def list_files():
    """List all uploaded files"""
    try:
        files = []
        upload_dir = app.config['UPLOAD_FOLDER']
        
        if os.path.exists(upload_dir):
            for filename in os.listdir(upload_dir):
                filepath = os.path.join(upload_dir, filename)
                if os.path.isfile(filepath):
                    file_info = {
                        'filename': filename,
                        'size': os.path.getsize(filepath),
                        'size_formatted': format_file_size(os.path.getsize(filepath)),
                        'uploaded_at': os.path.getctime(filepath)
                    }
                    files.append(file_info)
        
        return jsonify({'files': files}), 200
        
    except Exception as e:
        app.logger.error(f'List files error: {str(e)}')
        return jsonify({'error': str(e)}), 500

@app.route('/files/<filename>', methods=['DELETE'])
def delete_file(filename):
    """Delete a specific file"""
    try:
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(filename))
        
        if os.path.exists(filepath):
            os.remove(filepath)
            app.logger.info(f'File deleted: {filename}')
            return jsonify({'message': f'File {filename} deleted successfully'}), 200
        else:
            return jsonify({'error': 'File not found'}), 404
            
    except Exception as e:
        app.logger.error(f'Delete file error: {str(e)}')
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    """Health check endpoint for load balancers"""
    return jsonify({'status': 'healthy', 'service': 'animal-detector'}), 200

def format_file_size(size_bytes):
    """Format file size in human readable format"""
    if size_bytes == 0:
        return "0 Bytes"
    
    size_names = ["Bytes", "KB", "MB", "GB", "TB"]
    i = 0
    while size_bytes >= 1024 and i < len(size_names) - 1:
        size_bytes /= 1024.0
        i += 1
    
    return f"{size_bytes:.2f} {size_names[i]}"

@app.errorhandler(413)
def too_large(e):
    """Handle file too large error"""
    return jsonify({'error': 'File too large. Maximum size is 16MB.'}), 413

@app.errorhandler(404)
def not_found(e):
    """Handle 404 errors"""
    return jsonify({'error': 'Resource not found'}), 404

@app.errorhandler(500)
def internal_error(e):
    """Handle 500 errors"""
    app.logger.error(f'Server error: {str(e)}')
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # Production settings
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    
    app.logger.info(f'Starting Animal Detector server on port {port}')
    app.run(debug=debug, host='0.0.0.0', port=port)
