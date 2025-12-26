# Session.nvim

## Install

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua

{
    "AbaoFromCUG/session.nvim",
    opts = {
        silent_restore = false,
        hooks = {
            pre_save = {
                close_all_floating_wins = function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local config = vim.api.nvim_win_get_config(win)
                        if config.relative ~= "" then
                            vim.api.nvim_win_close(win, false)
                        end
                    end
                end,
            },
            extra_save = {
                -- the result of hook will be saved to `x.vim`(extra session file), read `:help :mksession` for more info
                notify_after_restore = function() return [[lua vim.notify("Session restored!", vim.log.levels.INFO)]] end,
            },
            post_save = {},
            pre_restore = {},
            post_restore = {},
        },
    },
    -- StdinReadPre for avoid session restore conflict when vim started with stdin input, e.g. `cat README.md | nvim -`
    event = { "VeryLazy", "StdinReadPre" },
}
```

## Setup

Default configuration

```lua

---@type session.Configuration
local config = {
    silent_restore = true,  -- silent restore session, maybe cause confusion if you log in autocmd(e.g. BufWinEnter)
    hooks = {
        pre_save = {},
        extra_save = {},
        post_save = {},
        pre_restore = {},
        post_restore = {},
    },
}

require("sesion").setup(config)

```

### Hooks type

* `pre_save` will called before save session
* `extra_save` will called after save session. Hook can return vim cmd which will be called when last reopen session automatically
* `post_save` will called after `extra_save`
* `pre_restore` will called before restore session
* `post_restore` will called after restore session

You can use hook ability via two methods, `setup` and `register`, they are equivalent.

### Register hooks (Static)

```lua

---@type session.Configuration
local config = {
    hooks = {
        pre_save = {
            my_pre_save = function() 
                --some code
            end
        },
        extra_save = {
            my_extra_save = function()
                return [[lua vim.notify("hello")]]
            end,
        },
        post_save = {},
        pre_restore = {},
        post_restore = {},
    },
}

require("sesion").setup(config)


```

### Register hooks (Dynamic)

```lua
local session = require("session")
session.register_hook("extra_save", "my_extra_save", function()
    return [[lua vim.notify("hello")]]
end)

session.register_hook("post_restore", "my_post_restore", function()
    vim.notify("world")
end)

```

## Integrate

**[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim/)**

`session.nvim` support integrate with `telescop.nvim`, use `:Telescope session` to list session

```lua
local telescope = require("telescope")
telescope.load_extension("session")
```

## Acknowledges

* [auto-sesion](https://github.com/rmagatti/auto-session): a powerful and rich with features session manager
