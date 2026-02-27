local S = {}

local function getVal(name)
  if not name then return nil end
  local v = getValue(name)
  if v == nil or v == "----" then return nil end
  return v
end

local function normalizeDeg(x)
  if type(x) ~= "number" then return nil end
  if math.abs(x) <= 180 then return x end
  for _, div in ipairs({1e7, 1e6, 1e5, 1e4, 1e3}) do
    local t = x / div
    if math.abs(t) <= 180 then return t end
  end
  while math.abs(x) > 180 do x = x / 10 end
  return x
end

local function parseGPS(gpsVal)
  if gpsVal == nil then return nil, nil end
  if type(gpsVal) == "table" then
    local lat = gpsVal.lat or gpsVal.latitude or gpsVal[1]
    local lon = gpsVal.lon or gpsVal.longitude or gpsVal[2]
    lat = normalizeDeg(lat)
    lon = normalizeDeg(lon)
    return lat, lon
  end
  return nil, nil
end

local function looksLikeSats(x)
  return type(x) == "number" and x >= 0 and x <= 60
end

local function pickSats(primaryName, fallbackName)
  local a = getVal(primaryName)
  local b = getVal(fallbackName)

  if looksLikeSats(a) and looksLikeSats(b) then
    -- prefer the more "sat-like" (bývá stabilnější) = větší číslo, ale ne šílený
    if a >= b then return a, primaryName else return b, fallbackName end
  end
  if looksLikeSats(a) then return a, primaryName end
  if looksLikeSats(b) then return b, fallbackName end

  -- fallback: vrať cokoliv, ať je aspoň něco vidět v debug
  return a or b, (a and primaryName) or (b and fallbackName) or nil
end

function S.read(config)
  local d = {}

  d.batt = getVal(config.SENS.batt)
  d.rssi = getVal(config.SENS.rssi)
  d.alt  = getVal(config.SENS.alt)
  d.spd  = getVal(config.SENS.spd)
  d.hdg  = getVal(config.SENS.hdg)

  local gpsVal = getVal(config.SENS.gps)
  d.lat, d.lon = parseGPS(gpsVal)
  d.gpsOk = (d.lat ~= nil and d.lon ~= nil and math.abs(d.lat) <= 90 and math.abs(d.lon) <= 180)

  d.sats, d.satsSrc = pickSats(config.SENS.satsPrimary, config.SENS.satsFallback)

  d.status = getVal(config.SENS.status) -- Tmp2 raw (většinou number)

  return d
end

return S