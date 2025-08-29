#!/bin/bash

# EC2 Deployment Script for Flask Animal Gallery App
# Run this script on your EC2 instance

echo "🚀 Starting EC2 deployment for Flask Animal Gallery App..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install required system packages
echo "🔧 Installing system dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv nginx git

# Create application directory
echo "📁 Setting up application directory..."
mkdir -p /home/ubuntu/flask_app
cd /home/ubuntu/flask_app

# Copy application files (if they exist in current directory)
echo "📋 Copying application files..."
if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt found in current directory"
else
    echo "❌ requirements.txt not found. Please ensure all files are uploaded to /home/ubuntu/flask_app/"
    echo "📁 Current directory contents:"
    ls -la
    exit 1
fi

# Create virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip

# Check if requirements.txt exists and install dependencies
if [ -f "requirements.txt" ]; then
    echo "📦 Installing dependencies from requirements.txt..."
    pip install -r requirements.txt
    if [ $? -eq 0 ]; then
        echo "✅ Dependencies installed successfully"
    else
        echo "❌ Failed to install dependencies"
        exit 1
    fi
else
    echo "❌ requirements.txt not found in $(pwd)"
    echo "📁 Current directory: $(pwd)"
    echo "📋 Files in current directory:"
    ls -la
    exit 1
fi

# Create uploads directory
echo "📂 Creating uploads directory..."
mkdir -p uploads
chmod 755 uploads

# Set up environment variables
echo "🔐 Setting up environment variables..."
cat > .env << EOF
SECRET_KEY=your-super-secret-key-change-this-in-production
FLASK_ENV=production
EOF

# Set up Nginx configuration
echo "🌐 Setting up Nginx..."
sudo tee /etc/nginx/sites-available/flask-app << EOF
server {
    listen 5000;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static {
        alias /home/ubuntu/flask_app/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /uploads {
        alias /home/ubuntu/flask_app/uploads;
        internal;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Set up systemd service
echo "⚙️ Setting up systemd service..."
sudo cp flask-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app

# Restart Nginx
echo "🔄 Restarting Nginx..."
sudo systemctl restart nginx

# Check service status
echo "📊 Checking service status..."
sudo systemctl status flask-app
sudo systemctl status nginx

echo "✅ Deployment completed!"
echo "🌐 Your app should be accessible at: http://YOUR_EC2_PUBLIC_IP"
echo "📝 Check logs with: sudo journalctl -u flask-app -f"
echo "🔄 Restart service with: sudo systemctl restart flask-app"
