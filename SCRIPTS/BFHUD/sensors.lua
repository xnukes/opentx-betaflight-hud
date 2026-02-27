-- /SCRIPTS/BFHUD/sensors.lua

local S = {}

local function getAny(name)
  if not name then return nil end
  local v = getValue(name)
  if v == nil or v == "----" then return nil end
  return v
end

local function normalizeDeg(x)
  if type(x) ~= "number" then return nil end
  local ax = math.abs(x)
  if ax <= 180 then return x end

  -- Sometimes GPS comes as scaled int (1e6 or 1e7)
  local t = x
  for _, div in ipairs({1e7, 1e6, 1e5, 1e4, 1e3}) do
    if math.abs(t / div) <= 180 then return t / div end
  end

  -- Last resort: keep scaling down until plausible
  while math.abs(t) > 180 do
    t = t / 10
    if math.abs(t) <= 180 then return t end
  end
  return t
end

-- OpenTX GPS sensor often returns a table:
-- { lat = ..., lon = ... } OR { [1]=lat, [2]=lon }
local function parseGPS(gpsVal)
  if gpsVal == nil then return nil, nil end

  if type(gpsVal) == "table" then
    local lat = gpsVal.lat or gpsVal.latitude or gpsVal[1]
    local lon = gpsVal.lon or gpsVal.longitude or gpsVal[2]
    lat = normalizeDeg(lat)
    lon = normalizeDeg(lon)
    return lat, lon
  end

  -- If it’s a single number, we can't extract both coords
  return nil, nil
end

function S.read(config)
  local d = {}

  d.batt = getAny(config.SENS.batt)
  d.rssi = getAny(config.SENS.rssi)
  d.alt  = getAny(config.SENS.alt)
  d.spd  = getAny(config.SENS.spd)
  d.hdg  = getAny(config.SENS.hdg)
  d.sats = getAny(config.SENS.sats)

  local gpsVal = getAny(config.SENS.gps)
  d.lat, d.lon = parseGPS(gpsVal)

  -- GPS OK if coords are plausible
  d.gpsOk = (d.lat ~= nil and d.lon ~= nil and math.abs(d.lat) <= 90 and math.abs(d.lon) <= 180)

  return d
end

return S