local M = {}

---escape file path
---@param path string file path
---@return string
function M.escape_path(path)
    local escaped = string.gsub(path, "([^a-zA-Z])", function(c)
        return string.format("_%02X", string.byte(c))
    end)
    return escaped
end

---unescape name to file path
---@param name string
---@return string
function M.unescape_path(name)
    local unescaped = string.gsub(name, "_(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
    return unescaped
end

function M.join(...)
    local args = { ... }
    if vim.loop.os_uname().sysname == "Windows_NT" then
        return vim.fn.join(args, "\\")
    else
        return vim.fn.join(args, "/")
    end
end

---get session dir, default `stdpath('state)/session`
---@return string path
function M.get_session_root()
    local path = M.join(vim.fn.stdpath("state"), "session")
    if not vim.fn.isdirectory(path) then
        vim.fn.mkdir(path)
    end
    return path
end

---get session file by dir_path, default is current work directory
---@param dir_path? string
---@return string, string
function M.get_session_file(dir_path)
    dir_path = dir_path or vim.fn.getcwd() --[[@as string]]
    local name = M.escape_path(dir_path)
    local session_root = M.get_session_root()
    local path = M.join(session_root, string.format("%s_.vim", name))
    local xpath = M.join(session_root, string.format("%s_x.vim", name))
    return path, xpath
end

return M
