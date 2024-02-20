local plugin = require("cosco.module")

-- ================
-- Helper functions
-- ================

describe("helpers", function()
  it("strip helper func", function()
    assert(plugin.strip(" Hello!  ") == "Hello!", "strip() func works")
  end)

  it("get_next_non_blank_line_num helper func", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "", "", "", "five" })

    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    assert(5 == plugin.get_next_non_blank_line_num(1))

    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "", "", "", "" })

    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    assert(nil == plugin.get_next_non_blank_line_num(1))
  end)

  it("get_prev_non_blank_line_num helper func", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "", "", "", "five" })

    vim.api.nvim_win_set_cursor(0, { 5, 0 })

    assert(1 == plugin.get_prev_non_blank_line_num(5))

    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "", "", "", "", "five" })

    vim.api.nvim_win_set_cursor(0, { 5, 0 })

    assert(nil == plugin.get_prev_non_blank_line_num(5))
  end)
end)

it("get_line_by_num helper func", function()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "", "", "", "five" })

  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  assert("one" == plugin.get_line_by_num(1))
  assert("five" == plugin.get_line_by_num(5))
end)

describe("Previous line ending with `,`", function()
  it("Next line is also `,`", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one,", "two", "three," })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})

    assert("two," == vim.api.nvim_get_current_line())

    plugin.comma_or_semi_colon({})
    assert("two," == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("two;")
    plugin.comma_or_semi_colon({})
    assert("two," == vim.api.nvim_get_current_line())
  end)

  it("Next begins with }, ] or )", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one,", "two", "}" })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})
    assert("two" == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("two,")
    plugin.comma_or_semi_colon({})
    assert("two" == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("two;")
    plugin.comma_or_semi_colon({})
    assert("two" == vim.api.nvim_get_current_line())
  end)

  it("Next line is less indent:", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "    one,",
      "    two",
      "three;",
    })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})
    assert("    two;" == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("    two,")
    plugin.comma_or_semi_colon({})
    assert("    two;" == vim.api.nvim_get_current_line())

    plugin.comma_or_semi_colon({})
    assert("    two;" == vim.api.nvim_get_current_line())
  end)

  it("Next line is same indentation:", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "    one,",
      "    two",
      "    three;",
    })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})
    assert("    two," == vim.api.nvim_get_current_line())

    plugin.comma_or_semi_colon({})
    assert("    two," == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("    two;")
    plugin.comma_or_semi_colon({})
    assert("    two," == vim.api.nvim_get_current_line())
  end)
end)

describe("Previous line ending with `;`", function()
  it("Next line is also `;`", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one;", "two", "three;" })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})

    assert("two;" == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("two,")
    plugin.comma_or_semi_colon({})
    assert("two;" == vim.api.nvim_get_current_line())

    vim.api.nvim_set_current_line("two;")
    plugin.comma_or_semi_colon({})
    assert("two;" == vim.api.nvim_get_current_line())
  end)
end)

describe("Previous line ending with `{`", function()
  it("Next line is `,`", function() end)
  it("Next line is `var .* ,`", function() end)
  it("Next line is whatever", function() end)
  it("Previous line is `var .*`", function() end)
end)

describe("Previous line ending with `[`", function()
  it("Next line is `]`", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "[", "two", "]" })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})

    assert("two" == vim.api.nvim_get_current_line())
  end)

  it("Next line is whatever", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "[", "two", "three" })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})

    assert("two," == vim.api.nvim_get_current_line())
  end)
end)

describe("Previous line ending with `(`", function()
  it("Next line is `)`", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "(", "two", ")" })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})

    assert("two" == vim.api.nvim_get_current_line())
  end)

  it("Next line is whatever", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "(", "two", "three," })

    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    plugin.comma_or_semi_colon({})

    assert("two," == vim.api.nvim_get_current_line())
  end)
end)

describe("Next line starting with `{`", function()
  it("Next line is `}`", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "function nextLineBrace()",
      "    {",
      "        // Absolutely Barbaric",
      "    }",
    })

    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    plugin.comma_or_semi_colon({})

    assert("function nextLineBrace()" == vim.api.nvim_get_current_line())
  end)
end)
