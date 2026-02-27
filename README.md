# BF HUD by ITWOLF

**Betaflight-style GPS HUD for OpenTX / EdgeTX radios (FrSky F.Port compatible)**

Custom telemetry Lua script that displays a clean, Betaflight-inspired HUD directly on your transmitter screen.
Designed and tested on **FrSky X-Lite + R9M (F.Port) + Betaflight GPS**, but works with any OpenTX/EdgeTX radio providing standard telemetry sensors.

---

## ✨ Features

* 🧭 **Home arrow** (points toward recorded Home position)
* 📏 **Distance to Home** (meters / kilometers)
* 🌍 **GPS coordinates display** (LAT / LON)
* 🛰 **Satellite count**
* 📡 **RSSI**
* 🔋 **Battery voltage (VFAS)**
* 🧭 **Heading**
* 🧪 **Debug mode** (raw telemetry inspection)
* 📄 **Multiple pages**
* 🎮 **Joystick-based control**
* ⚡ Fully compatible with **FrSky SmartPort / F.Port telemetry**
* 🧩 Modular architecture (multiple Lua modules)

No MSP required. No special Betaflight build required.

---

## 📷 HUD Overview

**Page 1 — Main HUD**

Shows:

* ALT
* Speed
* Satellites
* RSSI
* Battery voltage
* Distance to Home
* Home arrow
* GPS status

**Page 2 — GPS Detail**

Shows:

* GPS Fix status
* Latitude
* Longitude
* Satellite count
* Distance to Home

**Page 3 — Status / Raw telemetry**

Shows:

* Tmp2 status value (useful for Rescue/Failsafe detection)
* GPS state
* Home state

**Debug Mode**

Shows raw sensor values for troubleshooting and calibration.

---

## 🎮 Controls (FrSky X-Lite / OpenTX D-Pad)

| Action        | Function            |
| ------------- | ------------------- |
| Right (short) | Next page           |
| Down (short)  | Next page           |
| Right (long)  | Set Home position   |
| Left (long)   | Clear Home position |
| Up (long)     | Toggle Debug mode   |

---

## 📂 Installation

Copy files to your radio SD card:

```
/SCRIPTS/TELEMETRY/BFHUD.lua

/SCRIPTS/BFHUD/config.lua
/SCRIPTS/BFHUD/sensors.lua
/SCRIPTS/BFHUD/math.lua
/SCRIPTS/BFHUD/ui.lua
```

---

## ⚙️ Enable Script in OpenTX / EdgeTX

On your radio:

```
MENU
PAGE → Telemetry
Screen
Type → Script
Select → BFHUD
```

---

## 📡 Required Betaflight Telemetry Sensors

Typical Betaflight → FrSky sensor mapping:

| Sensor | Purpose                   |
| ------ | ------------------------- |
| VFAS   | Battery voltage           |
| RSSI   | Signal strength           |
| Alt    | Altitude                  |
| GSpd   | Ground speed              |
| Hdg    | Heading                   |
| GPS    | Coordinates               |
| Tmp1   | Satellite count (usually) |
| Tmp2   | Status / spare channel    |

Verify using:

```
Telemetry → Discover new sensors
```

---

## 🧭 Setting Home Position

Recommended workflow:

1. Power drone
2. Wait for GPS fix (≥ 8 satellites recommended)
3. Arm and disarm once (Betaflight sets its home)
4. Long press RIGHT on joystick → sets radio Home

---

## 🧪 Debug Mode

Long press UP to enter Debug mode.

Displays:

* Raw telemetry values
* Satellite source
* Tmp2 status value

Useful for:

* Rescue detection mapping
* Sensor troubleshooting
* Telemetry validation

---

## 🧠 How Home Arrow Works

Uses:

* GPS coordinates
* Heading sensor
* Haversine distance calculation
* Bearing correction

No magnetometer required.

---

## 🧩 Compatibility

Tested with:

* OpenTX 2.3+
* EdgeTX 2.6+
* FrSky X-Lite
* FrSky R9M / F.Port
* Betaflight 4.x
* GPS modules (DJI, BN-220, M10, etc.)

Works with most radios supporting Lua telemetry scripts:

* X-Lite
* QX7
* X9D
* TX16S
* Boxer
* etc.

---

## ⚠️ Limitations

FrSky telemetry does NOT directly transmit:

* Flight mode name
* Rescue active flag (without decoding Tmp channels)
* Armed state (reliably)

Debug page helps identify usable signals.

ELRS / CRSF provides richer telemetry.

---

## 🔧 Customization

Edit:

```
/SCRIPTS/BFHUD/config.lua
```

Example:

```
batt = "VFAS"
satsPrimary = "Tmp1"
```

Adjust if your sensors use different names.

---

## 🛠 Troubleshooting

**No GPS data**

Ensure:

```
Betaflight → GPS enabled
Telemetry → Discover sensors
```

**Arrow incorrect**

Verify heading sensor is present:

```
Hdg sensor must exist
```

**No satellites**

Check Tmp1 / Tmp2 values in Debug mode.

---

## 📜 License

Free for personal and commercial use.

---

## 👤 Author

**ITWOLF**

Custom Betaflight telemetry HUD
Built for FrSky pilots who refuse to upgrade to ELRS 😄

---
