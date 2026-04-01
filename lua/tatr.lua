---@class Config
---@field tatr_cmd string Command to run tatr (default: "tatr")
---@field default_priority number Default priority for new tasks (default: 0)
---@field default_status string Default status for new tasks (default: "OPEN")
local DEFAULT_CONFIG = {
    tatr_cmd = "tatr",
    default_priority = 0,
    default_status = "OPEN",
}

---@class Tatr
local M = {}

---@type Config
M.config = DEFAULT_CONFIG

---Setup tatr.nvim plugin
---@param args Config?
M.setup = function(args)
    args = args or {}
    M.config = vim.tbl_deep_extend("force", M.config, args)

    -- Validate configuration
    vim.validate({
        tatr_cmd = {
            M.config.tatr_cmd,
            "string",
            true,
        },
        default_priority = {
            M.config.default_priority,
            "number",
            true,
        },
        default_status = {
            M.config.default_status,
            function(v)
                return v == "OPEN" or v == "IN_PROGRESS" or v == "CLOSED"
            end,
            "status must be OPEN, IN_PROGRESS, or CLOSED",
        },
    })
end

---Check if tatr command is available
---@return boolean
local function is_tatr_available()
    local handle = io.popen("command -v " .. M.config.tatr_cmd)
    if handle == nil then
        return false
    end
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

---Execute tatr command and return output
---@param args string[] Command arguments
---@return string? output Command output or nil on error
---@return string? error Error message if command failed
local function execute_tatr(args)
    if not is_tatr_available() then
        local error_msg = string.format(
            "tatr command not found. Please install tatr or configure tatr_cmd in setup(). Looking for: %s",
            M.config.tatr_cmd
        )
        return nil, error_msg
    end

    local cmd = M.config.tatr_cmd .. " " .. table.concat(args, " ")
    local handle = io.popen(cmd .. " 2>&1")
    if handle == nil then
        return nil, "Failed to execute tatr command"
    end

    local output = handle:read("*a")
    local success = handle:close()

    if not success then
        return nil, output
    end

    return output, nil
end

---Create a new task
---@param opts table? Options for task creation
M.new = function(opts)
    opts = opts or {}

    -- Get title from user if not provided
    local title = opts.title
    if not title or title == "" then
        title = vim.fn.input("Task title: ")
        if title == "" then
            vim.notify("Task creation cancelled", vim.log.levels.INFO)
            return
        end
    end

    -- Build tatr new command
    local args = { "new" }

    -- Add title (quoted to handle spaces)
    table.insert(args, string.format('"%s"', title))

    -- Add priority
    local priority = opts.priority or M.config.default_priority
    if priority ~= 0 then
        table.insert(args, "-p")
        table.insert(args, tostring(priority))
    end

    -- Add tags
    if opts.tags and #opts.tags > 0 then
        table.insert(args, "-t")
        table.insert(args, table.concat(opts.tags, ","))
    end

    -- Add status
    local status = opts.status or M.config.default_status
    if status ~= "OPEN" then
        table.insert(args, "-s")
        table.insert(args, status)
    end

    -- Execute command
    local output, error_msg = execute_tatr(args)
    if error_msg then
        vim.notify(error_msg, vim.log.levels.ERROR)
        return
    end

    vim.notify(output or "Task created", vim.log.levels.INFO)
end

---List tasks
---@param opts table? Options for listing tasks
M.list = function(opts)
    opts = opts or {}

    -- Build tatr ls command
    local args = { "ls" }

    -- Add sort option
    if opts.sort then
        table.insert(args, "-s")
        table.insert(args, opts.sort)
    end

    -- Execute command
    local output, error_msg = execute_tatr(args)
    if error_msg then
        vim.notify(error_msg, vim.log.levels.ERROR)
        return
    end

    -- Try to use telescope if available
    local ok_telescope, telescope_ok = pcall(function()
        local ok, pickers = pcall(require, "telescope.pickers")
        if not ok then
            return false
        end
        local ok2, finders = pcall(require, "telescope.finders")
        if not ok2 then
            return false
        end
        local ok3, conf = pcall(require, "telescope.config")
        if not ok3 then
            return false
        end
        local ok4, actions = pcall(require, "telescope.actions")
        if not ok4 then
            return false
        end
        local ok5, action_state = pcall(require, "telescope.actions.state")
        if not ok5 then
            return false
        end

        -- Parse output into lines
        local lines = vim.split(output or "", "\n")
        local entries = {}
        for _, line in ipairs(lines) do
            if line ~= "" then
                table.insert(entries, line)
            end
        end

        if #entries == 0 then
            vim.notify("No tasks found", vim.log.levels.INFO)
            return true
        end

        -- Create telescope picker
        pickers
            .new({}, {
                prompt_title = "Tasks",
                finder = finders.new_table({
                    results = entries,
                }),
                sorter = conf.values.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        if selection then
                            -- Extract file path from line
                            local file_path = selection[1]:match("^([^:]+)")
                            if file_path then
                                vim.cmd("edit " .. file_path)
                            end
                        end
                    end)
                    return true
                end,
            })
            :find()

        return true
    end)

    -- If telescope is not available or failed, use quickfix
    if not ok_telescope or not telescope_ok then
        local lines = vim.split(output or "", "\n")
        local qf_list = {}

        for _, line in ipairs(lines) do
            if line ~= "" then
                -- Parse line format: /path/to/file.md: [PRIORITY: X, TAGS: y] Title
                local file_path = line:match("^([^:]+)")
                if file_path then
                    table.insert(qf_list, {
                        filename = file_path,
                        text = line,
                    })
                end
            end
        end

        if #qf_list == 0 then
            vim.notify("No tasks found", vim.log.levels.INFO)
            return
        end

        vim.fn.setqflist(qf_list)
        vim.cmd("copen")
    end
end

---Parse task line to extract HUID and title
---@param line string Task line from tatr ls output
---@return string? huid Task HUID (timestamp)
---@return string? title Task title
local function parse_task_line(line)
    -- Format: /path/to/tasks/HUID/TASK.md: [PRIORITY: X, TAGS: y] Title
    -- Extract HUID from path
    local huid = line:match("/(%d+%-%d+)/TASK%.md:")
    if not huid then
        return nil, nil
    end

    -- Extract title (everything after the closing bracket and space)
    local title = line:match("%]%s+(.+)$")
    if not title then
        return nil, nil
    end

    return huid, title
end

---Get comment string for current buffer filetype
---@return string comment_string Comment string for the filetype
local function get_comment_string()
    -- Get commentstring option (e.g., "// %s" or "# %s")
    local commentstring = vim.bo.commentstring

    -- Extract the comment prefix (before %s)
    local comment_prefix = commentstring:match("^(.-)%%s")
    if comment_prefix then
        -- Remove trailing space if present
        comment_prefix = vim.trim(comment_prefix)
        return comment_prefix
    end

    -- Default to // if commentstring is not set
    return "//"
end

---Insert task as TODO comment at current line
---@param opts table? Options for inserting task
M.insert = function(opts)
    opts = opts or {}

    -- Build tatr ls command
    local args = { "ls" }

    -- Add sort option
    if opts.sort then
        table.insert(args, "-s")
        table.insert(args, opts.sort)
    end

    -- Execute command
    local output, error_msg = execute_tatr(args)
    if error_msg then
        vim.notify(error_msg, vim.log.levels.ERROR)
        return
    end

    -- Try to use telescope if available
    local ok_telescope, telescope_ok = pcall(function()
        local ok, pickers = pcall(require, "telescope.pickers")
        if not ok then
            return false
        end
        local ok2, finders = pcall(require, "telescope.finders")
        if not ok2 then
            return false
        end
        local ok3, conf = pcall(require, "telescope.config")
        if not ok3 then
            return false
        end
        local ok4, actions = pcall(require, "telescope.actions")
        if not ok4 then
            return false
        end
        local ok5, action_state = pcall(require, "telescope.actions.state")
        if not ok5 then
            return false
        end

        -- Parse output into lines
        local lines = vim.split(output or "", "\n")
        local entries = {}
        for _, line in ipairs(lines) do
            if line ~= "" then
                table.insert(entries, line)
            end
        end

        if #entries == 0 then
            vim.notify("No tasks found", vim.log.levels.INFO)
            return true
        end

        -- Create telescope picker
        pickers
            .new({}, {
                prompt_title = "Insert Task as TODO Comment",
                finder = finders.new_table({
                    results = entries,
                }),
                sorter = conf.values.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        if selection then
                            local line = selection[1]
                            local huid, title = parse_task_line(line)

                            if not huid or not title then
                                vim.notify(
                                    "Failed to parse task line",
                                    vim.log.levels.ERROR
                                )
                                return
                            end

                            -- Get current buffer and cursor position
                            local buffer = vim.api.nvim_get_current_buf()
                            local cursor_line =
                                vim.api.nvim_win_get_cursor(0)[1]

                            -- Get comment string for current filetype
                            local comment_str = get_comment_string()

                            -- Build TODO comment
                            local todo_comment = string.format(
                                "%s TODO(%s): %s",
                                comment_str,
                                huid,
                                title
                            )

                            -- Get current line content and indentation
                            local current_line_content =
                                vim.api.nvim_buf_get_lines(
                                    buffer,
                                    cursor_line - 1,
                                    cursor_line,
                                    false
                                )[1]
                            local indent = current_line_content:match("^%s*")
                                or ""

                            -- Insert the TODO comment with proper indentation
                            vim.api.nvim_buf_set_lines(
                                buffer,
                                cursor_line - 1,
                                cursor_line - 1,
                                false,
                                { indent .. todo_comment }
                            )

                            vim.notify(
                                "Inserted TODO comment",
                                vim.log.levels.INFO
                            )
                        end
                    end)
                    return true
                end,
            })
            :find()

        return true
    end)

    -- If telescope is not available, show error
    if not ok_telescope or not telescope_ok then
        vim.notify(
            "TatrInsert requires telescope.nvim to be installed",
            vim.log.levels.ERROR
        )
        return
    end
end

---Health check
M.health = function()
    return require("tatr.health").check()
end

return M
