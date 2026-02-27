-- /SCRIPTS/TELEMETRY/BFHUD.lua

local CFG = loadScript("/SCRIPTS/BFHUD/config.lua")()
local SENS = loadScript("/SCRIPTS/BFHUD/sensors.lua")()
local MATH = loadScript("/SCRIPTS/BFHUD/math.lua")()
local UI = loadScript("/SCRIPTS/BFHUD/ui.lua")()

-- Home storage (in RAM; resets when radio script restarts)
local homeLat, homeLon = nil, nil
local homeSetAt = nil -- getTime() value
local msg = nil
local msgUntil = 0

local function setMsg(t, seconds)
  msg = t
  msgUntil = getTime() + (seconds or 80) -- 80 ticks ~ 0.8s (OpenTX ticks are 10ms-ish on many radios)
end

local function trySetHome(d)
  if d.gpsOk then
    homeLat, homeLon = d.lat, d.lon
    homeSetAt = getTime()
    setMsg("HOME SET", 120)
  else
    setMsg("NO GPS", 120)
  end
end

local function clearHome()
  homeLat, homeLon, homeSetAt = nil, nil, nil
  setMsg("HOME CLR", 120)
end

local function run(event)
  local W, H = LCD_W, LCD_H

  local d = SENS.read(CFG)

  -- Controls:
  -- Long ENTER: set home
  -- Long EXIT: clear home
  if event == EVT_ENTER_LONG then
    trySetHome(d)
    killEvents(event)
  elseif event == EVT_EXIT_LONG then
    clearHome()
    killEvents(event)
  end

  -- Compute home metrics
  local dist = nil
  local bearing = nil
  local rel = nil

  if homeLat and homeLon and d.gpsOk then
    dist = MATH.haversine_m(homeLat, homeLon, d.lat, d.lon)
    bearing = MATH.bearing_deg(d.lat, d.lon, homeLat, homeLon) -- from craft to home
    if type(d.hdg) == "number" and bearing then
      rel = MATH.wrap360(bearing - d.hdg) -- arrow relative to where nose points
    end
  end

  lcd.clear()

  -- Header
  lcd.drawText(1, 1, "BF HUD", INVERS)

  -- Battery top-right
  if type(d.batt) == "number" then
    lcd.drawText(W - 1, 1, string.format("%.1fV", d.batt), RIGHT + INVERS)
  else
    lcd.drawText(W - 1, 1, "--.-V", RIGHT + INVERS)
  end

  -- Left column
  lcd.drawText(1, 14, "ALT", 0)
  lcd.drawText(30, 14, UI.fmtNum(d.alt, "m", 0), 0)

  lcd.drawText(1, 26, "SPD", 0)
  lcd.drawText(30, 26, UI.fmtNum(d.spd, "", 0), 0)

  lcd.drawText(1, 38, "SAT", 0)
  lcd.drawText(30, 38, UI.fmtNum(d.sats, "", 0), 0)

  -- Right column
  lcd.drawText(W - 1, 14, "RSSI " .. UI.fmtNum(d.rssi, "", 0), RIGHT)

  if dist then
    local dd = dist
    local distTxt
    if dd >= 1000 then
      distTxt = string.format("%.2fkm", dd / 1000)
    else
      distTxt = string.format("%dm", dd)
    end
    lcd.drawText(W - 1, 26, "HOME " .. distTxt, RIGHT)
  else
    lcd.drawText(W - 1, 26, "HOME --", RIGHT)
  end

  if type(d.hdg) == "number" then
    lcd.drawText(W - 1, 38, string.format("HDG %d", d.hdg), RIGHT)
  else
    lcd.drawText(W - 1, 38, "HDG --", RIGHT)
  end

  -- Center: arrow + GPS status
  local cx, cy = math.floor(W / 2), H - 14
  UI.drawArrow(cx, cy, rel, CFG.UI.arrowSize)

  local gpsTxt = d.gpsOk and "GPS OK" or "NO GPS"
  lcd.drawText(cx, H - 10, gpsTxt, CENTER + SMLSIZE)

  -- Home status line
  if homeLat and homeLon then
    lcd.drawText(1, H - 10, "H:SET", SMLSIZE)
  else
    lcd.drawText(1, H - 10, "H:--", SMLSIZE)
  end

  -- Toast message
  if msg and getTime() <= msgUntil then
    lcd.drawText(cx, 52, msg, CENTER + INVERS)
  end

  return 0
end

return { run = run }