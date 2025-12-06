#!/bin/bash

# Advanced Subnet Calculator
# Beautiful and comprehensive IP subnetting tool

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# Box drawing
TL='╔'
TR='╗'
BL='╚'
BR='╝'
H='═'
V='║'

print_line() {
    local width=$1
    local char=$2
    printf "${char}%.0s" $(seq 1 $width)
}

print_header() {
    local text="$1"
    local width=80
    local text_len=${#text}
    local padding=$(( (width - text_len - 2) / 2 ))
    
    echo -e "${CYAN}${TL}$(print_line $((width-2)) $H)${TR}${NC}"
    printf "${CYAN}${V}${NC}"
    printf "%*s" $padding
    echo -ne "${WHITE}${BOLD}${text}${NC}"
    printf "%*s" $((width - text_len - padding - 2))
    echo -e "${CYAN}${V}${NC}"
    echo -e "${CYAN}${BL}$(print_line $((width-2)) $H)${BR}${NC}"
}

print_section() {
    local text="$1"
    echo ""
    echo -e "${YELLOW}${BOLD}▶ ${text}${NC}"
    echo -e "${YELLOW}$(print_line 80 '─')${NC}"
}

print_field() {
    local label="$1"
    local value="$2"
    local color="${3:-$CYAN}"
    printf "  ${WHITE}%-25s${NC} ${color}%s${NC}\n" "$label:" "$value"
}

# Convert IP to decimal
ip_to_decimal() {
    local ip=$1
    local IFS=.
    local -a octets=($ip)
    echo $(( (${octets[0]} << 24) + (${octets[1]} << 16) + (${octets[2]} << 8) + ${octets[3]} ))
}

# Convert decimal to IP
decimal_to_ip() {
    local decimal=$1
    echo "$(( (decimal >> 24) & 255 )).$(( (decimal >> 16) & 255 )).$(( (decimal >> 8) & 255 )).$(( decimal & 255 ))"
}

# Convert IP to binary
ip_to_binary() {
    local ip=$1
    local IFS=.
    local -a octets=($ip)
    local binary=""
    for octet in "${octets[@]}"; do
        binary+=$(printf "%08d" $(echo "obase=2; $octet" | bc))
    done
    echo "$binary"
}

# Format binary for display
format_binary() {
    local binary=$1
    echo "${binary:0:8}.${binary:8:8}.${binary:16:8}.${binary:24:8}"
}

# Get CIDR from netmask
netmask_to_cidr() {
    local netmask=$1
    local binary=$(ip_to_binary $netmask)
    echo "${binary//0/}" | wc -c
    echo $(($(echo "${binary//0/}" | wc -c) - 1))
}

# Get netmask from CIDR
cidr_to_netmask() {
    local cidr=$1
    local mask=""
    for ((i=0; i<32; i++)); do
        if [ $i -lt $cidr ]; then
            mask+="1"
        else
            mask+="0"
        fi
    done
    local dec1=$((2#${mask:0:8}))
    local dec2=$((2#${mask:8:8}))
    local dec3=$((2#${mask:16:8}))
    local dec4=$((2#${mask:24:8}))
    echo "$dec1.$dec2.$dec3.$dec4"
}

# Calculate wildcard mask
get_wildcard() {
    local netmask=$1
    local IFS=.
    local -a octets=($netmask)
    echo "$((255 - ${octets[0]})).$((255 - ${octets[1]})).$((255 - ${octets[2]})).$((255 - ${octets[3]}))"
}

# Get IP class
get_ip_class() {
    local first_octet=$(echo $1 | cut -d. -f1)
    if [ $first_octet -ge 1 ] && [ $first_octet -le 126 ]; then
        echo "A (Large Networks)"
    elif [ $first_octet -ge 128 ] && [ $first_octet -le 191 ]; then
        echo "B (Medium Networks)"
    elif [ $first_octet -ge 192 ] && [ $first_octet -le 223 ]; then
        echo "C (Small Networks)"
    elif [ $first_octet -ge 224 ] && [ $first_octet -le 239 ]; then
        echo "D (Multicast)"
    elif [ $first_octet -ge 240 ] && [ $first_octet -le 255 ]; then
        echo "E (Experimental)"
    else
        echo "Invalid"
    fi
}

# Check if IP is private
is_private_ip() {
    local ip=$1
    local first=$(echo $ip | cut -d. -f1)
    local second=$(echo $ip | cut -d. -f2)
    
    if [ $first -eq 10 ]; then
        echo "Yes (10.0.0.0/8)"
    elif [ $first -eq 172 ] && [ $second -ge 16 ] && [ $second -le 31 ]; then
        echo "Yes (172.16.0.0/12)"
    elif [ $first -eq 192 ] && [ $second -eq 168 ]; then
        echo "Yes (192.168.0.0/16)"
    else
        echo "No (Public IP)"
    fi
}

# Validate IP
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        local IFS=.
        local -a octets=($ip)
        for octet in "${octets[@]}"; do
            if [ $octet -lt 0 ] || [ $octet -gt 255 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Main calculation
calculate_subnet() {
    local ip=$1
    local cidr=$2
    
    clear
    print_header "SUBNET CALCULATOR RESULTS"
    
    # Basic Information
    print_section "INPUT"
    print_field "IP Address / CIDR" "$ip/$cidr" "$GREEN"
    
    # Calculate netmask
    local netmask=$(cidr_to_netmask $cidr)
    local wildcard=$(get_wildcard $netmask)
    
    # Convert to decimal for calculations
    local ip_dec=$(ip_to_decimal $ip)
    local mask_dec=$(ip_to_decimal $netmask)
    
    # Calculate network address
    local network_dec=$((ip_dec & mask_dec))
    local network_ip=$(decimal_to_ip $network_dec)
    
    # Calculate broadcast address
    local wildcard_dec=$(ip_to_decimal $wildcard)
    local broadcast_dec=$((network_dec | wildcard_dec))
    local broadcast_ip=$(decimal_to_ip $broadcast_dec)
    
    # Calculate first and last usable IPs
    local first_ip=$(decimal_to_ip $((network_dec + 1)))
    local last_ip=$(decimal_to_ip $((broadcast_dec - 1)))
    
    # Calculate number of hosts
    local total_ips=$((2 ** (32 - cidr)))
    local usable_hosts=$((total_ips - 2))
    
    # IP Class and Type
    print_section "IP ADDRESS INFORMATION"
    print_field "IP Class" "$(get_ip_class $ip)" "$MAGENTA"
    print_field "IP Type" "$(is_private_ip $ip)" "$BLUE"
    
    # Network Information
    print_section "NETWORK INFORMATION"
    print_field "Network Address" "$network_ip" "$GREEN"
    print_field "Broadcast Address" "$broadcast_ip" "$RED"
    print_field "Subnet Mask" "$netmask" "$CYAN"
    print_field "Wildcard Mask" "$wildcard" "$YELLOW"
    print_field "CIDR Notation" "/$cidr" "$MAGENTA"
    
    # Usable IP Range
    print_section "USABLE IP RANGE"
    print_field "First Usable IP" "$first_ip" "$GREEN"
    print_field "Last Usable IP" "$last_ip" "$GREEN"
    print_field "Total IP Addresses" "$total_ips" "$CYAN"
    if [ $usable_hosts -gt 0 ]; then
        print_field "Usable Hosts" "$usable_hosts" "$CYAN"
    else
        print_field "Usable Hosts" "0 (Point-to-Point)" "$RED"
    fi
    
    # Binary Representation
    print_section "BINARY REPRESENTATION"
    print_field "IP Address (Binary)" "$(format_binary $(ip_to_binary $ip))" "$GRAY"
    print_field "Subnet Mask (Binary)" "$(format_binary $(ip_to_binary $netmask))" "$GRAY"
    print_field "Network Address (Binary)" "$(format_binary $(ip_to_binary $network_ip))" "$GRAY"
    
    # Hexadecimal Representation
    print_section "HEXADECIMAL REPRESENTATION"
    local IFS=.
    local -a ip_octets=($ip)
    local hex_ip=$(printf "%02X.%02X.%02X.%02X" ${ip_octets[0]} ${ip_octets[1]} ${ip_octets[2]} ${ip_octets[3]})
    print_field "IP Address (Hex)" "$hex_ip" "$GRAY"
    
    # Subnet Division Examples
    if [ $cidr -lt 30 ]; then
        print_section "SUBNET DIVISION EXAMPLES"
        
        # Show how to divide into smaller subnets
        local next_cidr=$((cidr + 1))
        echo -e "  ${WHITE}Divide /${cidr} into /${next_cidr} subnets:${NC}"
        echo ""
        
        local subnets_count=$((2 ** (next_cidr - cidr)))
        local subnet_size=$((2 ** (32 - next_cidr)))
        
        local count=0
        local current_network=$network_dec
        
        while [ $count -lt $subnets_count ] && [ $count -lt 8 ]; do
            local subnet_addr=$(decimal_to_ip $current_network)
            local subnet_broadcast=$(decimal_to_ip $((current_network + subnet_size - 1)))
            local subnet_first=$(decimal_to_ip $((current_network + 1)))
            local subnet_last=$(decimal_to_ip $((current_network + subnet_size - 2)))
            
            echo -e "  ${CYAN}Subnet $((count + 1)):${NC} ${GREEN}$subnet_addr/$next_cidr${NC}"
            echo -e "    Range: ${GRAY}$subnet_first - $subnet_last${NC}"
            echo ""
            
            current_network=$((current_network + subnet_size))
            count=$((count + 1))
        done
        
        if [ $subnets_count -gt 8 ]; then
            echo -e "  ${GRAY}... and $((subnets_count - 8)) more subnets${NC}"
            echo ""
        fi
    fi
    
    # Quick Reference
    print_section "QUICK REFERENCE"
    echo ""
    printf "  ${WHITE}%-8s %-20s %-15s %s${NC}\n" "CIDR" "Subnet Mask" "Total IPs" "Usable Hosts"
    echo -e "  ${WHITE}$(print_line 78 '─')${NC}"
    
    local common_cidrs=(24 25 26 27 28 29 30 31 32)
    for c in "${common_cidrs[@]}"; do
        local mask=$(cidr_to_netmask $c)
        local total=$((2 ** (32 - c)))
        local usable=$((total - 2))
        if [ $c -eq 31 ]; then
            usable=2
        elif [ $c -eq 32 ]; then
            usable=1
        fi
        
        if [ $c -eq $cidr ]; then
            printf "  ${GREEN}%-8s %-20s %-15s %s${NC}\n" "/$c" "$mask" "$total" "$usable"
        else
            printf "  ${GRAY}%-8s %-20s %-15s %s${NC}\n" "/$c" "$mask" "$total" "$usable"
        fi
    done
    
    # Footer
    echo ""
    echo -e "${CYAN}$(print_line 80 '═')${NC}"
    echo -e "${WHITE}  Professional subnet calculations  |  Run ${CYAN}subnet${WHITE} to calculate again${NC}"
    echo -e "${CYAN}$(print_line 80 '═')${NC}"
    echo ""
    echo -e "${CYAN}                        ╔══════════════════════════════╗${NC}"
    echo -e "${CYAN}                        ║${NC} ${BOLD}${MAGENTA}★${NC} ${BOLD}${WHITE}Created by${NC} ${BOLD}${CYAN}mikegilkim${NC} ${BOLD}${MAGENTA}★${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}                        ║${NC}   ${BLUE}facebook.com/mikegilkim${NC}   ${CYAN}║${NC}"
    echo -e "${CYAN}                        ╚══════════════════════════════╝${NC}"
    echo ""
}

# Interactive mode
interactive_mode() {
    clear
    print_header "ADVANCED SUBNET CALCULATOR"
    
    echo ""
    echo -e "${WHITE}Enter IP address and CIDR notation${NC}"
    echo -e "${GRAY}Examples: 192.168.1.0/24, 10.0.0.0/8, 172.16.0.0/16${NC}"
    echo ""
    
    read -p "$(echo -e ${CYAN}IP/CIDR: ${NC})" input
    
    # Parse input
    if [[ $input =~ ^([0-9\.]+)/([0-9]+)$ ]]; then
        local ip="${BASH_REMATCH[1]}"
        local cidr="${BASH_REMATCH[2]}"
        
        # Validate IP
        if ! validate_ip "$ip"; then
            echo ""
            echo -e "${RED}Error: Invalid IP address format${NC}"
            echo ""
            exit 1
        fi
        
        # Validate CIDR
        if [ $cidr -lt 0 ] || [ $cidr -gt 32 ]; then
            echo ""
            echo -e "${RED}Error: CIDR must be between 0 and 32${NC}"
            echo ""
            exit 1
        fi
        
        calculate_subnet "$ip" "$cidr"
    else
        echo ""
        echo -e "${RED}Error: Invalid format. Use IP/CIDR notation (e.g., 192.168.1.0/24)${NC}"
        echo ""
        exit 1
    fi
}

# Check command line arguments
if [ $# -eq 0 ]; then
    interactive_mode
elif [ $# -eq 1 ]; then
    input=$1
    if [[ $input =~ ^([0-9\.]+)/([0-9]+)$ ]]; then
        ip="${BASH_REMATCH[1]}"
        cidr="${BASH_REMATCH[2]}"
        
        if ! validate_ip "$ip"; then
            echo -e "${RED}Error: Invalid IP address${NC}"
            exit 1
        fi
        
        if [ $cidr -lt 0 ] || [ $cidr -gt 32 ]; then
            echo -e "${RED}Error: CIDR must be between 0 and 32${NC}"
            exit 1
        fi
        
        calculate_subnet "$ip" "$cidr"
    else
        echo -e "${RED}Error: Invalid format. Use IP/CIDR notation${NC}"
        echo -e "${WHITE}Usage: subnet 192.168.1.0/24${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: Too many arguments${NC}"
    echo -e "${WHITE}Usage: subnet [IP/CIDR]${NC}"
    echo -e "${WHITE}Example: subnet 192.168.1.0/24${NC}"
    exit 1
fi
