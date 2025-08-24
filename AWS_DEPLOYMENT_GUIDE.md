# 🚀 AWS Ubuntu Server Deployment Guide

Complete guide to deploy your Animal Detector & File Upload System on AWS Ubuntu Server.

## 📋 **Prerequisites**

- AWS Account
- Basic knowledge of AWS EC2
- SSH key pair (create one in AWS Console)

## 🔧 **Step 1: Launch EC2 Instance**

### **Instance Configuration**
1. **AMI**: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
2. **Instance Type**: 
   - Free Tier: `t2.micro`
   - Production: `t3.small` or `t3.medium`
3. **Storage**: 20 GB GP3 SSD (free tier) or larger for production

### **Security Group Setup**
Create a new security group with these rules:

| Type | Protocol | Port Range | Source |
|------|----------|------------|---------|
| SSH | TCP | 22 | Your IP (0.0.0.0/0 for testing) |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| Custom TCP | TCP | 5000 | 0.0.0.0/0 |

## 🌐 **Step 2: Connect to Your Server**

```bash
# Replace with your actual key and IP
ssh -i your-key.pem ubuntu@your-server-public-ip

# Update system
sudo apt update && sudo apt upgrade -y
```

## 📦 **Step 3: Upload Your Project**

### **Option A: Git Clone (Recommended)**
```bash
# Install git
sudo apt install git -y

# Clone your repository
git clone https://github.com/yourusername/your-repo.git
cd your-repo

# Or create project directory manually
sudo mkdir -p /var/www/animal-detector
sudo chown ubuntu:ubuntu /var/www/animal-detector
cd /var/www/animal-detector
```

### **Option B: SCP Upload**
```bash
# From your local machine
scp -i your-key.pem -r ./your-project-folder ubuntu@your-server-ip:/var/www/animal-detector/
```

## 🚀 **Step 4: Run Deployment Script**

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

## ⚙️ **Step 5: Manual Setup (Alternative)**

If you prefer manual setup:

```bash
# Install dependencies
sudo apt install python3 python3-pip python3-venv nginx build-essential python3-dev -y

# Create virtual environment
cd /var/www/animal-detector
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install --upgrade pip
pip install -r requirements_production.txt

# Create directories
mkdir -p uploads logs
chmod 755 uploads logs

# Copy service files
sudo cp animal-detector.service /etc/systemd/system/
sudo cp gunicorn.conf.py /var/www/animal-detector/

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable animal-detector
sudo systemctl start animal-detector
sudo systemctl restart nginx
```

## 🔍 **Step 6: Verify Deployment**

```bash
# Check service status
sudo systemctl status animal-detector
sudo systemctl status nginx

# Check logs
sudo journalctl -u animal-detector -f
sudo tail -f /var/www/animal-detector/logs/animal-detector.log

# Test health endpoint
curl http://localhost:5000/health
```

## 🌍 **Step 7: Access Your Application**

- **Local**: `http://localhost:5000`
- **Public**: `http://your-server-public-ip`
- **Domain**: If you have a domain, point it to your server IP

## 📊 **Monitoring & Maintenance**

### **View Logs**
```bash
# Application logs
sudo journalctl -u animal-detector -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Application-specific logs
tail -f /var/www/animal-detector/logs/animal-detector.log
```

### **Restart Services**
```bash
# Restart Flask app
sudo systemctl restart animal-detector

# Restart Nginx
sudo systemctl restart nginx

# Restart both
sudo systemctl restart animal-detector nginx
```

### **Update Application**
```bash
cd /var/www/animal-detector

# Pull latest changes (if using git)
git pull origin main

# Restart service
sudo systemctl restart animal-detector
```

## 🔒 **Security Considerations**

### **Firewall (UFW)**
```bash
# Install UFW
sudo apt install ufw -y

# Allow SSH, HTTP, HTTPS
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443

# Enable firewall
sudo ufw enable
```

### **SSL Certificate (Let's Encrypt)**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 💰 **Cost Optimization**

### **Free Tier Tips**
- Use `t2.micro` instance (750 hours/month free)
- Use 20 GB GP3 storage (free tier)
- Monitor usage in AWS Cost Explorer

### **Production Scaling**
- Use `t3.small` or `t3.medium` for better performance
- Consider Auto Scaling Groups for high traffic
- Use CloudFront CDN for static files

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Port 5000 not accessible**
   ```bash
   # Check if service is running
   sudo systemctl status animal-detector
   
   # Check firewall
   sudo ufw status
   ```

2. **Permission denied errors**
   ```bash
   # Fix ownership
   sudo chown -R ubuntu:ubuntu /var/www/animal-detector
   
   # Fix permissions
   chmod 755 uploads logs
   ```

3. **Nginx configuration errors**
   ```bash
   # Test configuration
   sudo nginx -t
   
   # Check error logs
   sudo tail -f /var/log/nginx/error.log
   ```

### **Performance Issues**
```bash
# Check resource usage
htop
free -h
df -h

# Check Gunicorn workers
ps aux | grep gunicorn
```

## 📈 **Scaling Options**

### **Load Balancer**
- Use AWS Application Load Balancer
- Configure health checks to `/health` endpoint
- Enable auto-scaling based on CPU/memory

### **Database**
- Add RDS for file metadata storage
- Use S3 for file storage instead of local disk
- Implement Redis for caching

### **Monitoring**
- CloudWatch for metrics
- AWS X-Ray for tracing
- Custom CloudWatch dashboards

## 🎯 **Next Steps**

1. **Domain Setup**: Point your domain to the server
2. **SSL Certificate**: Enable HTTPS with Let's Encrypt
3. **Monitoring**: Set up CloudWatch alarms
4. **Backup**: Configure automated backups
5. **CI/CD**: Set up GitHub Actions for auto-deployment

## 📞 **Support**

If you encounter issues:
1. Check the logs first
2. Verify security group settings
3. Ensure all services are running
4. Check file permissions and ownership

Your Animal Detector app should now be running successfully on AWS! 🎉
