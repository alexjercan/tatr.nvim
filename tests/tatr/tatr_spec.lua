local Tatr = require("tatr")

describe("Tatr setup", function()
    before_each(function()
        -- Reset to default config before each test
        Tatr.config = {
            tatr_cmd = "tatr",
            default_priority = 0,
            default_status = "OPEN",
        }
    end)

    it("works with default config", function()
        Tatr.setup()

        assert(Tatr.config.tatr_cmd == "tatr", "default tatr_cmd")
        assert(Tatr.config.default_priority == 0, "default priority")
        assert(Tatr.config.default_status == "OPEN", "default status")
    end)

    it("merges user config with defaults", function()
        Tatr.setup({
            default_priority = 50,
        })

        assert(Tatr.config.tatr_cmd == "tatr", "keeps default tatr_cmd")
        assert(Tatr.config.default_priority == 50, "uses custom priority")
        assert(Tatr.config.default_status == "OPEN", "keeps default status")
    end)

    it("accepts custom tatr_cmd", function()
        Tatr.setup({
            tatr_cmd = "/usr/local/bin/tatr",
        })

        assert(Tatr.config.tatr_cmd == "/usr/local/bin/tatr", "custom tatr_cmd")
    end)

    it("accepts valid OPEN status", function()
        Tatr.setup({
            default_status = "OPEN",
        })

        assert(Tatr.config.default_status == "OPEN", "OPEN status")
    end)

    it("accepts valid IN_PROGRESS status", function()
        Tatr.setup({
            default_status = "IN_PROGRESS",
        })

        assert(
            Tatr.config.default_status == "IN_PROGRESS",
            "IN_PROGRESS status"
        )
    end)

    it("accepts valid CLOSED status", function()
        Tatr.setup({
            default_status = "CLOSED",
        })

        assert(Tatr.config.default_status == "CLOSED", "CLOSED status")
    end)
end)

describe("Tatr setup errors", function()
    it("errors on invalid status", function()
        assert.has_error(function()
            Tatr.setup({
                default_status = "INVALID",
            })
        end)
    end)

    it("errors on non-string tatr_cmd", function()
        assert.has_error(function()
            Tatr.setup({
                tatr_cmd = 123,
            })
        end)
    end)

    it("errors on non-number default_priority", function()
        assert.has_error(function()
            Tatr.setup({
                default_priority = "high",
            })
        end)
    end)
end)

describe("Tatr module structure", function()
    it("exports setup function", function()
        assert(type(Tatr.setup) == "function", "setup is a function")
    end)

    it("exports new function", function()
        assert(type(Tatr.new) == "function", "new is a function")
    end)

    it("exports list function", function()
        assert(type(Tatr.list) == "function", "list is a function")
    end)

    it("exports health function", function()
        assert(type(Tatr.health) == "function", "health is a function")
    end)

    it("exports config table", function()
        assert(type(Tatr.config) == "table", "config is a table")
    end)
end)

describe("Tatr config persistence", function()
    before_each(function()
        -- Reset to default config before each test
        Tatr.config = {
            tatr_cmd = "tatr",
            default_priority = 0,
            default_status = "OPEN",
        }
    end)

    it("persists config across calls", function()
        Tatr.setup({
            default_priority = 99,
        })

        local priority1 = Tatr.config.default_priority

        -- Call setup again without arguments
        Tatr.setup()

        local priority2 = Tatr.config.default_priority

        -- Config should be merged, not reset
        assert(priority1 == 99, "initial config: " .. priority1)
        assert(priority2 == 99, "config persists: " .. priority2)
    end)

    it("allows config updates", function()
        Tatr.setup({
            default_priority = 10,
        })

        assert(Tatr.config.default_priority == 10, "initial priority")

        Tatr.setup({
            default_priority = 20,
        })

        assert(Tatr.config.default_priority == 20, "updated priority")
    end)
end)

describe("Tatr config validation", function()
    before_each(function()
        -- Reset to default config before each test
        Tatr.config = {
            tatr_cmd = "tatr",
            default_priority = 0,
            default_status = "OPEN",
        }
    end)

    it("validates tatr_cmd is string", function()
        assert.has_error(function()
            Tatr.setup({
                tatr_cmd = {},
            })
        end)
    end)

    it("validates default_priority is number", function()
        assert.has_error(function()
            Tatr.setup({
                default_priority = {},
            })
        end)
    end)

    it("validates default_status is valid value", function()
        assert.has_error(function()
            Tatr.setup({
                default_status = "PENDING",
            })
        end)
    end)

    it("accepts negative priority", function()
        Tatr.setup({
            default_priority = -10,
        })

        assert(Tatr.config.default_priority == -10, "negative priority allowed")
    end)

    it("accepts zero priority", function()
        Tatr.setup({
            default_priority = 0,
        })

        assert(Tatr.config.default_priority == 0, "zero priority allowed")
    end)

    it("accepts large priority", function()
        Tatr.setup({
            default_priority = 1000,
        })

        assert(Tatr.config.default_priority == 1000, "large priority allowed")
    end)
end)
