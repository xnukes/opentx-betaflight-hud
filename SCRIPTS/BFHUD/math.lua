-- /SCRIPTS/BFHUD/math.lua

local M = {}

local R = 6371000 -- Earth radius (m)

local function rad(d) return d * math.pi / 180 end
local function deg(r) return r * 180 / math.pi end

function M.wrap360(a)
  if a == nil then return nil end
  a = a % 360
  if a < 0 then a = a + 360 end
  return a
end

function M.haversine_m(lat1, lon1, lat2, lon2)
  if not lat1 or not lon1 or not lat2 or not lon2 then return nil end

  local phi1, phi2 = rad(lat1), rad(lat2)
  local dphi = rad(lat2 - lat1)
  local dlmb = rad(lon2 - lon1)

  local s = math.sin(dphi/2)^2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlmb/2)^2
  local c = 2 * math.atan2(math.sqrt(s), math.sqrt(1 - s))
  return R * c
end

function M.bearing_deg(lat1, lon1, lat2, lon2)
  if not lat1 or not lon1 or not lat2 or not lon2 then return nil end

  local phi1 = rad(lat1)
  local phi2 = rad(lat2)
  local dlmb = rad(lon2 - lon1)

  local y = math.sin(dlmb) * math.cos(phi2)
  local x = math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi2) * math.cos(dlmb)
  local brng = deg(math.atan2(y, x))
  return M.wrap360(brng)
end

return M