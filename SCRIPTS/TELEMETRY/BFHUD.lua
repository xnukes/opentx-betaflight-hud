-- /SCRIPTS/TELEMETRY/BFHUD.lua

local CFG  = loadScript("/SCRIPTS/BFHUD/config.lua")()
local SENS = loadScript("/SCRIPTS/BFHUD/sensors.lua")()
local MATH = loadScript("/SCRIPTS/BFHUD/math.lua")()
local UI   = loadScript("/SCRIPTS/BFHUD/ui.lua")()

local homeLat, homeLon = nil, nil

-- Pages: 1 HUD, 2 GPS, 3 STATUS
local page = 1
local maxPage = 3

-- Debug toggle (long UP)
local debugOn = false
local prevPage = 1

local msg, msgUntil = nil, 0
local function toast(t, ticks)
  msg = t
  msgUntil = getTime() + (ticks or 140)
end

local function setHome(d)
  if d.gpsOk then
    homeLat, homeLon = d.lat, d.lon
    toast("HOME SET", 160)
  else
    toast("NO GPS", 160)
  end
end

local function clearHome()
  homeLat, homeLon = nil, nil
  toast("HOME CLR", 160)
end

local function nextPage()
  page = page + 1
  if page > maxPage then page = 1 end
end

local function drawHeader(W)
  -- “krasny header” v rámci OpenTX možností (inverzní bar)
  lcd.drawText(1, 1, "BF HUD by ITWOLF", INVERS)
  -- drobný page indicator vpravo (není v INVERS aby byl čitelnej)
  lcd.drawText(W - 1, 1, "Pg " .. page .. "/" .. maxPage, RIGHT)
end

-- Optional bit test (works if status is numeric)
local function bitIsSet(x, bit)
  if type(x) ~= "number" then return false end
  return (math.floor(x / (2 ^ bit)) % 2) == 1
end

local function run(event)
  local W, H = LCD_W, LCD_H
  local d = SENS.read(CFG)

  -- ===== Controls (X-Lite D-pad) =====
  -- Page: DOWN or RIGHT (short)
  if event == EVT_RIGHT_BREAK or event == EVT_DOWN_BREAK then
    if not debugOn then
      nextPage()
    else
      toast("DEBUG", 100)
    end
  end

  -- Long RIGHT = set home
  if event == EVT_RIGHT_LONG then
    setHome(d); killEvents(event)
  end

  -- Long LEFT = clear home
  if event == EVT_LEFT_LONG then
    clearHome(); killEvents(event)
  end

  -- Long UP = toggle debug
  if event == EVT_UP_LONG then
    debugOn = not debugOn
    if debugOn then
      prevPage = page
      toast("DEBUG ON", 160)
    else
      page = prevPage or 1
      toast("DEBUG OFF", 160)
    end
    killEvents(event)
  end

  -- ===== Common calculations =====
  local dist, rel = nil, nil
  if homeLat and homeLon and d.gpsOk then
    dist = MATH.haversine_m(homeLat, homeLon, d.lat, d.lon)
    local bearing = MATH.bearing_deg(d.lat, d.lon, homeLat, homeLon) -- craft -> home
    if type(d.hdg) == "number" and bearing then
      rel = MATH.wrap360(bearing - d.hdg)
    end
  end

  -- ===== Render =====
  lcd.clear()
  drawHeader(W)

  -- top-right battery in invers bar area (nice and consistent)
  lcd.drawText(W - 1, 1, UI.fmt(d.batt, "V", 1), RIGHT + INVERS)

  -- ===== DEBUG overlay page (toggle) =====
  if debugOn then
    lcd.drawText(1, 14, "DEBUG RAW:", 0)
    lcd.drawText(1, 24, "VFAS " .. UI.fmt(d.batt, "V", 1), 0)
    lcd.drawText(1, 34, "RSSI " .. UI.fmt(d.rssi, "", 0), 0)
    lcd.drawText(1, 44, "Alt  " .. UI.fmt(d.alt, "m", 0), 0)
    lcd.drawText(1, 54, "GSpd " .. UI.fmt(d.spd, "", 0), 0)

    local src = d.satsSrc or "-"
    lcd.drawText(70, 44, "SAT(" .. src .. ") " .. UI.fmt(d.sats, "", 0), 0)
    lcd.drawText(70, 54, "Tmp2 " .. UI.fmt(d.status, "", 0), 0)

    lcd.drawText(W - 1, H - 10, "UP=exit", RIGHT + SMLSIZE)

    if msg and getTime() <= msgUntil then
      lcd.drawText(math.floor(W/2), 52, msg, CENTER + INVERS)
    end
    return 0
  end

  -- ===== Page 1: HUD =====
  if page == 1 then
    lcd.drawText(1, 14, "ALT", 0)
    lcd.drawText(30, 14, UI.fmt(d.alt, "m", 0), 0)

    lcd.drawText(1, 26, "SPD", 0)
    lcd.drawText(30, 26, UI.fmt(d.spd, "", 0), 0)

    lcd.drawText(1, 38, "SAT", 0)
    lcd.drawText(30, 38, UI.fmt(d.sats, "", 0), 0)

    lcd.drawText(W - 1, 14, "RSSI " .. UI.fmt(d.rssi, "", 0), RIGHT)

    if dist then
      local t = (dist >= 1000) and string.format("%.2fkm", dist/1000) or string.format("%dm", dist)
      lcd.drawText(W - 1, 26, "HOME " .. t, RIGHT)
    else
      lcd.drawText(W - 1, 26, "HOME --", RIGHT)
    end

    lcd.drawText(W - 1, 38, "HDG " .. UI.fmt(d.hdg, "", 0), RIGHT)

    local cx, cy = math.floor(W / 2), H - 14
    UI.drawArrow(cx, cy, rel, CFG.UI.arrowSize)

    lcd.drawText(cx, H - 10, d.gpsOk and "GPS OK" or "NO GPS", CENTER + SMLSIZE)
    lcd.drawText(1, H - 10, (homeLat and homeLon) and "H:SET" or "H:--", SMLSIZE)

  -- ===== Page 2: GPS detail =====
  elseif page == 2 then
    lcd.drawText(1, 14, "GPS", 0)
    lcd.drawText(30, 14, d.gpsOk and "OK" or "NO", 0)

    lcd.drawText(1, 26, "LAT", 0)
    lcd.drawText(30, 26, d.gpsOk and string.format("%.5f", d.lat) or "--", 0)

    lcd.drawText(1, 38, "LON", 0)
    lcd.drawText(30, 38, d.gpsOk and string.format("%.5f", d.lon) or "--", 0)

    lcd.drawText(1, 50, "SAT", 0)
    lcd.drawText(30, 50, UI.fmt(d.sats, "", 0), 0)

    if dist then
      local t = (dist >= 1000) and string.format("%.2fkm", dist/1000) or string.format("%dm", dist)
      lcd.drawText(W - 1, 50, "HOME " .. t, RIGHT)
    else
      lcd.drawText(W - 1, 50, "HOME --", RIGHT)
    end

  -- ===== Page 3: STATUS / RESCUE =====
  elseif page == 3 then
    lcd.drawText(1, 14, "STATUS", 0)

    -- Always show raw status channel (safe, compatible)
    lcd.drawText(1, 26, "Tmp2", 0)
    lcd.drawText(30, 26, UI.fmt(d.status, "", 0), 0)

    -- GPS + Home presence
    lcd.drawText(1, 38, "GPS", 0)
    lcd.drawText(30, 38, d.gpsOk and "OK" or "NO", 0)

    lcd.drawText(1, 50, "HOME", 0)
    lcd.drawText(30, 50, (homeLat and homeLon) and "SET" or "--", 0)

    -- Optional bit interpretation (only if enabled in config)
    if CFG.STATUS_BITS and CFG.STATUS_BITS.enabled and type(d.status) == "number" then
      -- Example placeholders: you will fill actual bit indexes after confirming in flight / logs
      local y = 14
      lcd.drawText(W - 1, y, "FLAGS:", RIGHT); y = y + 10

      if CFG.STATUS_BITS.failsafe ~= nil then
        lcd.drawText(W - 1, y, bitIsSet(d.status, CFG.STATUS_BITS.failsafe) and "FAILSAFE" or "OK", RIGHT); y = y + 10
      end
      if CFG.STATUS_BITS.gps_rescue ~= nil then
        lcd.drawText(W - 1, y, bitIsSet(d.status, CFG.STATUS_BITS.gps_rescue) and "RESCUE" or "-", RIGHT); y = y + 10
      end
      if CFG.STATUS_BITS.armed ~= nil then
        lcd.drawText(W - 1, y, bitIsSet(d.status, CFG.STATUS_BITS.armed) and "ARMED" or "DISARM", RIGHT); y = y + 10
      end
    else
      lcd.drawText(W - 1, 14, "RAW ONLY", RIGHT + SMLSIZE)
    end
  end

  -- Toast
  if msg and getTime() <= msgUntil then
    lcd.drawText(math.floor(W/2), 52, msg, CENTER + INVERS)
  end

  return 0
end

return { run = run }