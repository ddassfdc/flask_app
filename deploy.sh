#!/bin/bash

# Flask Animal Gallery App Deployment Script
# This script sets up the Flask app to run directly with Gunicorn on port 5000

set -e  # Exit on any error

echo "🚀 Starting Flask Animal Gallery App deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install required system packages
echo "🔧 Installing system dependencies..."
sudo apt install -y python3 python3-pip python3-venv nginx

# Create app directory if it doesn't exist
echo "📁 Setting up application directory..."
cd ~
if [ ! -d "flask_app" ]; then
    echo "❌ flask_app directory not found!"
    echo "📁 Current directory: $(pwd)"
    echo "📋 Files in current directory:"
    ls -la
    exit 1
fi

cd flask_app

# Check if requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt not found in $(pwd)"
    echo "📁 Current directory: $(pwd)"
    echo "📋 Files in current directory:"
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

# Update Gunicorn config to use port 5000 directly
echo "⚙️ Updating Gunicorn configuration..."
sed -i 's/bind = "0.0.0.0:8000"/bind = "0.0.0.0:5000"/' gunicorn.conf.py

# Set up systemd service for direct Gunicorn access
echo "⚙️ Setting up systemd service..."
echo "📁 Checking for flask-app.service..."
if [ -f "flask-app.service" ]; then
    echo "✅ Found flask-app.service"
    ls -la flask-app.service
else
    echo "❌ flask-app.service not found!"
    echo "📁 Current directory contents:"
    ls -la
    exit 1
fi

# Create updated service file for direct Gunicorn access
sudo tee /etc/systemd/system/flask-app.service << 'EOF'
[Unit]
Description=Flask Animal Gallery App
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/flask_app
Environment=PATH=/home/ubuntu/flask_app/venv/bin
ExecStart=/home/ubuntu/flask_app/venv/bin/gunicorn --config gunicorn.conf.py wsgi:app
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app

# Stop and disable Nginx (not needed anymore)
echo "🔄 Stopping and disabling Nginx..."
sudo systemctl stop nginx
sudo systemctl disable nginx

# Check service status
echo "📊 Checking service status..."
sudo systemctl status flask-app

echo "✅ Deployment completed!"
echo "🌐 Your app is now accessible at: http://YOUR_EC2_PUBLIC_IP:5000"
echo "📝 Check logs with: sudo journalctl -u flask-app -f"
echo "🔄 Restart service with: sudo systemctl restart flask-app"
echo "📊 Check status with: sudo systemctl status flask-app"
echo "🌍 Test access with: curl http://localhost:5000"
