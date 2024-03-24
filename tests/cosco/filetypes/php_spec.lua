local plugin = require("cosco.module")

local function setup()
  vim.cmd("enew")
  vim.bo.filetype = "php"
end

local function teardown()
  vim.cmd("bd!")
end

-- ============
-- Php specific
-- ============

describe("Previous line ending with `,`", function()
  it("Next line is anything", function()
    setup()

    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "$arr = [",
      "    one,",
      "    two",
      "    three",
      "];",
    })

    vim.api.nvim_win_set_cursor(0, { 3, 0 })

    plugin.comma_or_semi_colon({})
    assert("    two," == vim.api.nvim_get_current_line())

    plugin.comma_or_semi_colon({})
    assert("    two," == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("    two;")
    plugin.comma_or_semi_colon({})
    assert("    two," == vim.api.nvim_get_current_line())

    teardown()
  end)

  it("Next line is `];`", function()
    setup()

    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "$arr = [",
      "    one,",
      "    two,",
      "    three",
      "];",
    })

    vim.api.nvim_win_set_cursor(0, { 4, 0 })

    plugin.comma_or_semi_colon({})
    assert("    three" == vim.api.nvim_get_current_line())

    plugin.comma_or_semi_colon({})
    assert("    three" == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("    three,")
    plugin.comma_or_semi_colon({})
    assert("    three" == vim.api.nvim_get_current_line())

    teardown()
  end)
end)

describe("Previous line ending with `[`", function()
  it("Next line ending is `,`", function()
    setup()

    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "$arr = [",
      "    one",
      "    two,",
      "    three",
      "];",
    })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})
    assert("    one," == vim.api.nvim_get_current_line())

    plugin.comma_or_semi_colon({})
    assert("    one," == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("    one;")
    plugin.comma_or_semi_colon({})
    assert("    one," == vim.api.nvim_get_current_line())

    teardown()
  end)
end)

describe("Previous line function ending with `{`", function()
  it("Next line ending with `%w+];`", function()
    setup()

    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "function getSmth($param): string",
      "{",
      "    $smth = self::smth()",
      "    return $smth[$param];",
      "}",
    })

    vim.api.nvim_win_set_cursor(0, { 3, 0 })

    plugin.comma_or_semi_colon({})
    assert("    $smth = self::smth();" == vim.api.nvim_get_current_line())

    teardown()
  end)
end)
