#!/bin/bash

# Subnet Calculator Installer
# One-line install: curl -sSL https://raw.githubusercontent.com/mikegilkim/subnet-calculator/main/install.sh | sudo bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Subnet Calculator Installer v1.0                      ║"
echo "║         Advanced IP subnetting tool                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Install dependencies
echo -e "${BLUE}[1/3]${NC} Installing dependencies..."
if ! command -v bc &> /dev/null; then
    apt-get update -qq
    apt-get install -y bc wget > /dev/null 2>&1
    echo -e "${GREEN}✓ Installed bc${NC}"
else
    echo -e "${GREEN}✓ Dependencies already installed${NC}"
fi

# Download the calculator
echo -e "${BLUE}[2/3]${NC} Downloading subnet calculator..."

wget -q https://raw.githubusercontent.com/mikegilkim/subnet-calculator/main/subnet-calc.sh -O /usr/local/bin/subnet-calc

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Calculator downloaded${NC}"
else
    echo -e "${RED}✗ Failed to download calculator${NC}"
    exit 1
fi

# Make executable
chmod +x /usr/local/bin/subnet-calc
echo -e "${GREEN}✓ Made executable${NC}"

# Add alias
echo -e "${BLUE}[3/3]${NC} Adding 'subnet' alias..."

add_alias() {
    local file=$1
    if [ -f "$file" ]; then
        if ! grep -q "alias subnet=" "$file"; then
            echo "" >> "$file"
            echo "# Subnet Calculator alias" >> "$file"
            echo "alias subnet='/usr/local/bin/subnet-calc'" >> "$file"
            echo -e "${GREEN}  ✓ Added alias to $file${NC}"
        else
            echo -e "${YELLOW}  ⚠ Alias already exists in $file${NC}"
        fi
    fi
}

add_alias "/root/.bashrc"

for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        username=$(basename "$user_home")
        add_alias "$user_home/.bashrc"
        if grep -q "alias subnet=" "$user_home/.bashrc" 2>/dev/null; then
            chown $username:$username "$user_home/.bashrc" 2>/dev/null || true
        fi
    fi
done

if [ -f /etc/bash.bashrc ]; then
    add_alias "/etc/bash.bashrc"
fi

# Final message
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Installation Complete! 🎉 🔢                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${WHITE}To use the subnet calculator:${NC}"
echo -e "  ${CYAN}${BOLD}subnet${NC}                    (Interactive mode)"
echo -e "  ${CYAN}${BOLD}subnet 192.168.1.0/24${NC}     (Direct calculation)"
echo ""
echo -e "${YELLOW}Note: You may need to reload your shell:${NC}"
echo -e "  ${CYAN}source ~/.bashrc${NC}"
echo ""
echo -e "${WHITE}Features:${NC}"
echo -e "  📊 Complete subnet information"
echo -e "  🔢 Binary and hexadecimal representations"
echo -e "  📡 Network, broadcast, and usable IP ranges"
echo -e "  🎯 IP class and type detection"
echo -e "  📋 Subnet division examples"
echo -e "  📖 Quick reference table"
echo ""
echo -e "${GREEN}Calculate subnets like a pro! 🚀${NC}"
echo ""
