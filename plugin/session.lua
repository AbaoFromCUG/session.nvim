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

local function parse(args)
    local parts = vim.split(vim.trim(args), "%s+")
    table.remove(parts, 1)
    if args:sub(-1) == " " then
        parts[#parts + 1] = ""
    end
    return table.remove(parts, 1) or "", parts
end

vim.api.nvim_create_user_command("Session", function(opts)
    if #opts.fargs < 1 then
        command()
    else
        command[table.remove(opts.fargs, 1)].run(opts.fargs)
    end
end, {
    desc = "Session manager",
    nargs = "*",
    complete = function(_, line, _)
        local prefix, args = parse(line)
        if command[prefix] ~= nil then
            return command[prefix].complete()
        end
        return vim.tbl_keys(command)
    end,
})
