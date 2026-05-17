# sentinel
sentilel-security


# SENTINEL - SECURITY

✅ Auto-detection - Automatically detects Termux/Linux
✅ No Root (Termux) - Runs without root access in Termux
✅ Root Support (Linux) - Uses full root access on Linux
✅ Background Daemon - 24/7 monitoring
✅ Multi-Module - 10+ security modules
✅ Real-time Alerts - Instant notifications
✅ Low Resource - Lightweight and efficient
✅ Encrypted Config - Encrypted configuration
✅ Game Security - Anti-cheat for games
✅ Keyboard Protection - Keylogger detection

Sentinel - This security app is suitable for Android (via Termux), runs in the background, and is supported on Linux distributions such as Kali Linux, Debian, etc.


INSTALATION :

# Install
cd ~
git clone <repo-url> sentinel

cd sentinel

chmod +x install.sh sentinel daemon.sh

chmod +x modules/*.sh core/*.sh

# Start monitoring
./sentinel start

# Check status
./sentinel status

# Run scan
./sentinel scan all

./sentinel scan malware

./sentinel scan remote

# Stop
./sentinel stop

# View logs
./sentinel logs 100
