local session = require("session")
local path = require("session.path")

local M = {
    open = function(dir)
        local session_file = path.get_session_file(dir)
        if vim.fn.filereadable(session_file) then
            session.save_session()
            session.restore_session(dir)
        else
            vim.notify(string.format("session file [%s] not exists", session_file), vim.log.levels.ERROR, { title = "Session" })
        end
    end,
    delete = function(dir)
        session.delete_session(dir)
    end,
}

return M
