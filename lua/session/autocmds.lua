local group = vim.api.nvim_create_augroup("Session", {})

local function autocmd_or_restore()
    local session = require("session")

    local function restore_session()
        if session._enabled() then
            session.restore_session()
        end
    end

    vim.api.nvim_create_autocmd("StdinReadPre", {
        group = group,
        callback = function()
            session._state.started_with_stdin = true
        end,
    })

    if vim.v.vim_did_enter == 1 then
        vim.schedule(restore_session)
    else
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            nested = true,
            callback = restore_session,
        })
    end

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            if session._enabled() then
                session.save_session()
            end
        end,
    })
end

return autocmd_or_restore
