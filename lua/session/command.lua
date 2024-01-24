local session = require("session")
local path = require("session.path")

local M = {}

M = {
    open = {
        complete = function()
            return vim.tbl_map(function(sess)
                return sess.work_directory
            end, session.get_session_list())
        end,
        execute = function(dir)
            if dir == nil then
                vim.ui.select(session.get_session_list(), {
                    prompt = "Session open...",
                    format_item = function(item)
                        return item.work_directory
                    end,
                }, function(choice)
                    if choice ~= nil then
                        M.open.execute(choice.work_directory)
                    end
                end)
                return
            end
            local session_file = path.get_session_file(dir)
            if vim.fn.filereadable(session_file) then
                session.save_session()
                session.restore_session(dir)
            else
                vim.notify(string.format("session file [%s] not exists", session_file), vim.log.levels.ERROR, { title = "Session" })
            end
        end,
    },
    delete = {
        complete = function()
            return vim.tbl_map(function(sess)
                return sess.name
            end, session.get_session_list())
        end,
        execute = function(dir)
            if dir == nil then
                vim.ui.select(session.get_session_list(), {
                    prompt = "Session delete...",
                    format_item = function(item)
                        return item.work_directory
                    end,
                }, function(choice)
                    if choice ~= nil then
                        M.delete.execute(choice.work_directory)
                    end
                end)
                return
            end
            session.delete_session(dir)
        end,
    },
}

return M
