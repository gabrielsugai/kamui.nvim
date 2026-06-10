# kamui.nvim

## Why

## Install with [lazy.nvim](https://github.com/folke/lazy.nvim)

### With vim-tmux-navigator

```lua
return {
  "gabrielsugai/kamui.nvim",
  dependencies = { "christoomey/vim-tmux-navigator" },
    init = function()
        vim.g.tmux_navigator_no_mappings = 1
    end,
  opts = {
    navigate = {
      -- normal navigation: let vim-tmux-navigator decide between nvim/tmux.
      -- the focused behavior (jump to the tmux pane) is built in.
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
    { "<leader>z", function() require("kamui").toggle() end, desc = "Focus/unfocus window" },
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
    default = nil, -- fun(dir): navigation when NOT focused (required to use navigate)
    focused = nil, -- fun(dir): navigation when focused (optional; defaults to tmux)
  },
  create_commands = true, -- creates :Focus, :Unfocus, :FocusToggle
}
```

## Commands

- `:Focus` — focus the current window
- `:Unfocus` — unfocus/equalize
- `:FocusToggle` — toggle
