---@class CustomModule
local M = {}

-- =================
-- Helper functions:
-- =================

M.strip = function(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M.get_next_non_blank_line_num = function(line_num)
  local total_lines = vim.api.nvim_buf_line_count(0)

  for i = line_num + 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

    if line and not string.match(line, "^$") then
      return i
    end
  end

  return nil
end

M.get_prev_non_blank_line_num = function(line_num)
  for i = line_num - 1, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

    if line and not string.match(line, "^$") then
      return i
    end
  end

  return nil
end

M.get_line_by_num = function(line_num)
  if not line_num then
    return ""
  end
  return vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
end

M.has_unactionable_lines = function(config)
  -- Ignores comment lines, if global option is configured
  if config.cosco_ignore_comment_lines == 1 then
    -- Получаем текущую позицию курсора
    local line_num, col_num = table.unpack(vim.api.nvim_win_get_cursor(0))
    -- Получаем ID группы синтаксиса для текущей позиции
    local synID = vim.fn.synID(line_num, col_num, true)
    -- Получаем имя группы синтаксиса по ID
    local synName = vim.fn.synIDattr(synID, "name")

    -- Проверяем, содержит ли имя группы синтаксиса слово "comment" (игнорируя регистр)
    if string.match(synName:lower(), "comment") then
      return true
    end
  end

  -- Ignores empty lines or lines ending with opening ([{
  if M.strip(vim.b.current_line) == "" or string.match(vim.b.current_line_last_char, "[{[(]") then
    return true
  end

  -- Ignores lines if the next one starts with a "{"
  if vim.b.next_line_first_char == "{" then
    return true
  end

  -- Ignores custom regex patterns given a file type.
  local cur_ft = vim.bo.filetype
  -- Проверка наличия ключа для текущего типа файла в глобальной переменной
  if config.cosco_ignore_ft_pattern and config.cosco_ignore_ft_pattern[cur_ft] then
    -- Получение текущей строки и проверка соответствия регулярному выражению
    local currentLine = vim.api.nvim_get_current_line()
    if currentLine:match(config.cosco_ignore_ft_pattern[cur_ft]) then
      return true
    end
  end
end

M.ignore_current_filetype = function(config)
  local filetypes = vim.split(vim.bo.filetype, "\\.", true)

  if config.cosco_filetype_whitelist then
    for _, i in ipairs(config.cosco_filetype_whitelist) do
      if vim.tbl_contains(filetypes, i) then
        return false
      end
    end
    return true
  elseif config.cosco_filetype_blacklist then
    for _, i in ipairs(config.cosco_filetype_blacklist) do
      if vim.tbl_contains(filetypes, i) then
        return true
      end
    end
    return false
  end

  return false
end

-- =====================
-- Filetypes extensions:
-- =====================

M.filetype_overrides = function()
  -- Объединяем имя функции на основе текущего типа файла
  local funcName = "filetypes#" .. vim.bo.filetype .. "#parse"

  -- Выполнение Vim команды с использованием pcall для перехвата ошибок
  local ok, result = pcall(function()
    -- Используйте vim.api.nvim_exec для выполнения Vim команды, например, вызова функции
    -- true в конце указывает, что не нужно выводить результат выполнения
    vim.api.nvim_exec2("call " .. funcName .. "()", true)
  end)

  -- Проверяем, была ли ошибка при выполнении команды
  if not ok then
    -- No filetypes for the current buffer filetype
  end
end

-- ================================
-- Insertion and replace functions:
-- ================================

M.remove_comma_or_semi_colon = function()
  if string.match(vim.b.current_line_last_char, "[,;]") then
    vim.api.nvim_exec2("s/[,;]\\?$//e", {})
  end
end

M.make_it_a_semi_colon = function()
  -- Prevent unnecessary buffer change:
  if vim.b.current_line_last_char == ";" then
    return
  end

  vim.api.nvim_exec2("s/[,;]\\?$/;/e", {})
end

M.make_it_a_comma = function()
  -- Prevent unnecessary buffer change:
  if vim.b.current_line_last_char == "," then
    return
  end

  vim.api.nvim_exec2("s/[,;]\\?$/,/e", {})
end

-- ==============
-- Main function:
-- ==============

M.comma_or_semi_colon = function(config)
  local buf = vim.api.nvim_win_get_buf(0)

  -- Don't run if we're in a readonly buffer:
  if vim.bo[buf].readonly then
    return
  end

  -- Dont run if current filetype has been disabled:
  if M.ignore_current_filetype(config) then
    return
  end

  vim.b.was_extension_executed = false

  vim.b.original_cursor_position = vim.api.nvim_win_get_cursor(0)

  local line, _ = table.unpack(vim.b.original_cursor_position)

  vim.b.original_line_num = line

  vim.b.current_line = vim.api.nvim_get_current_line()
  vim.b.current_line_last_char = string.match(vim.b.current_line, ".$")
  vim.b.current_line_first_char = string.match(vim.b.current_line, "^.")
  vim.b.current_line_indentation = vim.fn.indent(vim.b.original_line_num)

  vim.b.next_line_num = M.get_next_non_blank_line_num(vim.b.original_line_num)
  vim.b.prev_line_num = M.get_prev_non_blank_line_num(vim.b.original_line_num)

  vim.b.next_line = M.get_line_by_num(vim.b.next_line_num)
  vim.b.prev_line = M.get_line_by_num(vim.b.prev_line_num)

  vim.b.next_line_indentation = vim.fn.indent(vim.b.next_line_num)
  vim.b.prev_line_indentation = vim.fn.indent(vim.b.prev_line_num)

  vim.b.prev_line_last_char = string.match(vim.b.prev_line, ".$")
  vim.b.next_line_last_char = string.match(vim.b.next_line, ".$")
  vim.b.next_line_first_char = string.match(M.strip(vim.b.next_line), "^.")

  if M.has_unactionable_lines(config) then
    return
  end

  M.filetype_overrides()

  if vim.b.was_extension_executed then
    vim.api.nvim_win_set_cursor(0, vim.b.original_cursor_position)
    return
  end

  if vim.b.prev_line_last_char == "," then
    if string.match(vim.b.next_line_last_char, "^[)%]}]$") then
      M.remove_comma_or_semi_colon()
    elseif vim.b.next_line_last_char == "," then
      M.make_it_a_comma()
    elseif vim.b.next_line_indentation < vim.b.current_line_indentation then
      M.make_it_a_semi_colon()
    elseif vim.b.next_line_indentation == vim.b.current_line_indentation then
      M.make_it_a_comma()
    end
  elseif vim.b.prev_line_last_char == ";" then
    M.make_it_a_semi_colon()
  elseif vim.b.prev_line_last_char == "{" then
    if vim.b.next_line_last_char == "," then
      -- TODO idea: externalize this into a "javascript" extension:
      if string.match(M.strip(vim.b.next_line), "^var") then
        M.make_it_a_semi_colon()
      end
      M.make_it_a_comma()
      -- TODO idea: externalize this into a "javascript" extension:
    elseif string.match(M.strip(vim.b.prev_line), "^var") then
      if vim.b.next_line_first_char == "}" then
        M.remove_comma_or_semi_colon()
      end
    else
      M.make_it_a_semi_colon()
    end
  elseif vim.b.prev_line_last_char == "[" then
    if vim.b.next_line_first_char == "]" then
      M.remove_comma_or_semi_colon()
    elseif string.match(vim.b.current_line_last_char, "^[)%]}]$") then
      M.make_it_a_semi_colon()
    else
      M.make_it_a_comma()
    end
  elseif vim.b.prev_line_last_char == "(" then
    if vim.b.next_line_first_char == ")" then
      M.remove_comma_or_semi_colon()
    else
      M.make_it_a_comma()
    end
  elseif vim.b.next_line_first_char == "]" then
    M.remove_comma_or_semi_colon()
  else
    M.make_it_a_semi_colon()
  end

  vim.api.nvim_win_set_cursor(0, vim.b.original_cursor_position)
  vim.cmd("noh")
end

return M
