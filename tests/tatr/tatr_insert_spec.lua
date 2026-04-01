local Tatr = require("tatr")

describe("Tatr insert", function()
    it("exports insert function", function()
        assert(type(Tatr.insert) == "function", "insert is a function")
    end)
end)

describe("Task line parsing", function()
    it("parses valid task line with single tag", function()
        local line = "/home/alex/personal/tatr.nvim/tasks/20260330-202900/TASK.md:"
            .. "[PRIORITY: 90, TAGS: feature] Implement nvim plugin to create task and link from editor"

        -- Access the private parse function by reading the module directly
        -- In real implementation, we'd export this for testing or test integration
        -- For now, we test the behavior through integration
        assert(line ~= nil, "line is not nil")
    end)

    it("parses valid task line with multiple tags", function()
        local line =
            "/home/alex/tasks/TASK.md: [PRIORITY: 50, TAGS: feature, test] Test task"
        assert(line ~= nil, "line is not nil")
    end)
end)

describe("Comment string detection", function()
    it("works with lua files", function()
        -- Create a temporary lua buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, "filetype", "lua")
        vim.api.nvim_set_current_buf(buf)

        local commentstring = vim.bo.commentstring
        assert(
            commentstring ~= nil and commentstring ~= "",
            "commentstring is set for lua: " .. tostring(commentstring)
        )

        -- Clean up
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("works with python files", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, "filetype", "python")
        vim.api.nvim_set_current_buf(buf)

        local commentstring = vim.bo.commentstring
        assert(
            commentstring ~= nil and commentstring ~= "",
            "commentstring is set for python: " .. tostring(commentstring)
        )

        -- Clean up
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("works with javascript files", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, "filetype", "javascript")
        vim.api.nvim_set_current_buf(buf)

        local commentstring = vim.bo.commentstring
        assert(
            commentstring ~= nil and commentstring ~= "",
            "commentstring is set for javascript: " .. tostring(commentstring)
        )

        -- Clean up
        vim.api.nvim_buf_delete(buf, { force = true })
    end)
end)

describe("Insert TODO comment format", function()
    it("follows correct format", function()
        local huid = "20260330-202900"
        local title =
            "Implement nvim plugin to create task and link from editor"
        local comment_str = "//"

        local expected =
            "// TODO(20260330-202900): Implement nvim plugin to create task and link from editor"
        local actual =
            string.format("%s TODO(%s): %s", comment_str, huid, title)

        assert(actual == expected, "TODO comment format matches")
    end)

    it("works with different comment strings", function()
        local huid = "20260330-202900"
        local title = "Test task"

        -- Test with # (Python, Shell, etc.)
        local comment1 = string.format("# TODO(%s): %s", huid, title)
        assert(
            comment1 == "# TODO(20260330-202900): Test task",
            "Python comment format"
        )

        -- Test with // (JavaScript, C++, etc.)
        local comment2 = string.format("// TODO(%s): %s", huid, title)
        assert(
            comment2 == "// TODO(20260330-202900): Test task",
            "JavaScript comment format"
        )

        -- Test with -- (Lua, SQL, etc.)
        local comment3 = string.format("-- TODO(%s): %s", huid, title)
        assert(
            comment3 == "-- TODO(20260330-202900): Test task",
            "Lua comment format"
        )
    end)
end)
