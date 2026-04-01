# tatr.nvim

Neovim plugin for [tatr](https://github.com/alexjercan/tatr) - a simple task tracker.

## Features

- Create new tasks from within Neovim
- List and browse tasks with Telescope integration (falls back to quickfix list)
- Configurable default priority and status
- Health check integration

## Requirements

- Neovim >= 0.9
- [tatr](https://github.com/alexjercan/tatr) CLI tool installed and available in PATH
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional, for better task browsing)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "alexjercan/tatr.nvim",
    config = function()
        require("tatr").setup({
            -- Optional: customize tatr command path
            -- tatr_cmd = "tatr",

            -- Optional: default priority for new tasks
            -- default_priority = 0,

            -- Optional: default status for new tasks
            -- default_status = "OPEN",
        })
    end,
    dependencies = {
        "nvim-telescope/telescope.nvim", -- optional
    },
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    "alexjercan/tatr.nvim",
    config = function()
        require("tatr").setup()
    end,
    requires = {
        "nvim-telescope/telescope.nvim", -- optional
    },
}
```

## Usage

### Commands

#### `:TatrNew [title]`

Create a new task. If no title is provided, you will be prompted to enter one.

Examples:
```vim
:TatrNew
:TatrNew Implement new feature
```

#### `:TatrList [sort]`

List all tasks. Opens in Telescope if available, otherwise uses quickfix list.

Optional sort parameter: `created`, `priority`, or `title` (default: `created`)

Examples:
```vim
:TatrList
:TatrList priority
:TatrList title
```

#### `:TatrInsert [sort]`

Insert a task as a TODO comment at the current line. Opens a Telescope picker to select a task, then inserts a comment in the format:

```
// TODO(HUID): Task title
```

The comment string is automatically detected based on the current file's `commentstring` setting (e.g., `//` for JavaScript, `#` for Python, `--` for Lua).

Optional sort parameter: `created`, `priority`, or `title` (default: `created`)

Examples:
```vim
:TatrInsert
:TatrInsert priority
```

**Note:** This command requires [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) to be installed.

#### `:TatrSetup`

Reload the plugin configuration.

### Lua API

You can also use the Lua API directly:

```lua
-- Create a new task
require("tatr").new({
    title = "Task title",
    priority = 50,
    tags = {"feature", "bug"},
    status = "OPEN",  -- or "IN_PROGRESS", "CLOSED"
})

-- List tasks
require("tatr").list({
    sort = "priority",  -- or "created", "title"
})

-- Insert task as TODO comment
require("tatr").insert({
    sort = "priority",  -- or "created", "title"
})
```

### Configuration

```lua
require("tatr").setup({
    -- Path to tatr command (default: "tatr")
    tatr_cmd = "tatr",

    -- Default priority for new tasks (default: 0)
    default_priority = 0,

    -- Default status for new tasks (default: "OPEN")
    -- Valid values: "OPEN", "IN_PROGRESS", "CLOSED"
    default_status = "OPEN",
})
```

### Example Keybindings

Add these to your Neovim configuration:

```lua
-- Create a new task
vim.keymap.set("n", "<leader>tn", "<cmd>TatrNew<cr>", {
    desc = "Create new task",
})

-- List tasks
vim.keymap.set("n", "<leader>tl", "<cmd>TatrList<cr>", {
    desc = "List tasks",
})

-- List tasks sorted by priority
vim.keymap.set("n", "<leader>tp", "<cmd>TatrList priority<cr>", {
    desc = "List tasks by priority",
})

-- Insert task as TODO comment
vim.keymap.set("n", "<leader>ti", "<cmd>TatrInsert<cr>", {
    desc = "Insert task as TODO comment",
})
```

## Health Check

Run `:checkhealth tatr` to verify your installation and configuration.

## License

MIT
