#!/bin/bash

echo "🚀 Quick Deploy - Animal Detector on AWS Ubuntu"
echo "================================================"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run as root. Use: sudo -u ubuntu ./quick_deploy.sh"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "app.py" ] || [ ! -f "requirements.txt" ]; then
    print_error "Please run this script from your project directory"
    exit 1
fi

print_status "Starting deployment..."

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install python3 python3-pip python3-venv nginx build-essential python3-dev -y

# Create application directory
print_status "Setting up application directory..."
sudo mkdir -p /var/www/animal-detector
sudo chown $USER:$USER /var/www/animal-detector

# Copy project files
print_status "Copying project files..."
cp -r * /var/www/animal-detector/
cd /var/www/animal-detector

# Create virtual environment
print_status "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
print_status "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install Gunicorn if not in requirements
if ! pip show gunicorn > /dev/null 2>&1; then
    print_status "Installing Gunicorn..."
    pip install gunicorn
fi

# Create necessary directories
print_status "Creating directories..."
mkdir -p uploads logs
chmod 755 uploads logs

# Create systemd service
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/animal-detector.service > /dev/null <<EOF
[Unit]
Description=Animal Detector Flask App
After=network.target

[Service]
User=$USER
WorkingDirectory=/var/www/animal-detector
Environment="PATH=/var/www/animal-detector/venv/bin"
ExecStart=/var/www/animal-detector/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 2 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx
print_status "Configuring Nginx..."
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
}
EOF

# Enable site and restart services
print_status "Enabling services..."
sudo ln -sf /etc/nginx/sites-available/animal-detector /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl daemon-reload
sudo systemctl enable animal-detector
sudo systemctl start animal-detector
sudo systemctl restart nginx

# Check if services are running
print_status "Checking service status..."
if sudo systemctl is-active --quiet animal-detector; then
    print_status "✅ Animal Detector service is running"
else
    print_error "❌ Animal Detector service failed to start"
    sudo systemctl status animal-detector --no-pager
fi

if sudo systemctl is-active --quiet nginx; then
    print_status "✅ Nginx service is running"
else
    print_error "❌ Nginx service failed to start"
    sudo systemctl status nginx --no-pager
fi

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")

echo ""
echo "🎉 Deployment completed!"
echo "========================"
echo "🌐 Your app is accessible at:"
echo "   Local:  http://localhost:5000"
echo "   Public: http://$PUBLIC_IP"
echo ""
echo "📁 Application directory: /var/www/animal-detector"
echo "📋 Useful commands:"
echo "   - View logs: sudo journalctl -u animal-detector -f"
echo "   - Restart app: sudo systemctl restart animal-detector"
echo "   - Restart nginx: sudo systemctl restart nginx"
echo "   - Stop app: sudo systemctl stop animal-detector"
echo ""
echo "🔒 Security reminder:"
echo "   - Configure firewall: sudo ufw enable"
echo "   - Restrict SSH access in AWS Security Groups"
echo "   - Consider adding SSL certificate with Let's Encrypt"
echo ""
print_status "Deployment script completed successfully!"
