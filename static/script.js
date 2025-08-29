document.addEventListener('DOMContentLoaded', function() {
    // Animal selection functionality
    const animalInputs = document.querySelectorAll('input[name="animal"]');
    const animalImageContainer = document.getElementById('animal-image');
    
    // Animal images data - using high-quality Unsplash images
    const animalImages = {
        cat: {
            url: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop&crop=center',
            alt: 'Beautiful cat with green eyes',
            name: 'Cat'
        },
        dog: {
            url: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=300&fit=crop&crop=center',
            alt: 'Happy golden retriever dog',
            name: 'Dog'
        },
        elephant: {
            url: 'https://unsplash.com/photos/elephant-walking-during-daytime-QJbyG6O0ick?w=400&h=300&fit=crop&crop=center',
            alt: 'Majestic African elephant',
            name: 'Elephant'
        }
    };
    
    // Handle animal selection
    animalInputs.forEach(input => {
        input.addEventListener('change', function() {
            const selectedAnimal = this.value;
            const animalData = animalImages[selectedAnimal];
            
            console.log('Selected animal:', selectedAnimal, animalData); // Debug log
            
            if (animalData) {
                // Show loading state
                animalImageContainer.innerHTML = `
                    <div class="loading-state">
                        <div class="loading-spinner"></div>
                        <p>Loading ${animalData.name}...</p>
                    </div>
                `;
                
                // Create image element
                const img = new Image();
                
                img.onload = function() {
                    console.log('Image loaded successfully:', animalData.url); // Debug log
                    animalImageContainer.innerHTML = `
                        <div class="animal-display">
                            <img src="${animalData.url}" alt="${animalData.alt}" title="${animalData.name}">
                            <div class="animal-info">
                                <h3>${animalData.name}</h3>
                                <p>Beautiful ${animalData.name.toLowerCase()} image</p>
                            </div>
                        </div>
                    `;
                };
                
                img.onerror = function() {
                    console.log('Image failed to load:', animalData.url); // Debug log
                    // Fallback to emoji if image fails to load
                    animalImageContainer.innerHTML = `
                        <div class="animal-display fallback">
                            <div class="fallback-icon">${getAnimalEmoji(selectedAnimal)}</div>
                            <div class="animal-info">
                                <h3>${animalData.name}</h3>
                                <p>Beautiful ${animalData.name.toLowerCase()}</p>
                            </div>
                        </div>
                    `;
                };
                
                // Set timeout for image loading
                const timeout = setTimeout(() => {
                    console.log('Image loading timeout:', animalData.url); // Debug log
                    if (img.complete === false) {
                        img.onerror(); // Trigger error handler
                    }
                }, 10000); // 10 second timeout
                
                img.onload = function() {
                    clearTimeout(timeout);
                    console.log('Image loaded successfully:', animalData.url); // Debug log
                    animalImageContainer.innerHTML = `
                        <div class="animal-display">
                            <img src="${animalData.url}" alt="${animalData.alt}" title="${animalData.name}">
                            <div class="animal-info">
                                <h3>${animalData.name}</h3>
                                <p>Beautiful ${animalData.name.toLowerCase()} image</p>
                            </div>
                        </div>
                    `;
                };
                
                img.src = animalData.url;
            }
        });
    });
    
    // Helper function to get emoji fallback
    function getAnimalEmoji(animal) {
        const emojis = {
            cat: '🐱',
            dog: '🐕',
            elephant: '🐘'
        };
        return emojis[animal] || '🦁';
    }
    
    // File upload functionality
    const uploadArea = document.getElementById('upload-area');
    const fileInput = document.getElementById('file-input');
    const uploadResult = document.getElementById('upload-result');
    const uploadError = document.getElementById('upload-error');
    const filenameSpan = document.getElementById('filename');
    const filesizeSpan = document.getElementById('filesize');
    const filetypeSpan = document.getElementById('filetype');
    const errorMessage = document.getElementById('error-message');
    
    // Click to upload
    uploadArea.addEventListener('click', function() {
        fileInput.click();
    });
    
    // File input change
    fileInput.addEventListener('change', function() {
        if (this.files.length > 0) {
            handleFileUpload(this.files[0]);
        }
    });
    
    // Drag and drop functionality
    uploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        this.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', function(e) {
        e.preventDefault();
        this.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        this.classList.remove('dragover');
        
        if (e.dataTransfer.files.length > 0) {
            handleFileUpload(e.dataTransfer.files[0]);
        }
    });
    
    // Handle file upload
    function handleFileUpload(file) {
        const formData = new FormData();
        formData.append('file', file);
        
        // Show loading state
        uploadArea.classList.add('loading');
        uploadArea.innerHTML = `
            <div class="upload-content">
                <div class="loading-spinner"></div>
                <p>Uploading ${file.name}...</p>
                <p class="upload-hint">Please wait while we process your file</p>
            </div>
        `;
        
        fetch('/upload', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                showError(data.error);
            } else {
                showUploadResult(data);
            }
        })
        .catch(error => {
            showError('Upload failed: ' + error.message);
        })
        .finally(() => {
            // Reset upload area
            resetUploadArea();
        });
    }
    
    // Show upload result
    function showUploadResult(data) {
        filenameSpan.textContent = data.filename;
        filesizeSpan.textContent = formatFileSize(data.filesize);
        filetypeSpan.textContent = data.filetype;
        
        uploadResult.style.display = 'block';
        uploadError.style.display = 'none';
        
        // Add success animation
        uploadResult.style.animation = 'none';
        uploadResult.offsetHeight; // Trigger reflow
        uploadResult.style.animation = 'slide-up 0.4s ease';
    }
    
    // Show error
    function showError(message) {
        errorMessage.textContent = message;
        uploadError.style.display = 'block';
        uploadResult.style.display = 'none';
        
        // Add error animation
        uploadError.style.animation = 'none';
        uploadError.offsetHeight; // Trigger reflow
        uploadError.style.animation = 'slide-up 0.4s ease';
    }
    
    // Reset upload area
    function resetUploadArea() {
        uploadArea.classList.remove('loading');
        uploadArea.innerHTML = `
            <div class="upload-content">
                <svg class="upload-icon" viewBox="0 0 24 24">
                    <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                </svg>
                <p>Click to upload or drag and drop</p>
                <p class="upload-hint">Supports: TXT, PDF, Images, Documents, Archives</p>
            </div>
        `;
    }
    
    // Format file size
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
});
