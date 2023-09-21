local session = require("session")
-- require("")

local M = {
    load = {
        run = function(args)
            local session_list
        end,
        complete = session.get_session_list,
    },
    delete = {
        run = function(item)
            if item ~= nil then
                vim.ui.select(session.get_session_list(), {
                    title = "Delete Session",
                }, function(selected)
                    session.delete_session(selected)
                end)
            else
                session.delete_session(selected)
            end
        end,
        complete = session.get_session_list,
    },
}

setmetatable(M, {
    __call = function() end,
})

return M
