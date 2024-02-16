---@class CustomModule
local M = {}

M.strip =
    function(string) return string.gsub(string, "^s*(.{-})s*$", "\1", 1) end

M.get_next_non_blank_line_num = function(line_num)
    local total_lines = vim.api.nvim_buf_line_count(0)

    for i = line_num + 1, total_lines do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if line and not string.match(line, "^$") then return i end
    end

    return nil
end

M.get_prev_non_blank_line_num = function(line_num)
    for i = line_num - 1, 0, -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if line and not string.match(line, "^$") then return i end
    end

    return nil
end

M.get_line_by_num = function(line_num)
    if not line_num then return '' end
    return vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
end

M.remove_comma_or_semi_colon = function()
    if string.match(vim.b.current_line_last_char, '[,;]') then
        vim.api.nvim_exec2("s/[,;]\\?$//e", {})
    end
end

M.make_it_a_semi_colon = function()
    -- Prevent unnecessary buffer change:
    if vim.b.current_line_last_char == ';' then return end

    vim.api.nvim_exec2("s/[,;]\\?$/;/e", {})
end

M.make_it_a_comma = function()
    -- Prevent unnecessary buffer change:
    if vim.b.current_line_last_char == ',' then return end

    vim.api.nvim_exec2("s/[,;]\\?$/,/e", {})
end

M.has_unactionable_lines = function()
    -- Ignores comment lines, if global option is configured
    -- if (g:cosco_ignore_comment_lines == 1) then
    --     let l:isComment = synIDattr(synID(line("."),col("."),1),"name") =~ '\ccomment'
    --     if l:isComment then
    --         return 1
    --     end
    -- end

    -- Ignores empty lines or lines ending with opening ([{
    if (M.strip(vim.b.current_line) == '' or
        string.match(vim.b.current_line_last_char, '[{[(]')) then return 1 end

    -- Ignores lines if the next one starts with a "{"
    if vim.b.next_line_first_char == '{' then return 1 end

    -- Ignores custom regex patterns given a file type.
    -- let s:cur_ft = &filetype
    -- if has_key(g:cosco_ignore_ft_pattern, s:cur_ft)
    --   if match(getline(line(".")), g:cosco_ignore_ft_pattern[s:cur_ft]) != -1
    --     return 1
    --   endif
    -- endif
end

M.comma_or_semi_colon = function(config)
    local buf = vim.api.nvim_win_get_buf(0)

    -- Don't run if we're in a readonly buffer:
    if vim.bo[buf].readonly then return end

    local l, c = table.unpack(vim.api.nvim_win_get_cursor(0))

    vim.b.original_line_num = l
    vim.b.original_cursor_position = vim.api.nvim_win_get_cursor(0)

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

    if M.has_unactionable_lines() then return end

    if vim.b.prev_line_last_char == ',' then
        if vim.b.next_line_last_char == ',' then
            M.make_it_a_comma(vim.b.current_line_last_char)
        elseif vim.b.next_line_indentation < vim.b.current_line_indentation then
            M.make_it_a_semi_colon(vim.b.current_line_last_char)
        elseif vim.b.next_line_indentation == vim.b.current_line_indentation then
            M.make_it_a_comma(vim.b.current_line_last_char)
        end
    elseif vim.b.prev_line_last_char == ';' then
        M.make_it_a_semi_colon(vim.b.current_line_last_char)
    elseif vim.b.prev_line_last_char == '{' then
        if vim.b.next_line_last_char == ',' then
            -- TODO idea: externalize this into a "javascript" extension:
            if string.match(M.strip(vim.b.next_line), '^var') then
                M.make_it_a_semi_colon(vim.b.current_line_last_char)
            end
            M.make_it_a_comma(vim.b.current_line_last_char)
            -- TODO idea: externalize this into a "javascript" extension:
        elseif string.match(M.strip(vim.b.prev_line), '^var') then
            if vim.b.next_line_first_char == '}' then
                M.remove_comma_or_semi_colon(vim.b.current_line_last_char)
            end
        else
            M.make_it_a_semi_colon(vim.b.current_line_last_char)
        end
    elseif vim.b.prev_line_last_char == '[' then
        if vim.b.next_line_first_char == ']' then
            M.remove_comma_or_semi_colon(vim.b.current_line_last_char)
        elseif string.match(vim.b.current_line_last_char, '[}\\])]') then
            M.make_it_a_semi_colon(vim.b.current_line_last_char)
        else
            M.make_it_a_comma(vim.b.current_line_last_char)
        end
    elseif vim.b.prev_line_last_char == '(' then
        if vim.b.next_line_first_char == ')' then
            M.remove_comma_or_semi_colon(vim.b.current_line_last_char)
        else
            M.make_it_a_comma(vim.b.current_line_last_char)
        end
    elseif vim.b.next_line_first_char == ']' then
        M.remove_comma_or_semi_colon(vim.b.current_line_last_char)
    else
        M.make_it_a_semi_colon(vim.b.current_line_last_char)
    end

    vim.api.nvim_win_set_cursor(0, vim.b.original_cursor_position)
    vim.cmd('noh')
end

return M
