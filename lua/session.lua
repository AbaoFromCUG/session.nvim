local path = require("session.path")

---@class session
---@field config session.Configuration
local M = {}

---@class session.Configuration
---@field enabled? boolean
---@field silent_restore? boolean # silent restore, may cause confusion
---@field hooks? table<session.Chance, table<string, function>>

---@type session.Configuration
M.config = {
    enabled = true,
    silent_restore = true,
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

    if not M.config.enabled then
        return
    end

    M.register_hook("pre_restore", "close_unrelated_buffers", function(old, new)
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            local buf_file = vim.api.nvim_buf_get_name(bufnr)
            if buf_file:match(old) then
                vim.api.nvim_buf_delete(bufnr, { force = false })
            end
        end
    end)
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
function M.execute_hooks(when, ...)
    local result = {}
    for key, hook in pairs(M.config.hooks[when]) do
        local status, value = pcall(hook, ...)
        if status then
            table.insert(result, value)
        else
            vim.notify(string.format("Run hook %s on %s faild: %s", key, when, value), vim.log.levels.ERROR, {
                title = "Session",
            })
        end
    end
    return result
end

function M.restore_session(dir)
    local session_file = path.get_session_file(dir)
    if vim.fn.filereadable(session_file) == 0 then
        return
    end
    M.execute_hooks("pre_restore", vim.fn.getcwd(), dir)
    if M.config.silent_restore then
        vim.cmd("silent source " .. session_file)
    else
        vim.cmd("source " .. session_file)
    end
    M.execute_hooks("post_restore", dir)
end

function M.delete_session(dir)
    local session_file = path.get_session_file(dir)
    if not vim.fn.filereadable(session_file) then
        vim.notify("session file note exists", vim.log.levels.ERROR, {
            title = "Session",
        })
        return
    end
    local name = session_file:match("(.+)_.vim")
    local xfile = string.format("%s_x.vim", name)
    vim.loop.fs_unlink(session_file)
    vim.loop.fs_unlink(xfile)
end

function M.save_session()
    local session_file, xsesssion_file = path.get_session_file()
    M.execute_hooks("pre_save")
    vim.cmd("mksession! " .. session_file)
    local result = M.execute_hooks("extra_save")
    vim.fn.writefile(result, xsesssion_file)
    M.execute_hooks("post_save")
end

---@class session.Session
---@field work_directory string
---@field session_file string
---@field name? string

---get session list
---@return session.Session[]
function M.get_session_list()
    local session_files = vim.fs.find(function(name)
        return name:match("[%w_]+_.vim")
    end, { path = path.get_session_root(), limit = math.huge, type = "file" })
    local session_list = {}

    for _, session_file in ipairs(session_files) do
        local filename = vim.fs.basename(session_file)
        local name = filename:match("([%w_]+)_.vim")
        local raw_path = path.unescape_path(name)
        table.insert(session_list, {
            work_directory = raw_path,
            session_file = session_file,
            name = vim.fs.basename(raw_path),
        })
    end
    local find_one = true
    while find_one do
        find_one = false
        for _, sess in ipairs(session_list) do
            local same_list = vim.tbl_filter(function(other)
                return other.name == sess.name
            end, session_list)
            if #same_list > 1 then
                find_one = true
                vim.tbl_map(function(one)
                    local parent_dir = one.work_directory:sub(1, #one.work_directory - #one.name - 1)
                    one.name = path.join(vim.fs.basename(parent_dir), one.name)
                end, same_list)
            end
        end
    end
    return session_list
end

return M
