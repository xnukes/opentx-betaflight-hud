-- /SCRIPTS/BFHUD/config.lua

local C = {}

-- ===== sensor names (as shown in Telemetry -> Sensors) =====
C.SENS = {
  batt = "VFAS",   -- battery voltage
  rssi = "RSSI",   -- RSSI
  alt  = "Alt",    -- altitude
  spd  = "GSpd",   -- ground speed
  hdg  = "Hdg",    -- heading
  gps  = "GPS",    -- GPS (table with lat/lon on OpenTX)
  sats = "Tmp1",   -- satellites (often BF maps sats to Tmp1)
  -- you can later use Tmp2 for status if you want
}

-- ===== units / scaling =====
C.UNITS = {
  speed = "kmh",     -- OpenTX often already shows km/h for GSpd
  alt   = "m",
  dist  = "m",
}

-- ===== UI =====
C.UI = {
  showGrid = false,
  arrowSize = 10,
}

return C