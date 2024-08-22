local M = {}

local function ShowLocationsInQuickfix(locations)
  local quickfix_list = {}

  for _, loc in ipairs(locations) do
    local file = vim.fn.fnamemodify(loc.uri, ':p')
    table.insert(quickfix_list, {
      filename = file,
      lnum = loc.range.start.line + 1,
      col = loc.range.start.character + 1,
      text = 'LSP Location'
    })
  end

  vim.fn.setqflist(quickfix_list, 'r')
  vim.api.nvim_command('copen')
end

local function onResponse(err, result)
  if err then
    vim.api.nvim_err_writeln('Error: ' .. err.message)
    return
  end

  if not result or #result == 0 then
    vim.api.nvim_out_write('No locations found!\n')
    return
  end

  if #result == 1 then
    local loc = result[1]
    vim.lsp.util.jump_to_location(loc)
  else
    ShowLocationsInQuickfix(result)
  end
end

function M.DslLocation()
  local filepath = vim.fn.expand('%:p')
  local uri = 'file://' .. filepath
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = cursor_pos[1] - 1
  local character = cursor_pos[2]

  local params = {
    textDocument = { uri = uri },
    position = {
      line = line,
      character = character
    }
  }

  vim.lsp.buf_request(0, 'dsl/location', params, function(err, result)
    onResponse(err, result)
  end)
end

function M.OpenFileAtLine()
  local line = vim.fn.getline('.')

  -- Match the pattern 'file://filename:line_number:column'
  local matches = { string.match(line, 'file://(.+):(%d+):(%d+)') }

  if #matches == 3 then
    local root = "/workspace/restaumatic"

    local filepath = matches[1]:gsub('${root}', root)
    local lineno = tonumber(matches[2])
    local colno = tonumber(matches[3])

    vim.cmd('edit ' .. filepath)
    vim.api.nvim_win_set_cursor(0, { lineno, colno })
  else
    vim.cmd('normal! gf')
  end
end

function M.setup()
  vim.api.nvim_create_user_command('DslLocation', M.DslLocation, {})
  vim.api.nvim_create_user_command('DslOpenFileAtLine', M.OpenFileAtLine, {})
  vim.api.nvim_set_keymap('n', 'gy', '<cmd>DslLocation<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', 'gf', '<cmd>DslOpenFileAtLine<CR>', { noremap = true, silent = true })
end

return M

