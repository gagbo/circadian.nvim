<!--
SPDX-FileCopyrightText: 2023 Gerry Agbobada <git@gagbo.net>

SPDX-License-Identifier: CC0-1.0
-->

# Circadian.nvim

> Port of the [circadian.el](https://github.com/guidoschmidt/circadian.el) plugin
  I like so much in Emacs


This plugin changes automatically between 2 themes according to the sunrise and
sunset times at your location. It literally uses an astronomical formula to
obtain the hours from the current date, the latitude, and the longitude in order
to set the colorschemes correctly for you.

## Setup

No configuration option is mandatory. Calling the setup function will
set the colorscheme according to the time of day, if the relevant option
(`day` or `night`) is filled.

```lua
require('circadian').setup({
  -- Latitude: Defaults to Paris' latitude
  lat = 0.0,
  -- Longitude: Defaults to Paris' longitude
  lon = 0.0,
  -- Day theme: the background is optional, but useful for themes that
  -- control light/dark variants with it. Defaults to nil everywhere
  -- (will not change a thing when Sun rises)
  day = { background = "light", colorscheme = "alabaster" }
  -- Night theme: the background is optional, but useful for themes that
  -- control light/dark variants with it. Defaults to nil everywhere
  -- (will not change a thing when Sun sets)
  night = { background = "dark", colorscheme = "catpuccin" }
})
```

## Good add-on

Totally unrelated, but Circadian is a little noisy on the log side, so
using something like [nvim-notify](https://github.com/rcarriga/nvim-notify)
or any other `vim.notify` handler is going to feel good.

## Alpha state

- I don't know how it works with all the themes that are full lua and need
  a `setup()` function call with options
- I don't know how robust the algorithm is when switching between day and
  night (_especially_ if you have a neovim started at night until the next sunrise)
- Probably a bunch of other things are going to fail
