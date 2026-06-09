local M = {}

-- default configuration
local config = {
  navigate = {
    default = nil,
    maximized = nil,
  },
  create_commands = true,
}

local tmux_directions = { left = "L", down = "D", up = "U", right = "R" }

local maximized = false

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

--- Indica se ha um painel maximizado de fato.
--- Considera maximizado somente se a flag interna estiver ativa E existir ao menos um painel vizinho minimizado. 
function M.is_maximized()
  if not maximized then
    return false
  end
  local wins = real_windows()
  if #wins <= 1 then
    return false
  end
  local current = vim.api.nvim_get_current_win()
  for _, win in ipairs(wins) do
    if win ~= current then
      local minimized = vim.api.nvim_win_get_width(win) <= 1
        or vim.api.nvim_win_get_height(win) <= 1
      if minimized then
        return true
      end
    end
  end
  return false
end

--- Maximiza o painel atual, minimizando os demais.
function M.maximize()
  if #real_windows() <= 1 then
    return
  end
  vim.cmd("wincmd _") -- altura maxima
  vim.cmd("wincmd |") -- largura maxima
  maximized = true
end

--- Restaura/equaliza os paineis, ocupando todo o espaco disponivel atual.
function M.restore()
  vim.cmd("wincmd =")
  maximized = false
end

--- Alterna entre maximizar e restaurar.
function M.toggle()
  if M.is_maximized() then
    M.restore()
  else
    M.maximize()
  end
end

--- Despacha um movimento de navegacao para o handler correto conforme o estado.
--- param dir string Direcao logica: "left", "down", "up" ou "right".
--- param handlers { default: fun(dir: string), maximized: fun(dir: string) }
function M.navigate(dir, handlers)
  handlers = handlers or config.navigate
  if M.is_maximized() then
    if handlers.maximized then
      handlers.maximized(dir)
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

  if config.create_commands then
    vim.api.nvim_create_user_command("Maximize", M.maximize, { desc = "Maximizar painel atual" })
    vim.api.nvim_create_user_command("Unmaximize", M.restore, { desc = "Restaurar/equalizar paineis" })
    vim.api.nvim_create_user_command("MaximizeToggle", M.toggle, { desc = "Alternar maximizar painel" })
  end
end

return M
