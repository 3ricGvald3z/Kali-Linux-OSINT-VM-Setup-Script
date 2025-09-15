#!/bin/bash

# Enhanced Kali OSINT Setup Script
# This script combines all the user's scripts into a single, cohesive script.
# It includes better error handling, logging, and a more structured approach
# to installing tools for OSINT on a fresh Kali Linux VM.

# --- Global Variables and Functions ---
LOG_FILE="/var/log/kali_osint_setup.log"
INSTALL_DIR="$HOME/programs"

# Function to log messages to the console and a log file
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        log "ERROR: The last command failed. Please check the log file ($LOG_FILE) for details."
        exit 1
    fi
}

# --- Initial Setup ---
log "Starting Kali OSINT setup..."
# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    log "Please run this script with sudo."
    exit 1
fi

# Update package lists
log "Updating package lists..."
apt update -y | tee -a "$LOG_FILE"
check_command

# --- System-wide Package Installation ---
log "Installing system-wide packages with apt..."
APT_PACKAGES="tor ufw gospider hakrawler gobuster ruby-dev ffuf seclists youtubedl-gui filezilla libreoffice httrack webhttrack sherlock eyewitness sublist3r photon recon-ng python3-venv python3-pip jq pipx snapd mediainfo-gui kali-tools-crypto-stego neovim cargo asciinema redis-tools finalrecon ugrep bloodhound bing-ip2hosts golang libxcb-cursor0 mat2 gallery-dl libimage-exiftool-perl stegosuite exifprobe ruby-bundler mpg123 thunderbird sqlite3 python3-lxml exiflooter flowblade dumpsterdiver npm freerdp2-x11 ftp smbclient mongo-tools villain"
apt install -y $APT_PACKAGES | tee -a "$LOG_FILE"
check_command

log "Purging redundant packages..."
apt purge -y spiderfoot amass theharvester | tee -a "$LOG_FILE"
check_command

log "Autoremoving unused dependencies..."
apt autoremove -y | tee -a "$LOG_FILE"
check_command

# --- MongoDB Installation ---
log "Installing and configuring MongoDB..."
# Add the MongoDB GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor | tee /etc/apt/keyrings/mongodb-org-8.0.gpg >/dev/null
check_command

# Add the MongoDB repository to the sources list
echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/keyrings/mongodb-org-8.0.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
check_command

# Update package lists again with the new repository
apt update -y | tee -a "$LOG_FILE"
check_command

# Install the MongoDB packages
apt install -y mongodb-org | tee -a "$LOG_FILE"
check_command

# Enable and start the MongoDB service
log "Enabling and starting the MongoDB service..."
systemctl enable --now mongod | tee -a "$LOG_FILE"
check_command


# --- Service Configuration ---
log "Configuring other system services..."

log "Enabling and starting UFW (Uncomplicated Firewall)..."
ufw allow ssh | tee -a "$LOG_FILE"
ufw --force enable | tee -a "$LOG_FILE"
check_command

log "Enabling and starting Snapd..."
systemctl enable --now snapd snapd.apparmor | tee -a "$LOG_FILE"
check_command

log "Enabling and starting PostgreSQL..."
systemctl enable --now postgresql | tee -a "$LOG_FILE"
check_command

log "Enabling and starting SSH..."
systemctl enable --now ssh | tee -a "$LOG_FILE"
check_command

log "Initializing Metasploit Database..."
msfdb init | tee -a "$LOG_FILE"
check_command

log "Setting up DNS configuration..."
# Make sure resolvconf is installed
apt install -y resolvconf | tee -a "$LOG_FILE"
check_command

systemctl enable --now resolvconf.service | tee -a "$LOG_FILE"
check_command
echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 1.1.1.1" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 1.0.0.1" >> /etc/resolvconf/resolv.conf.d/head
resolvconf -u
check_command
systemctl restart resolvconf.service
check_command

# --- Go Toolchain Installation ---
log "Installing Go tools..."
export GOBIN="$HOME/go/bin"
GO_TOOLS=(
    github.com/tomnomnom/waybackurls@latest
    github.com/owasp-amass/amass/v4/...@master
    github.com/tomnomnom/httprobe@master
    github.com/owasp-amass/oam-tools/cmd/...@master
    github.com/projectdiscovery/katana/cmd/katana@latest
    github.com/xxxserxxx/gotop/v4/cmd/gotop@latest
    github.com/ndelphit/apkurlgrep@latest
    github.com/davecheney/httpstat@latest
    github.com/trap-bytes/hauditor@latest
    github.com/g0ldencybersec/gungnir/cmd/gungnir@latest
    github.com/tantosec/oneshell@latest
)

for tool in "${GO_TOOLS[@]}"; do
    log "Installing $tool..."
    go install -v "$tool" | tee -a "$LOG_FILE"
    check_command
done

log "Downloading and moving gowitness..."
wget -q --show-progress https://github.com/sensepost/gowitness/releases/download/2.5.1/gowitness-2.5.1-linux-amd64 -O "$GOBIN/gowitness"
check_command
chmod +x "$GOBIN/gowitness"
check_command


# --- Language-specific and Manual Installations ---
log "Installing tools with npm, gem, snap, and cargo..."

NPM_PACKAGES="ftp-spider localtunnel"
for package in $NPM_PACKAGES; do
    log "Installing npm package: $package..."
    npm install -g "$package" | tee -a "$LOG_FILE"
    check_command
done

GEM_PACKAGES="mechanize colorize"
for package in $GEM_PACKAGES; do
    log "Installing gem package: $package..."
    gem install "$package" | tee -a "$LOG_FILE"
    check_command
done

SNAP_PACKAGES="youtube-dl-pro joplin-desktop ngrok --devmode localxpose telegram-desktop"
for package in $SNAP_PACKAGES; do
    log "Installing snap package: $package..."
    snap install "$package" | tee -a "$LOG_FILE"
    check_command
done

log "Installing aichat with cargo..."
cargo install aichat | tee -a "$LOG_FILE"
check_command

# --- Pipx and Python Venv Installations ---
log "Setting up pipx and installing Python tools..."
pipx ensurepath
check_command

# Pipx installations
PIPX_PACKAGES="ghunt socialscan holehe xeuledoc waybackpy changedetection.io archivebox internetarchive search-that-hash name-that-hash h8mail domain-stats gitem ignorant masto social-analyzer recoverpy whisper-ctranslate2 checkdmarc shodan netlas postleaks postleaksNg androguard bbot toutatis poetry"
for package in $PIPX_PACKAGES; do
    log "Installing pipx package: $package..."
    pipx install "$package" | tee -a "$LOG_FILE"
    check_command
done

# Python venv and git clone installations
log "Setting up programs directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
check_command

declare -A REPO_WITH_VENV
REPO_WITH_VENV=(
    ["Elasticsearch-Crawler"]="https://github.com/AmIJesse/Elasticsearch-Crawler.git"
    ["blackbird"]="https://github.com/p1ngul1n0/blackbird"
    ["Carbon14"]="https://github.com/Lazza/Carbon14.git"
    ["maigret"]="https://github.com/soxoj/maigret"
    ["Cr3dOv3r"]="https://github.com/D4Vinci/Cr3dOv3r.git"
    ["BridgeKeeper"]="https://github.com/0xZDH/BridgeKeeper.git"
    ["Elevate"]="https://github.com/Healdb/Elevate.git"
    ["pwnedOrNot"]="https://github.com/thewhiteh4t/pwnedOrNot.git"
    ["LittleBrother"]="https://github.com/AbirHasan2005/LittleBrother"
    ["WhatsMyName-Python"]="https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python"
    ["sherloq"]="https://github.com/GuidoBartoli/sherloq.git"
    ["spiderfoot"]="https://github.com/smicallef/spiderfoot.git"
    ["theHarvester"]="https://github.com/laramies/theHarvester.git"
    ["creepyCrawler"]="https://github.com/chm0dx/creepyCrawler.git"
    ["Eyes"]="https://github.com/N0rz3/Eyes.git"
    ["tosint"]="https://github.com/drego85/tosint.git"
)

for repo_name in "${!REPO_WITH_VENV[@]}"; do
    log "Cloning and installing $repo_name..."
    git clone "${REPO_WITH_VENV[$repo_name]}"
    cd "$repo_name"
    python3 -m venv "${repo_name}Env"
    source "${repo_name}Env/bin/activate"
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt | tee -a "$LOG_FILE"
        check_command
    elif [ -f Pipfile ]; then
        pip install -r Pipfile.lock | tee -a "$LOG_FILE"
        check_command
    elif [ "$repo_name" = "maigret" ]; then
        pip3 install . | tee -a "$LOG_FILE"
        check_command
    fi
    deactivate
    cd "$INSTALL_DIR"
done

# Special case for dpulse which uses poetry
log "Cloning and installing dpulse with poetry..."
git clone https://github.com/OSINT-TECHNOLOGIES/dpulse
cd dpulse
poetry install | tee -a "$LOG_FILE"
check_command
cd "$INSTALL_DIR"

log "Installing phoneinfoga..."
mkdir -p phoneinfoga
cd phoneinfoga
wget -q --show-progress https://github.com/sundowndev/phoneinfoga/releases/download/v2.10.8/phoneinfoga_Linux_x86_64.tar.gz -O phoneinfoga_Linux_x86_64.tar.gz
check_command
tar -xzvf phoneinfoga_Linux_x86_64.tar.gz
check_command
rm phoneinfoga_Linux_x86_64.tar.gz
cd "$INSTALL_DIR"

log "Installing gron..."
wget -q --show-progress https://github.com/tomnomnom/gron/releases/download/v0.7.1/gron-linux-amd64-0.7.1.tgz -O gron-linux-amd64-0.7.1.tgz
check_command
tar xzf gron-linux-amd64-0.7.1.tgz
check_command
rm gron-linux-amd64-0.7.1.tgz
mv gron-linux-amd64-0.7.1 "$HOME/go/bin/gron"
check_command
cd "$INSTALL_DIR"

log "Installing proxybroker2..."
python3 -m venv proxybroker2
source proxybroker2/bin/activate
pip install -U git+https://github.com/bluet/proxybroker2.git | tee -a "$LOG_FILE"
check_command
deactivate
cd "$INSTALL_DIR"

log "Installing TREAVORproxy..."
python -m venv TREAVORproxy
source TREAVORproxy/bin/activate
pip install git+https://github.com/blacklanternsecurity/trevorproxy | tee -a "$LOG_FILE"
check_command
deactivate
cd "$INSTALL_DIR"

log "Installing yt-dlp..."
mkdir -p yt-dlp
cd yt-dlp
wget -q --show-progress https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O yt-dlp
check_command
wget -q --show-progress https://github.com/yt-dlp/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-linux64-gpl.tar.xz -O ffmpeg-master-latest-linux64-gpl.tar.xz
check_command
tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz
check_command
rm ffmpeg-master-latest-linux64-gpl.tar.xz
cd "$INSTALL_DIR"

log "Downloading .deb packages..."
wget -q --show-progress https://github.com/TermuxHackz/anonphisher/releases/download/3.3.2/anonphisher_3.3.2_all.deb
check_command

log "Installing .deb packages..."
dpkg -i anonphisher_3.3.2_all.deb | tee -a "$LOG_FILE"
apt install -f -y | tee -a "$LOG_FILE" # Fix broken dependencies
check_command
rm anonphisher_3.3.2_all.deb

# --- Repository Cloning ---
log "Cloning various repositories..."
CLONE_DIRS=(
    "$HOME/resources"
    "$HOME/tor-links"
    "$HOME/.config/amass"
    "$INSTALL_DIR"
)

declare -A REPO_URLS
REPO_URLS=(
    ["$HOME/resources"]="https://github.com/swisskyrepo/InternalAllTheThings.git https://github.com/andrewjkerr/security-cheatsheets.git https://github.com/cipher387/Dorks-collections-list.git https://github.com/cipher387/osint_stuff_tool_collection.git https://github.com/ExploitXpErtz/WebCam-Google-Shodan-Dorks.git https://github.com/cipher387/cheatsheets.git https://github.com/vaib25vicky/awesome-mobile-security.git"
    ["$HOME/tor-links"]="https://github.com/01Kevin01/OnionLinksV3.git https://github.com/fastfire/deepdarkCTI.git"
    ["$HOME/.config/amass"]="https://github.com/proabiral/Fresh-Resolvers.git"
    ["$INSTALL_DIR"]="https://github.com/hatlord/Spiderpig.git https://github.com/jocephus/WikiLeaker.git https://github.com/BillyV4/ID-entify.git https://github.com/lolwaleet/ReverseIP.git https://github.com/Raikia/UhOh365.git https://github.com/HACK3RY2J/Anon-SMS.git https://github.com/MohammedAlsubhi/instashell-master.git https://github.com/4n4nk3/Wordlister.git https://github.com/netlas-io/netlas-scripts.git https://github.com/proabiral/Fresh-Resolvers.git https://github.com/schooldropout1337/lazyegg.git https://github.com/rndinfosecguy/TrashSearch.git https://github.com/asciinema/agg.git https://github.com/TermuxHackz/X-osint.git https://github.com/m3n0sd0n4ld/GooFuzz.git https://github.com/TarlogicSecurity/BlueSpy.git"
)

for dir in "${CLONE_DIRS[@]}"; do
    log "Cloning repositories into $dir..."
    mkdir -p "$dir"
    cd "$dir"
    for repo_url in ${REPO_URLS[$dir]}; do
        git clone "$repo_url" | tee -a "$LOG_FILE"
    done
    check_command
done

# --- Final Steps ---
log "Installing Ronin..."
curl -o ronin-install.sh https://raw.githubusercontent.com/ronin-rb/scripts/main/ronin-install.sh
check_command
bash ronin-install.sh | tee -a "$LOG_FILE"
check_command
rm ronin-install.sh

log "Setup complete! Please reboot the system for all changes to take effect."
log "Your go binaries and new python venv tools are located in $HOME/go/bin and $HOME/programs."
log "To use the Go tools, make sure your PATH variable includes $HOME/go/bin."
log "You can add the following line to your ~/.bashrc or ~/.zshrc:"
log "export PATH=\"$HOME/go/bin:\$PATH\""
log "Then run: source ~/.bashrc (or ~/.zshrc)"

