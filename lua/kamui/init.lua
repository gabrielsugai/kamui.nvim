local M = {}

-- default configuration
local config = {
  navigate = {
    default = nil,
    focused = nil,
  },
  create_commands = true,
}

local tmux_directions = { left = "L", down = "D", up = "U", right = "R" }

local focused = false
local focused_win = nil

--- Retorna apenas os paineis "reais" da aba atual (ignora janelas flutuantes).
local function real_windows()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      table.insert(wins, win)
    end
  end
  return wins
end

--- Indica se ha um painel em foco de fato.
--- Considera em foco somente se a flag interna estiver ativa E existir ao menos um painel vizinho inativo.
function M.is_focused()
  if not focused then
    return false
  end
  local wins = real_windows()
  if #wins <= 1 then
    return false
  end
  local current = vim.api.nvim_get_current_win()
  for _, win in ipairs(wins) do
    if win ~= current then
      local inactive = vim.api.nvim_win_get_width(win) <= 1
        or vim.api.nvim_win_get_height(win) <= 1
      if inactive then
        return true
      end
    end
  end
  return false
end

local function apply_focus()
  vim.cmd("wincmd _") -- altura maxima
  vim.cmd("wincmd |") -- largura maxima
end

--- Foca o painel atual, deixando os demais inativos.
function M.focus()
  if #real_windows() <= 1 then
    return
  end
  focused_win = vim.api.nvim_get_current_win()
  apply_focus()
  focused = true
end

--- Tira o foco/equaliza os paineis, ocupando todo o espaco disponivel atual.
function M.unfocus()
  vim.cmd("wincmd =")
  focused = false
  focused_win = nil
end

--- Alterna entre focar e tirar o foco.
function M.toggle()
  if M.is_focused() then
    M.unfocus()
  else
    M.focus()
  end
end

--- Despacha um movimento de navegacao para o handler correto conforme o estado.
--- param dir string Direcao logica: "left", "down", "up" ou "right".
--- param handlers { default: fun(dir: string), focused: fun(dir: string) }
function M.navigate(dir, handlers)
  handlers = handlers or config.navigate
  if M.is_focused() then
    if handlers.focused then
      handlers.focused(dir)
    elseif vim.env.TMUX then
      -- Padrao para tmux: pula direto para o painel do tmux na direcao
      vim.fn.system("tmux select-pane -" .. tmux_directions[dir])
    elseif handlers.default then
      -- Fora do tmux: navegacao normal entre os paineis do nvim
      handlers.default(dir)
    end
  elseif handlers.default then
    handlers.default(dir)
  end
end

--- Configura o plugin.
--- param opts KamuiConfig
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("Kamui", { clear = true }),
    callback = function()
      if not focused then
        return
      end
      if focused_win and vim.api.nvim_win_is_valid(focused_win) then
        vim.api.nvim_win_call(focused_win, apply_focus)
      else
        focused = false
        focused_win = nil
      end
    end,
  })

  if config.create_commands then
    vim.api.nvim_create_user_command("Focus", M.focus, { desc = "Focar painel atual" })
    vim.api.nvim_create_user_command("Unfocus", M.unfocus, { desc = "Tirar foco/equalizar paineis" })
    vim.api.nvim_create_user_command("FocusToggle", M.toggle, { desc = "Alternar foco do painel" })
  end
end

return M
