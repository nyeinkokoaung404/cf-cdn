#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

echo "=========================================="
echo "  Cloudflare Origin CA Certificate Setup"
echo "=========================================="
echo ""

# Step 1: Check if cert.pem exists
print_info "Checking /root/cert.pem ..."
if [ -f "/root/cert.pem" ]; then
    print_status "cert.pem found!"
    print_info "First line of cert.pem:"
    head -1 /root/cert.pem
    echo ""
else
    print_error "cert.pem not found at /root/cert.pem"
    print_info "Please upload your certificate file to /root/cert.pem"
    exit 1
fi

# Step 2: Check if key.pem exists
print_info "Checking /root/key.pem ..."
if [ -f "/root/key.pem" ]; then
    print_status "key.pem found!"
    print_info "First line of key.pem:"
    head -1 /root/key.pem
    echo ""
else
    print_error "key.pem not found at /root/key.pem"
    print_info "Please upload your private key file to /root/key.pem"
    exit 1
fi

# Step 3: Validate certificate and key format
print_info "Validating certificate format..."
if grep -q "BEGIN CERTIFICATE" /root/cert.pem; then
    print_status "Certificate format is valid"
else
    print_error "Invalid certificate format. Missing 'BEGIN CERTIFICATE'"
    exit 1
fi

print_info "Validating private key format..."
if grep -q "BEGIN.*PRIVATE KEY" /root/key.pem; then
    print_status "Private key format is valid"
else
    print_error "Invalid private key format. Missing 'BEGIN PRIVATE KEY'"
    exit 1
fi

# Step 4: Download Cloudflare Origin CA Root Certificate
print_info "Downloading Cloudflare Origin CA Root Certificate..."
if wget -q https://developers.cloudflare.com/ssl/static/origin_ca_rsa_root.pem -O /usr/local/share/ca-certificates/cloudflare-origin-ca.crt; then
    print_status "Cloudflare Origin CA Root Certificate downloaded successfully!"
else
    print_error "Failed to download Cloudflare Origin CA Root Certificate"
    print_info "Please check your internet connection and try again"
    exit 1
fi

# Step 5: Set correct permissions
print_info "Setting file permissions..."
if chmod 644 /usr/local/share/ca-certificates/cloudflare-origin-ca.crt; then
    print_status "Permissions set to 644 successfully!"
else
    print_error "Failed to set permissions"
    exit 1
fi

# Step 6: Update system CA certificates
print_info "Updating system CA certificates..."
if update-ca-certificates 2>&1 | tee /tmp/ca-update.log; then
    print_status "CA certificates updated successfully!"
else
    print_error "Failed to update CA certificates"
    print_info "Check /tmp/ca-update.log for details"
    exit 1
fi

# Step 7: Verify installation
print_info "Verifying installation..."
if [ -f "/usr/local/share/ca-certificates/cloudflare-origin-ca.crt" ]; then
    print_status "Certificate installed at: /usr/local/share/ca-certificates/cloudflare-origin-ca.crt"
    print_status "File size: $(du -h /usr/local/share/ca-certificates/cloudflare-origin-ca.crt | cut -f1)"
else
    print_error "Certificate installation verification failed"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Installation completed successfully!${NC}"
echo "=========================================="
echo ""
print_info "Next steps:"
echo "  1. Configure your web server (Nginx/Apache/Caddy) to use:"
echo "     - Certificate: /root/cert.pem"
echo "     - Private Key: /root/key.pem"
echo "  2. Restart your web server service. Eg - systemctl restart x-ui"
echo "  3. Test your SSL configuration with: openssl s_client -connect your-domain.com:443"
echo ""
print_warning "Important: Keep your private key (/root/key.pem) secure!"
echo "=========================================="
