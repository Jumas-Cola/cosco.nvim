local plugin = require("cosco.module")

describe("helpers", function()
    it("strip helper func", function()
        assert(plugin.strip(" Hello!  ") == "Hello!", "strip() func works")
    end)
end)
