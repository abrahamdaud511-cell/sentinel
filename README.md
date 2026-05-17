# sentinel
sentilel-security


                _   _            _         
 ___  ___ _ __ | |_(_)_ __   ___| |        
/ __|/ _ \ '_ \| __| | '_ \ / _ \ |  _____ 
\__ \  __/ | | | |_| | | | |  __/ | |_____|
|___/\___|_| |_|\__|_|_| |_|\___|_|        
 ___  ___  ___ _   _ _ __(_) |_ _   _      
/ __|/ _ \/ __| | | | '__| | __| | | |     
\__ \  __/ (__| |_| | |  | | |_| |_| |     
|___/\___|\___|\__,_|_|  |_|\__|\__, |     
                                |___/      

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

==========================
INSTALATION :
==========================

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

===========================
===========================
