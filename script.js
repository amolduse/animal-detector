// Animal images data - Multiple reliable URLs for each animal
const animalImages = {
    cat: [
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop&auto=format',
        'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400&h=300&fit=crop&auto=format',
        'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=400&h=300&fit=crop&auto=format'
    ],
    dog: [
        'https://images.unsplash.com/photo-1547407139-3c921a66005c?w=400&h=300&fit=crop&auto=format',
        'https://images.unsplash.com/photo-1517423440428-a5b00fcdb524?w=400&h=300&fit=crop&auto=format',
        'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=400&h=300&fit=crop&auto=format'
    ],
    elephant: [
        'https://images.unsplash.com/photo-1557050543-4d5f2e07c346?w=400&h=300&fit=crop&auto=format',
        'https://images.unsplash.com/photo-1503919545889-8ef8e88e7c96?w=400&h=300&fit=crop&auto=format',
        'https://images.unsplash.com/photo-1564349683136-77e08dba1ef7?w=400&h=300&fit=crop&auto=format'
    ]
};

// Fallback images in case Unsplash fails
const fallbackImages = {
    cat: 'https://picsum.photos/400/300?random=1',
    dog: 'https://picsum.photos/400/300?random=2', 
    elephant: 'https://picsum.photos/400/300?random=3'
};

// Function to try loading images with multiple URLs
function tryLoadImage(urls, animalType, animalImageDiv, index = 0) {
    if (index >= urls.length) {
        // All URLs failed, try fallback
        tryFallbackImage(animalType, animalImageDiv);
        return;
    }
    
    const img = document.createElement('img');
    img.src = urls[index];
    img.alt = `${animalType} image`;
    
    img.onload = () => {
        animalImageDiv.innerHTML = '';
        animalImageDiv.appendChild(img);
    };
    
    img.onerror = () => {
        console.log(`Image ${index + 1} failed for ${animalType}, trying next...`);
        tryLoadImage(urls, animalType, animalImageDiv, index + 1);
    };
}

// Function to try fallback image
function tryFallbackImage(animalType, animalImageDiv) {
    const fallbackImg = document.createElement('img');
    fallbackImg.src = fallbackImages[animalType];
    fallbackImg.alt = `${animalType} image (fallback)`;
    
    fallbackImg.onload = () => {
        animalImageDiv.innerHTML = '';
        animalImageDiv.appendChild(fallbackImg);
    };
    
    fallbackImg.onerror = () => {
        // If fallback also fails, show emoji placeholder
        showEmojiPlaceholder(animalType, animalImageDiv);
    };
}

// Function to show emoji placeholder
function showEmojiPlaceholder(animalType, animalImageDiv) {
    animalImageDiv.innerHTML = `
        <div class="fallback-display">
            <span class="emoji">
                ${animalType === 'cat' ? '🐱' : animalType === 'dog' ? '🐕' : '🐘'}
            </span>
            <div class="animal-name">${animalType.charAt(0).toUpperCase() + animalType.slice(1)}</div>
            <div class="status">Image temporarily unavailable</div>
        </div>
    `;
}

// Function to show selected animal image
function showAnimal() {
    const select = document.getElementById('animalSelect');
    const animalImageDiv = document.getElementById('animalImage');
    const selectedAnimal = select.value;
    
    if (selectedAnimal) {
        // Show loading state
        animalImageDiv.innerHTML = '<p style="color: #666;">Loading image...</p>';
        
        // Try to load images with multiple URLs
        tryLoadImage(animalImages[selectedAnimal], selectedAnimal, animalImageDiv);
    } else {
        animalImageDiv.innerHTML = '';
    }
}

// Function to handle file upload
function handleFileUpload() {
    const fileInput = document.getElementById('fileInput');
    const fileInfoDiv = document.getElementById('fileInfo');
    const file = fileInput.files[0];
    
    if (file) {
        // Display file information
        const fileSize = formatFileSize(file.size);
        const fileType = file.type || 'Unknown';
        
        fileInfoDiv.innerHTML = `
            <h3>📄 File Information</h3>
            <p><strong>Name:</strong> ${file.name}</p>
            <p><strong>Size:</strong> ${fileSize}</p>
            <p><strong>Type:</strong> ${fileType}</p>
            <p><strong>Last Modified:</strong> ${new Date(file.lastModified).toLocaleString()}</p>
        `;
        
        // Send file to backend (optional - for demonstration)
        // uploadFileToServer(file);
    } else {
        fileInfoDiv.innerHTML = '';
    }
}

// Function to format file size
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Drag and drop functionality
document.addEventListener('DOMContentLoaded', function() {
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('fileInput');
    
    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        uploadArea.addEventListener(eventName, preventDefaults, false);
        document.body.addEventListener(eventName, preventDefaults, false);
    });
    
    // Highlight drop area when item is dragged over it
    ['dragenter', 'dragover'].forEach(eventName => {
        uploadArea.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        uploadArea.addEventListener(eventName, unhighlight, false);
    });
    
    // Handle dropped files
    uploadArea.addEventListener('drop', handleDrop, false);
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    function highlight(e) {
        uploadArea.classList.add('dragover');
    }
    
    function unhighlight(e) {
        uploadArea.classList.remove('dragover');
    }
    
    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0) {
            fileInput.files = files;
            handleFileUpload();
        }
    }
});

// Optional: Function to upload file to backend server
function uploadFileToServer(file) {
    const formData = new FormData();
    formData.append('file', file);
    
    fetch('/upload', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        console.log('Upload successful:', data);
    })
    .catch(error => {
        console.error('Upload failed:', error);
    });
}
