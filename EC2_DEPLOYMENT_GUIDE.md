# 🚀 EC2 Deployment Guide for Flask Animal Gallery App

This guide will walk you through deploying your Flask Animal Gallery & File Upload application on an AWS EC2 instance.

## 📋 Prerequisites

- AWS Account with EC2 access
- Basic knowledge of AWS services
- SSH client (Terminal on Mac/Linux, PuTTY on Windows)

## 🏗️ Step 1: Launch EC2 Instance

### 1.1 Create EC2 Instance
1. Go to AWS Console → EC2 → Launch Instance
2. Choose **Amazon Linux 2** or **Ubuntu Server 20.04 LTS**
3. Select **t2.micro** (free tier) or larger based on your needs
4. Configure Security Groups:
   - **SSH (Port 22)**: Your IP
   - **Custom TCP (Port 5000)**: 0.0.0.0/0
   - **HTTPS (Port 443)**: 0.0.0.0/0 (optional)
5. Launch instance and download your `.pem` key file

### 1.2 Connect to Your Instance
```bash
# Make key file executable (Mac/Linux)
chmod 400 your-key.pem

# Connect via SSH
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

## 📁 Step 2: Upload Application Files

### 2.1 Option A: Using SCP (Recommended)
```bash
# From your local machine
scp -i your-key.pem -r /path/to/flask_app ubuntu@YOUR_EC2_PUBLIC_IP:~/

# Verify files were uploaded correctly
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
cd flask_app
ls -la
# You should see: app.py, requirements.txt, static/, templates/, etc.
```

### 2.2 Option B: Using Git
```bash
# On EC2 instance
cd ~
git clone YOUR_REPOSITORY_URL
cd flask_app
```

### 2.3 Option C: Manual Upload
Upload files via AWS Console or use `scp` for individual files.

## 🚀 Step 3: Automated Deployment

### 3.1 Make Deployment Script Executable
```bash
chmod +x deploy.sh
```

### 3.2 Run Deployment Script
```bash
./deploy.sh
```

The script will automatically:
- Update system packages
- Install Python, Nginx, and dependencies
- Set up virtual environment
- Configure Nginx as reverse proxy
- Create systemd service for auto-startup
- Start the application

## ⚙️ Step 4: Manual Configuration (Alternative)

If you prefer manual setup:

### 4.1 Install Dependencies
```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv nginx git
```

### 4.2 Set Up Python Environment
```bash
cd ~/flask_app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4.3 Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/flask-app
# Copy the Nginx configuration from deploy.sh
sudo ln -s /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4.4 Set Up Systemd Service
```bash
sudo cp flask-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
```

## 🔧 Step 5: Configuration Files

### 5.1 Environment Variables
Create `.env` file in your app directory:
```bash
SECRET_KEY=your-super-secret-key-change-this-in-production
FLASK_ENV=production
```

### 5.2 Update App Configuration
The app will automatically use production settings when deployed.

## 🌐 Step 6: Access Your Application

### 6.1 HTTP Access
Your app will be accessible at:
```
http://YOUR_EC2_PUBLIC_IP:5000
```

### 6.2 HTTPS Setup (Optional)
1. Get SSL certificate from Let's Encrypt
2. Update Nginx configuration
3. Redirect HTTP to HTTPS

## 📊 Step 7: Monitoring & Maintenance

### 7.1 Check Service Status
```bash
sudo systemctl status flask-app
sudo systemctl status nginx
```

### 7.2 View Logs
```bash
# Flask app logs
sudo journalctl -u flask-app -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 7.3 Restart Services
```bash
sudo systemctl restart flask-app
sudo systemctl restart nginx
```

### 7.4 Update Application
```bash
cd ~/flask_app
git pull  # if using git
# or upload new files
sudo systemctl restart flask-app
```

## 🔒 Step 8: Security Considerations

### 8.1 Firewall Configuration
```bash
# Allow only necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 5000  # Custom TCP (Flask App)
sudo ufw allow 443   # HTTPS (if using SSL)
sudo ufw enable
```

### 8.2 Regular Updates
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### 8.3 Change Default SSH Port (Optional)
```bash
sudo nano /etc/ssh/sshd_config
# Change Port 22 to Port 2222
sudo systemctl restart ssh
```

## 🚨 Troubleshooting

### Common Issues:

1. **requirements.txt Not Found**
   ```bash
   # Check if you're in the right directory
   pwd
   ls -la
   
   # Make sure all files are uploaded
   scp -i your-key.pem -r /path/to/flask_app/* ubuntu@YOUR_EC2_IP:~/flask_app/
   
   # Or check file structure
   tree ~/flask_app/
   ```

2. **Port Already in Use**
   ```bash
   sudo netstat -tlnp | grep :8000
   sudo pkill -f gunicorn
   ```

2. **Permission Denied**
   ```bash
   sudo chown -R ubuntu:ubuntu ~/flask_app
   chmod +x ~/flask_app/deploy.sh
   ```

3. **Nginx Configuration Error**
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

4. **Service Won't Start**
   ```bash
   sudo journalctl -u flask-app -n 50
   sudo systemctl status flask-app
   ```

## 📈 Performance Optimization

### 1. Increase Workers
Edit `gunicorn.conf.py`:
```python
workers = 4  # Increase based on CPU cores
```

### 2. Enable Gzip Compression
Add to Nginx configuration:
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

### 3. Static File Caching
Already configured in Nginx setup.

## 🎯 Next Steps

1. **Domain Setup**: Point your domain to EC2 IP
2. **SSL Certificate**: Set up HTTPS with Let's Encrypt
3. **Monitoring**: Set up CloudWatch or similar
4. **Backup**: Configure automated backups
5. **Scaling**: Consider using Auto Scaling Groups

## 📞 Support

If you encounter issues:
1. Check service logs
2. Verify security group settings
3. Ensure all files are properly uploaded
4. Check file permissions

---

**🎉 Congratulations!** Your Flask Animal Gallery App is now running on EC2 and accessible to the world!
