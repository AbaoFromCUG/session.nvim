# Session.nvim

# Install

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "AbaoFromCUG/session.nvim"
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "AbaoFromCUG/session.nvim"
}
```
# Setup

Default configuration
```lua

---@type session.Configuration
local config = {
    enabled = true,
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


# Useages

## Hooks

### Hooks type
* `pre_save` will called before save session
* `extra_save` will called after save session. Hook can return vim cmd which will be called when last reopen session automatically
* `post_save` will called after `extra_save`
* `pre_restore` will called before restore session
* `post_restore` will called after restore session


You can use hook ability via two methods, `setup` and `register`, they are same

### Setup hooks
```lua

---@type session.Configuration
local config = {
    enabled = true,
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

### Register hooks

```lua
local session = require("session")
session.register_hook("extra_save", "my_extra_save", function()
    return [[lua vim.notify("hello")]]
end)

session.register_hook("post_restore", "my_post_restore", function()
    vim.notify("world")
end)

```


## integrate

**[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim/)**

`session.nvim` support integrate with `telescop.nvim`, use `:Telescope session` to list session 

```lua
local telescope = require("telescope")
telescope.load_extension("session")
```



# Acknowledges

* [auto-sesion](https://github.com/rmagatti/auto-session): a powerful and rich with features session manager
