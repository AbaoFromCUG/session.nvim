local file = require("session.file")
---@class session
---@field config session.Configuration
local M = {}

---@class session.Configuration
---@field enabled? boolean
---@field hooks? table<session.Chance, table<string, function>>

---@type session.Configuration
M.config = {
    enabled = true,
    hooks = {
        pre_save = {},
        extra_save = {},
        post_save = {},
        pre_restore = {},
        post_restore = {},
    },
}

---@class session.InternalState
---@field started_with_stdin boolean

---@type session.InternalState
M._state = {
    started_with_stdin = false,
}

---setup session.nvim
---@param config? session.Configuration
function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config or {})
end

---comment
function M._enabled()
    return M.config.enabled and not M._state.started_with_stdin and vim.fn.argc() == 0
end

---@alias session.Chance 'pre_save'|'extra_save'|'post_save'|'pre_restore'|'post_restore'

---register a hook, when specific time, which will be called
---@param when session.Chance
---@param identifier string identify specific hook
---@param handle function the called handle
function M.register_hook(when, identifier, handle)
    if M.config.hooks[when] then
        M.config.hooks[when][identifier] = handle
    else
        vim.notify("Unknown chance " .. when, vim.log.levels.WARN, {
            title = "Session",
        })
    end
end

---run all hooks
---@param when session.Chance
---@return any[]
function M.execute_hooks(when)
    local result = {}
    for key, hook in pairs(M.config.hooks[when]) do
        local status, value = pcall(hook)
        if status then
            table.insert(result, value)
        else
            vim.notify(string.format("Run hook %s on % faild: %s", key, when, value), vim.log.levels.ERROR, {
                title = "Session",
            })
        end
    end
    return result
end

function M.restore_session(session_file)
    session_file = session_file or file.get_session_file()
    if vim.fn.filereadable(session_file) == 0 then
        return
    end
    M.execute_hooks("pre_restore")
    vim.cmd("silent source " .. session_file)
    M.execute_hooks("post_restore")
end

function M.delete_session(dir) end

function M.save_session()
    local session_file, xsesssion_file = file.get_session_file()
    M.execute_hooks("pre_save")
    vim.cmd("mksession! " .. session_file)
    local result = M.execute_hooks("extra_save")
    vim.fn.writefile(result, xsesssion_file)
    M.execute_hooks("post_save")
end

function M.get_session_list()
    local session_files = vim.fn.glob(file.get_session_dir() .. "/*_.vim", true, true)
    local session_list = {}

    for _, session_file in ipairs(session_files) do
        local filename = vim.fs.basename(session_file)
        local name = filename:match("([%w_]+)_.vim")
        local raw_path = file.unescape_path(name)
        table.insert(session_list, raw_path)
    end
    return session_list
end

return M
