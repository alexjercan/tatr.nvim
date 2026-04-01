local M = {}

function M.check()
    local health = vim.health or require("health")

    health.start("tatr.nvim")

    -- Check Neovim version
    if vim.fn.has("nvim-0.9") == 1 then
        health.ok("Neovim >= 0.9")
    else
        health.error("Neovim < 0.9 is not supported")
    end

    -- Check if tatr command is available
    local tatr_cmd = require("tatr").config.tatr_cmd
    local handle = io.popen("command -v " .. tatr_cmd)
    if handle == nil then
        health.error(
            string.format("Could not check for tatr command: %s", tatr_cmd)
        )
    else
        local result = handle:read("*a")
        handle:close()
        if result ~= "" then
            health.ok(string.format("tatr command found: %s", vim.trim(result)))

            -- Check tatr version
            local version_handle = io.popen(tatr_cmd .. " version 2>&1")
            if version_handle then
                local version = version_handle:read("*a")
                version_handle:close()
                health.info(
                    string.format("tatr version: %s", vim.trim(version))
                )
            end
        else
            health.error(
                string.format(
                    "tatr command not found: %s. Please install tatr or configure tatr_cmd in setup()",
                    tatr_cmd
                )
            )
        end
    end

    -- Check telescope.nvim (optional)
    local ok_telescope = pcall(require, "telescope")
    if ok_telescope then
        health.ok("telescope.nvim detected (telescope integration enabled)")
    else
        health.info(
            "telescope.nvim not installed (will use quickfix list instead)"
        )
    end

    -- Check configuration
    local config = require("tatr").config
    if type(config) == "table" then
        health.ok("Configuration loaded")
        health.info(
            string.format("  default_priority: %d", config.default_priority)
        )
        health.info(
            string.format("  default_status: %s", config.default_status)
        )
    else
        health.error("Configuration is not a table")
    end
end

return M
