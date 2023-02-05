-- SPDX-FileCopyrightText: 2023 Gerry Agbobada <git@gagbo.net>
--
-- SPDX-License-Identifier: MIT

local M = {}

local lustrous = require("lustrous")

local timer

local function get_timezone_offset_hours()
  local now = os.time()
  return (os.difftime(now, os.time(os.date("!*t", now))) / 3600.0)
end

local function set_theme(opts)
  local day = opts.day or { background = "light", colorscheme = nil }
  local night = opts.night or { background = "dark", colorscheme = nil }
  local lat = opts.lat or 48.8567879
  local lon = opts.lon or 2.3510768

  local current, rise, set = lustrous.get_time({ lat = lat, lon = lon, offset = get_timezone_offset_hours() })

  local next_time = rise

  if current == "day" then
    next_time = set
    local need_reset = false
    if day.background then
      vim.o.background = day.background
      need_reset = true
    end
    if day.colorscheme then
      vim.cmd("colorscheme " .. day.colorscheme)
      need_reset = true
    end
    vim.notify(
      "Circadian: day detected (" .. day.colorscheme .. " / " .. day.background ..  ")",
      vim.log.levels.INFO,
    {title = "Circadian"})
    if need_reset then
        vim.cmd("syntax reset")
    end
  else
    next_time = rise
    local need_reset = false
    if night.background then
      vim.o.background = night.background
      need_reset = true
    end
    if night.colorscheme then
      vim.cmd("colorscheme " .. night.colorscheme)
      need_reset = true
    end
    vim.notify(
      "Circadian: night detected (" .. night.colorscheme .. " / " .. night.background ..  ")",
      vim.log.levels.INFO,
    {title = "Circadian"})
    if need_reset then vim.cmd("syntax reset") end
  end

  local timer = vim.loop.new_timer()
  local delay = next_time - os.time()
  -- Detecting when next_time is in the past
  -- Looping an extra day like that is likely to be 2/3 minutes off though
  if delay < 0 then
    delay = delay + 86400
  end
  vim.notify(
    "Circadian: next change planned at " .. os.date('%H:%M:%S', next_time) .. " (in " .. delay .. " seconds)",
    vim.log.levels.DEBUG,
  {title = "Circadian"})

  timer:start(delay,
              0,
              function ()
                timer:stop()
                timer:close()
                vim.schedule_wrap(function()
                  set_theme(opts)
                end)
              end)
  return timer
end

function M.setup(opts)
  timer = set_theme(opts)
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    vim.notify("Call circadian.setup again with the arguments to restart", vim.log.levels.INFO,
    {title = "Circadian"})
  else
    vim.notify("Circadian is not running now", vim.log.levels.WARN,
    {title = "Circadian"})
  end
end

return M
