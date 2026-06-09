# kamui.nvim

## Why

## Install

## With vim-tmux-navigator

```lua
{
  "gabrielsugai/kamui.nvim",
  dependencies = { "christoomey/vim-tmux-navigator" },
    init = function()
        vim.g.tmux_navigator_no_mappings = 1
    end,
  opts = {
    navigate = {
      -- normal navigation: let vim-tmux-navigator decide between nvim/tmux.
      -- the maximized behavior (jump to the tmux pane) is built in.
      default = function(dir)
        vim.cmd(({
          left = "TmuxNavigateLeft",
          down = "TmuxNavigateDown",
          up = "TmuxNavigateUp",
          right = "TmuxNavigateRight",
        })[dir])
      end,
    },
  },
  keys = {
    { "<leader>z", function() require("kamui").toggle() end, desc = "Maximize/restore window" },
    { "<C-h>", function() require("kamui").navigate("left") end },
    { "<C-j>", function() require("kamui").navigate("down") end },
    { "<C-k>", function() require("kamui").navigate("up") end },
    { "<C-l>", function() require("kamui").navigate("right") end },
  },
}
```

### Options

```lua
{
  navigate = {
    default = nil,   -- fun(dir): navigation when NOT maximized (required to use navigate)
    maximized = nil, -- fun(dir): navigation when maximized (optional; defaults to tmux)
  },
  create_commands = true, -- creates :Maximize, :Unmaximize, :MaximizeToggle
}
```

## Commands

- `:Maximize` — maximize the current window
- `:Unmaximize` — restore/equalize
- `:MaximizeToggle` — toggle
