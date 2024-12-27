# FanControl Installer
This repository contains the Inno Setup script for creating the installer of **FanControl**, a powerful and customizable fan management software by Rémi Mercier (Rem0o).  

---

## ⚠ Important Notice  
**FanControl must be run as Administrator at least once after installation** to complete its setup and ensure proper functionality.

---

## Features
- **Multi-Mode Installation**: Choose between User and System-wide installation modes.
- **2-in-1 .NET Version Support**: Options for .NET 4.8 (Legacy) and .NET 8.0.
- **Automatic**: Fetches the latest version of FanControl during installation.
- **User Data Cleanup**: Option to remove all user-generated files during uninstallation.

---

## Usage

Download the latest installer from the [Releases page](https://github.com/archead/FanControl.Installer/releases/latest) and run it to install FanControl.  

---

## Build Instructions

### 1. Prerequisites
- [Inno Setup](https://jrsoftware.org/isdl.php) installed on your system.
- Internet access for downloading the latest FanControl releases.

### 2. Build the Installer
1. Clone the repository:
   ```bash
   https://github.com/archead/FanControl.Installer.git
   ```
2. Open `src/installer.iss` in the Inno Setup Compiler.
3. Click **Compile** to generate the installer.

---

## Installation Options

### Modes
- **Basic Mode**: Default options for a quick setup.
- **Advanced Mode**: Allows customization of installation directories, .NET version, and more.

### Types
- **Default**: Latest FanControl with .NET 8.0.
- **Custom**: Choose between .NET 4.8 or 8.0.

---

## Uninstallation
The uninstaller ensures that:
1. FanControl is not running.
2. You can opt to delete user-generated files (e.g., configuration, logs).

---
## TODO
- Fully automate the uninstallation process.
- Ensure first launch is with admin privileges.

---

## Contributing
Feel free to fork and contribute to improve the installer. Issues and pull requests are welcome.

---

## License ![lgplv3-88x31](https://github.com/user-attachments/assets/016bf4f6-c787-44e6-ba79-d3928a7a0d75)

This project is licensed under the **GPLv3**. See the [LICENSE](https://github.com/archead/FanControl.Installer/blob/master/LICENSE) file for details.

---

**FanControl**  
By [Rémi Mercier (Rem0o)](https://github.com/Rem0o)  
Visit [FanControl Website](https://getfancontrol.com) for more details.
