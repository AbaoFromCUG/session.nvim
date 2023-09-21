local Path = require("plenary.path")

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

---get session dir, default `stdpath('state)/session`
---@return string path
function M.get_session_dir()
    local path = Path:new(vim.fn.stdpath("state"), "session")
    local path = vim.fn.stdpath("state") .. "/" .. "session"
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path)
    end
    return path
end

---get session file by dir_path, default is current work directory
---@param dir_path? string
---@return string, string
function M.get_session_file(dir_path)
    dir_path = dir_path or vim.fn.getcwd(0) --[[@as string]]
    local name = M.escape_path(dir_path)
    local path = string.format("%s/%s_.vim", M.get_session_dir(), name)
    local xpath = string.format("%s/%s_x.vim", M.get_session_dir(), name)
    return path, xpath
end

return M
