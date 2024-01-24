local session = require("session")
local cmds = require("session.command")

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
    local cmd = cmds[opts.fargs[1]]
    if cmd ~= nil then
        table.remove(opts.fargs, 1)
        cmd.execute(unpack(opts.fargs))
    end
end, {
    desc = "Session/Project Manager",
    nargs = "*",
    complete = function(_, line, _)
        local l = vim.split(line, "%s+")
        local n = #l - 2
        if n == 0 then
            return vim.tbl_filter(function(val)
                return vim.startswith(val, l[2])
            end, vim.tbl_keys(cmds))
        elseif n == 1 and cmds[l[2]] ~= nil then
            local cmd = cmds[l[2]]
            local condition = {}
            if type(cmd["complete"]) == "function" then
                condition = cmd.complete()
            elseif type(cmd["complete"]) == "table" then
                condition = cmd.complete --[[@as table]]
            end
            return vim.tbl_filter(function(val)
                return vim.startswith(val, l[3])
            end, condition)
        end
    end,
})
