local C = {}

C.SENS = {
  batt = "VFAS",
  rssi = "RSSI",
  alt  = "Alt",
  spd  = "GSpd",
  hdg  = "Hdg",
  gps  = "GPS",

  satsPrimary  = "Tmp1",
  satsFallback = "Tmp2",

  status = "Tmp2", -- často BF posílá "něco statusového" sem
}

C.UI = {
  arrowSize = 10,
}

-- Volitelné: mapování bitů pro status (pokud se potvrdí, že Tmp2 je bitmask)
-- Nechávám to defaultně vypnuté, aby se nic nehalucinovalo.
C.STATUS_BITS = {
  enabled = false,   -- až uvidíš, že to sedí, přepni na true
  -- příklad (NEJEN tak, musí se potvrdit):
  -- failsafe = 0,
  -- gps_rescue = 1,
  -- armed = 2,
}

return C