local plugin = require("cosco.module")

-- ================
-- Helper functions
-- ================

describe("helpers", function()
  it("strip helper func", function()
    assert(plugin.strip(" Hello!  ") == "Hello!", "strip() func works")
  end)
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
    vim.api.nvim_create_buf(true, true)
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
