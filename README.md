# 🔢 Advanced Subnet Calculator

Professional IP subnetting calculator in your terminal. Fast, accurate, and beautiful.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/mikegilkim/subnet-calculator/main/install.sh | sudo bash
```

## Usage

**Interactive Mode:**
```bash
subnet
```

**Direct Calculation:**
```bash
subnet 192.168.1.0/24
subnet 10.0.0.0/8
subnet 172.16.0.0/16
```

## Features

### 📊 Complete Network Information
- Network address and broadcast address
- Subnet mask and wildcard mask
- CIDR notation
- Usable IP range (first and last)
- Total IPs and usable hosts

### 🎯 IP Analysis
- **IP Class Detection** (A, B, C, D, E)
- **IP Type** (Private vs Public)
- Identifies RFC1918 private ranges

### 🔢 Multiple Representations
- **Decimal** - Standard dotted notation
- **Binary** - 8-bit octet format
- **Hexadecimal** - For network programming

### 📋 Subnet Division
- Shows how to divide into smaller subnets
- Lists up to 8 example subnets
- Includes usable ranges for each

### 📖 Quick Reference Table
- Common CIDR notations (/24 to /32)
- Subnet masks for each
- Total IPs and usable hosts

## Screenshot

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                      SUBNET CALCULATOR RESULTS                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

▶ INPUT
────────────────────────────────────────────────────────────────────────────────
  IP Address / CIDR:        192.168.1.0/24

▶ IP ADDRESS INFORMATION
────────────────────────────────────────────────────────────────────────────────
  IP Class:                 C (Small Networks)
  IP Type:                  Yes (192.168.0.0/16)

▶ NETWORK INFORMATION
────────────────────────────────────────────────────────────────────────────────
  Network Address:          192.168.1.0
  Broadcast Address:        192.168.1.255
  Subnet Mask:              255.255.255.0
  Wildcard Mask:            0.0.0.255
  CIDR Notation:            /24

▶ USABLE IP RANGE
────────────────────────────────────────────────────────────────────────────────
  First Usable IP:          192.168.1.1
  Last Usable IP:           192.168.1.254
  Total IP Addresses:       256
  Usable Hosts:             254

▶ BINARY REPRESENTATION
────────────────────────────────────────────────────────────────────────────────
  IP Address (Binary):      11000000.10101000.00000001.00000000
  Subnet Mask (Binary):     11111111.11111111.11111111.00000000
  Network Address (Binary): 11000000.10101000.00000001.00000000

▶ SUBNET DIVISION EXAMPLES
────────────────────────────────────────────────────────────────────────────────
  Divide /24 into /25 subnets:

  Subnet 1: 192.168.1.0/25
    Range: 192.168.1.1 - 192.168.1.126

  Subnet 2: 192.168.1.128/25
    Range: 192.168.1.129 - 192.168.1.254
```

## Use Cases

Perfect for:
- 🌐 **Network Engineers** - Plan subnet allocations
- 🎓 **Students** - Learn subnetting concepts
- 🔧 **System Administrators** - Quick network calculations
- 📝 **CCNA/Network+ Prep** - Practice subnetting
- 🏢 **IT Professionals** - Network design and troubleshooting

## Requirements

- Linux (Ubuntu, Debian, CentOS, RHEL, Arch)
- Bash 4.0+
- bc (auto-installed)

## Examples

### Calculate Class C Network
```bash
subnet 192.168.1.0/24
```
Shows 256 total IPs, 254 usable hosts

### Calculate Class A Network
```bash
subnet 10.0.0.0/8
```
Shows 16,777,216 total IPs

### Calculate Small Subnet
```bash
subnet 192.168.1.0/30
```
Shows point-to-point links (2 usable hosts)

### Calculate Single Host
```bash
subnet 192.168.1.1/32
```
Shows single host subnet

## Manual Install

```bash
wget https://raw.githubusercontent.com/mikegilkim/subnet-calculator/main/subnet-calc.sh
chmod +x subnet-calc.sh
sudo mv subnet-calc.sh /usr/local/bin/subnet-calc
echo "alias subnet='/usr/local/bin/subnet-calc'" >> ~/.bashrc
source ~/.bashrc
```

## Understanding the Output

### Network Address
The first address in the subnet. Cannot be assigned to hosts.

### Broadcast Address
The last address in the subnet. Used to send messages to all hosts.

### Usable IP Range
IPs between network and broadcast that can be assigned to devices.

### Subnet Mask
Defines which portion of IP is network vs host.

### Wildcard Mask
Inverse of subnet mask. Used in access control lists (ACLs).

### CIDR Notation
Compact way to represent subnet mask (/24 = 255.255.255.0).

## Common CIDR Notations

| CIDR | Subnet Mask     | Usable Hosts | Common Use        |
|------|-----------------|--------------|-------------------|
| /8   | 255.0.0.0       | 16,777,214   | Large enterprise  |
| /16  | 255.255.0.0     | 65,534       | Medium enterprise |
| /24  | 255.255.255.0   | 254          | Small network     |
| /25  | 255.255.255.128 | 126          | Small subnet      |
| /26  | 255.255.255.192 | 62           | Smaller subnet    |
| /27  | 255.255.255.224 | 30           | Tiny subnet       |
| /28  | 255.255.255.240 | 14           | Very small        |
| /29  | 255.255.255.248 | 6            | Point-to-multipoint |
| /30  | 255.255.255.252 | 2            | Point-to-point    |
| /31  | 255.255.255.254 | 2            | Point-to-point (RFC3021) |
| /32  | 255.255.255.255 | 1            | Single host       |

## Private IP Ranges (RFC1918)

- **10.0.0.0/8** - 10.0.0.0 to 10.255.255.255
- **172.16.0.0/12** - 172.16.0.0 to 172.31.255.255
- **192.168.0.0/16** - 192.168.0.0 to 192.168.255.255

## Tips & Tricks

**Quick Class C Subnetting:**
```bash
subnet 192.168.1.0/24   # 254 hosts
subnet 192.168.1.0/25   # 126 hosts (2 subnets)
subnet 192.168.1.0/26   # 62 hosts (4 subnets)
subnet 192.168.1.0/27   # 30 hosts (8 subnets)
```

**Point-to-Point Links:**
```bash
subnet 10.0.0.0/30      # 2 usable IPs for router links
```

**Verify Your Network Design:**
```bash
subnet 172.16.0.0/22    # Check if your allocation fits
```

## Troubleshooting

**"bc: command not found"**
```bash
sudo apt install bc -y
```

**"Permission denied"**
```bash
sudo subnet 192.168.1.0/24
```

**"Invalid IP address"**
- Check format: must be X.X.X.X/Y
- Octets must be 0-255
- CIDR must be 0-32

## License

MIT - Use freely, modify as needed.

## Related Tools

- [OpenVPN Monitor](https://github.com/mikegilkim/openvpn-monitor) - VPN connection monitoring
- [System Monitor](https://github.com/mikegilkim/sysmon-dashboard) - Server resource monitoring
- [Fail2ban Dashboard](https://github.com/mikegilkim/fail2ban-dashboard) - Security monitoring
