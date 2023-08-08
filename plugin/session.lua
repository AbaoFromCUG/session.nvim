local session = require("session")

if session.config.enabled then
    local group = vim.api.nvim_create_augroup("Session", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        nested = true,
        callback = function()
            session.restore_session()
        end,
    })

    vim.api.nvim_create_autocmd("VimLeave", {
        group = group,
        nested = true,
        callback = function()
            session.save_session()
        end,
    })
end
