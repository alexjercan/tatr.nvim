vim.api.nvim_create_user_command("TatrNew", function(opts)
    require("tatr").new({ title = opts.args })
end, {
    nargs = "?",
    desc = "Create a new task",
})

vim.api.nvim_create_user_command("TatrList", function(opts)
    local sort = nil
    if opts.args ~= "" then
        sort = opts.args
    end
    require("tatr").list({ sort = sort })
end, {
    nargs = "?",
    complete = function()
        return { "created", "priority", "title" }
    end,
    desc = "List tasks",
})

vim.api.nvim_create_user_command("TatrInsert", function(opts)
    local sort = nil
    if opts.args ~= "" then
        sort = opts.args
    end
    require("tatr").insert({ sort = sort })
end, {
    nargs = "?",
    complete = function()
        return { "created", "priority", "title" }
    end,
    desc = "Insert task as TODO comment",
})

vim.api.nvim_create_user_command("TatrSetup", function()
    require("tatr").setup(require("tatr").config)
end, {
    desc = "Reload tatr configuration",
})
