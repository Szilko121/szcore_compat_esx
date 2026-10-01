# 📦 szcore_compat_esx

[![SzCore Resource](https://img.shields.io/badge/SzCore-FiveM%20Resource-00f0ff?style=for-the-badge&logo=fivem&logoColor=white)](https://github.com/Szilko121/SzCore-Framework)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> Visszafelé kompatibilitási híd, amely a standard ESX exportokat és eseményeket SzCore-ra fordítja le.  
> *Seamless backwards compatibility bridge exposing standard ESX events, exports, and callbacks to SzCore.*

---

## ✨ Főbb Jellemzők (Features)
- 🚀 **Alacsony erőforráshasználat (0.00ms idle)**
- 🔒 **Szerveroldali hitelesítés és biztonsági ellenőrzések**
- 🌐 **Többnyelvűség (i18n): Magyar (HU) & Angol (EN)**
- 🧩 **Szerves integráció az SzCore ökoszisztémával**
- 🔄 **Nyílt exportok és események (Events & Callbacks)**

---

## 📋 Követelmények (Requirements)
- FiveM Server Artifacts (minimum `v5848` vagy frissebb)
- [`szcore`](https://github.com/Szilko121/szcore)
- `oxmysql`
- `ox_lib` (ajánlott)

---

## 📥 Telepítés (Installation)

1. Töltsd le vagy klónozd a repository-t a szervered `resources` mappájába:
   ```bash
   git clone https://github.com/Szilko121/szcore_compat_esx.git
   ```
2. Add hozzá a `server.cfg` konfigurációs fájlodhoz:
   ```cfg
   ensure szcore_compat_esx
   ```
3. Szükség esetén szabd testre a `config.lua` fájlban található beállításokat.

---

## 💻 Exportok & Használat (Exports)

```lua
-- Kliensoldali lekérdezés példa:
local isReady = exports['szcore_compat_esx']:isReady()

-- Szerveroldali esemény példa:
TriggerEvent('szcore_compat_esx:server:notify', source, 'Sikeres művelet!')
```

---

## 📜 Licenc
Kiadva a **MIT** licenc alatt. Részletekért lásd a `LICENSE` fájlt.
