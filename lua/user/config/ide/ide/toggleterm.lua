vim.api.nvim_create_autocmd('TermOpen', {
    pattern = 'term://*',
    callback = function()
        local opts = { buffer = 0 }

        vim.keymap.set('t', '<End>', [[<C-\><C-n>G]], opts)
        vim.keymap.set('t', '<M-q>', '<cmd>close<CR>', opts)

        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end,
})

local term_buf  = nil
local term_win  = nil
local term_height = 15

local function toggle_terminal()
    -- ── Case 1: split is visible ─────────────────────────────────────────
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        local cur_win = vim.api.nvim_get_current_win()
        if cur_win == term_win then
            -- focused on terminal → hide the split, go back to previous win
            vim.api.nvim_win_hide(term_win)
        else
            -- focused elsewhere → jump into the terminal
            vim.api.nvim_set_current_win(term_win)
            vim.cmd('startinsert')
        end
        return
    end

    -- ── Case 2: buffer exists but window was closed → reopen the split ───
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        vim.cmd('botright ' .. term_height .. 'split')
        vim.api.nvim_win_set_buf(0, term_buf)
        term_win = vim.api.nvim_get_current_win()

        vim.wo[term_win].number         = false
        vim.wo[term_win].relativenumber = false
        vim.wo[term_win].signcolumn     = 'no'

        vim.cmd('startinsert')
        return
    end

    -- ── Case 3: first launch → create split + terminal ───────────────────
    vim.cmd('botright ' .. term_height .. 'split')
    vim.cmd('terminal')

    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()

    vim.wo[term_win].number         = false
    vim.wo[term_win].relativenumber = false
    vim.wo[term_win].signcolumn     = 'no'
    vim.bo[term_buf].buflisted      = false

    vim.cmd('startinsert')
end

-- Resize from any window (adjusts the terminal split height)
vim.keymap.set('n', '<C-Up>', function()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        term_height = term_height + 2
        vim.api.nvim_win_set_height(term_win, term_height)
    end
end, { silent = true, desc = 'Terminal: increase height' })

vim.keymap.set('n', '<C-Down>', function()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        term_height = math.max(5, term_height - 2)
        vim.api.nvim_win_set_height(term_win, term_height)
    end
end, { silent = true, desc = 'Terminal: decrease height' })

vim.keymap.set('n', '<leader>tt', toggle_terminal, { desc = 'Toggle terminal' })
