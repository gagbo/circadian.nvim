-- SPDX-FileCopyrightText: 2023 Gerry Agbobada <git@gagbo.net>
--
-- SPDX-License-Identifier: MIT

local M = {}

local lustrous = require("circadian.lustrous")

local function get_timezone_offset_hours()
  local now = os.time()
  return (os.difftime(now, os.time(os.date("!*t", now))) / 3600.0)
end

local timer

local function set_theme(name, theme)
  local need_reset = false
  if theme.background then
    vim.o.background = theme.background
    need_reset = true
  end
  if theme.colorscheme then
    vim.cmd("colorscheme " .. theme.colorscheme)
    need_reset = true
  end
  if need_reset then
    vim.cmd("syntax reset")
  end
  vim.notify(
    "Circadian: " .. name .. " detected (" .. theme.colorscheme .. " / " .. theme.background .. ")",
    vim.log.levels.INFO,
    { title = "Circadian" }
  )
end

local function main(opts)
  local default = {
    day = { background = "light", colorscheme = nil },
    night = { background = "dark", colorscheme = nil },
  }
  local lat = opts.lat or 48.8567879
  local lon = opts.lon or 2.3510768

  local current, rise, set = lustrous.get_time({ lat = lat, lon = lon, offset = get_timezone_offset_hours() })
  local next_time = rise
  set_theme(current, opts[current] or default[current])
  if current == "day" then
    next_time = set
  else
    next_time = rise
  end

  local delay = next_time - os.time()
  -- Detecting when next_time is in the past
  -- Looping an extra day like that is likely to be 2/3 minutes off though
  if delay < 0 then
    delay = delay + 86400
  elseif delay == 0 then
    delay = 1
  end
  vim.notify(
    "Circadian: next change planned at " .. os.date("%H:%M:%S", next_time) .. " (in " .. delay .. " seconds)",
    vim.log.levels.DEBUG,
    { title = "Circadian" }
  )

  return vim.defer_fn(function()
    main(opts)
  end, delay * 1000)
end

function M.setup(opts)
  timer = main(opts)
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    vim.notify("Call circadian.setup again with the arguments to restart", vim.log.levels.INFO, { title = "Circadian" })
  else
    vim.notify("Circadian is not running now", vim.log.levels.WARN, { title = "Circadian" })
  end
end

return M
