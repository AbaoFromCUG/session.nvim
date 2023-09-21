local session = require("session")
local file = require("session.file")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local action_state = require("telescope.actions.state")

---telescope-style vim.ui.select
---@param items string[]
---@param opts {prompt:string, format_item:function}
---@param on_choice fun(item)
local function select(items, opts, on_choice)
    local format_item = opts.format_item or function(item)
        return item
    end
    pickers
        .new(opts, {
            prompt_title = "colors",
            finder = finders.new_table({
                results = items,
                entry_maker = function(item)
                    local formatted = format_item(item)
                    return {
                        display = formatted,
                        ordinal = formatted,
                        value = item,
                    }
                end,
            }),
            -- sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    -- print(vim.inspect(selection))
                    print(vim.inspect(selection))
                    -- vim.aredpi.nvim_put({ selection[1] }, "", false, true)
                end)
                return true
            end,
        })
        :find()
end

local opts = {}
return require("telescope").register_extension({
    setup = function(ext_config, config) end,
    exports = {
        session = function()
            -- session.list_session(select)
        end,
    },
})
