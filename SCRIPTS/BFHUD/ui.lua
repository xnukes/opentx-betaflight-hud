-- /SCRIPTS/BFHUD/ui.lua

local UI = {}

function UI.drawArrow(cx, cy, angleDeg, size)
  if not angleDeg then
    lcd.drawText(cx - 3, cy - 3, "?", SMLSIZE)
    return
  end

  local a = math.rad(angleDeg)
  local x1 = cx + math.cos(a) * size
  local y1 = cy - math.sin(a) * size

  local x2 = cx + math.cos(a + 2.6) * (size * 0.7)
  local y2 = cy - math.sin(a + 2.6) * (size * 0.7)

  local x3 = cx + math.cos(a - 2.6) * (size * 0.7)
  local y3 = cy - math.sin(a - 2.6) * (size * 0.7)

  lcd.drawLine(cx, cy, x1, y1, SOLID, 0)
  lcd.drawLine(x1, y1, x2, y2, SOLID, 0)
  lcd.drawLine(x1, y1, x3, y3, SOLID, 0)
end

function UI.fmtNum(v, suffix, decimals)
  if v == nil then return "--" end
  if type(v) ~= "number" then return tostring(v) end
  decimals = decimals or 0
  if decimals == 0 then
    return string.format("%d%s", v, suffix or "")
  end
  return string.format("%." .. decimals .. "f%s", v, suffix or "")
end

return UI