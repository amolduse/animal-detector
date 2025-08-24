#!/bin/bash

echo "🚀 Deploying Animal Detector & File Upload System to AWS Ubuntu Server"
echo "=================================================================="

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "🔧 Installing required packages..."
sudo apt install python3 python3-pip python3-venv nginx build-essential python3-dev -y

# Create application directory
echo "📁 Setting up application directory..."
sudo mkdir -p /var/www/animal-detector
sudo chown ubuntu:ubuntu /var/www/animal-detector
cd /var/www/animal-detector

# Create virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create uploads directory
echo "📁 Creating uploads directory..."
mkdir -p uploads
chmod 755 uploads

# Create systemd service file
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/animal-detector.service > /dev/null <<EOF
[Unit]
Description=Animal Detector Flask App
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/var/www/animal-detector
Environment="PATH=/var/www/animal-detector/venv/bin"
ExecStart=/var/www/animal-detector/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx
echo "🌐 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/animal-detector > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static {
        alias /var/www/animal-detector;
    }
}
EOF

# Enable site and restart services
echo "🔄 Enabling services..."
sudo ln -sf /etc/nginx/sites-available/animal-detector /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl daemon-reload
sudo systemctl enable animal-detector
sudo systemctl start animal-detector
sudo systemctl restart nginx

# Check status
echo "✅ Checking service status..."
sudo systemctl status animal-detector --no-pager
sudo systemctl status nginx --no-pager

echo ""
echo "🎉 Deployment completed!"
echo "🌐 Your app is now running at: http://$(curl -s ifconfig.me)"
echo "📁 Application directory: /var/www/animal-detector"
echo "📋 Useful commands:"
echo "   - View logs: sudo journalctl -u animal-detector -f"
echo "   - Restart app: sudo systemctl restart animal-detector"
echo "   - Restart nginx: sudo systemctl restart nginx"
echo "   - Stop app: sudo systemctl stop animal-detector"
