local session = require("session")
local command = require("session.command")

local group = vim.api.nvim_create_augroup("Session", {})
vim.api.nvim_create_autocmd("StdinReadPre", {
    group = group,
    callback = function()
        print("StdinReadPre")
        session._state.started_with_stdin = true
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    nested = true,
    callback = function()
        if session._enabled() then
            session.restore_session()
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
        if session._enabled() then
            session.save_session()
        end
    end,
})

vim.api.nvim_create_user_command("Session", function(opts)
    local function run(cmds)
        if #cmds < 1 then
            vim.ui.select({ "open", "delete" }, { prompt = "Session" }, function(item)
                if item then
                    table.insert(cmds, item)
                    run(cmds)
                end
            end)
        elseif #cmds == 1 then
            vim.ui.select(session.get_session_list(), { prompt = "Session " .. cmds[1] }, function(item)
                if item then
                    table.insert(cmds, item)
                    run(cmds)
                end
            end)
        elseif #cmds == 2 then
            if not command[cmds[1]] then
                vim.notify(string.format("Unknown session action [%s]", cmds[1]), vim.log.levels.ERROR, { prompt = "Session" })
                return
            end
            command[cmds[1]](cmds[2])
        end
    end
    run(opts.fargs)
end, {
    desc = "Session manager",
    nargs = "*",
    complete = function(_, line, _)
        local parts = vim.split(vim.trim(line), "%s+")
        if line:match("Session open ") or line:match("Session delete ") then
            return session.get_session_list()
        end
        return { "open", "delete" }
    end,
})
