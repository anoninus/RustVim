local runner_buf = nil
local prev_buf   = nil
local runner_win = nil
local split_height = 15  -- default height, user can resize

local function get_run_cmd()
    local ft        = vim.bo.filetype
    local file_dir  = vim.fn.expand('%:p:h')
    local file_name = vim.fn.expand('%:t')
    local root      = vim.fn.expand('%:t:r')

    local cmds = {
        rust       = 'cargo run',
        go         = 'go run .',
        python     = 'python3 '  .. file_name,
        lua        = 'lua '      .. file_name,
        javascript = 'node '     .. file_name,
        typescript = 'ts-node '  .. file_name,
        ruby       = 'ruby '     .. file_name,
        php        = 'php '      .. file_name,
        bash       = 'bash '     .. file_name,
        sh         = 'bash '     .. file_name,
        zig        = 'zig build-exe ' .. file_name,
        c          = 'gcc '  .. file_name .. ' -o ' .. root .. ' && ./' .. root,
        cpp        = 'g++ '  .. file_name .. ' -o ' .. root .. ' && ./' .. root,
        java       = 'javac ' .. file_name .. ' && java ' .. root,
    }

    local cmd = cmds[ft]
    if not cmd then
        vim.notify('No runner for filetype: ' .. ft, vim.log.levels.WARN)
        return nil, nil
    end

    return file_dir, cmd
end

local function open_split_terminal()
    -- Save current window to return focus later
    prev_buf = vim.api.nvim_get_current_buf()

    -- Kill stale buffer
    if runner_buf and vim.api.nvim_buf_is_valid(runner_buf) then
        vim.api.nvim_buf_delete(runner_buf, { force = true })
    end

    -- ✅ THE FIX: open a proper bottom split, then launch terminal inside it
    vim.cmd('botright ' .. split_height .. 'split')
    vim.cmd('terminal')

    runner_win = vim.api.nvim_get_current_win()
    runner_buf = vim.api.nvim_get_current_buf()

    -- Clean terminal buffer: no line numbers, no sign column
    vim.wo[runner_win].number         = false
    vim.wo[runner_win].relativenumber = false
    vim.wo[runner_win].signcolumn     = 'no'
    vim.bo[runner_buf].buflisted      = false

    return runner_win, runner_buf
end

local function run_code()
    local file_dir, cmd = get_run_cmd()
    if not cmd then return end

    open_split_terminal()

    vim.defer_fn(function()
        local chan = vim.bo[runner_buf].channel
        if chan and chan > 0 then
            vim.fn.chansend(chan, 'cd ' .. vim.fn.shellescape(file_dir) .. '\n')
            vim.fn.chansend(chan, 'clear\n')
            vim.fn.chansend(chan, cmd .. '\n')
        end
    end, 80)
end

local function toggle_runner()
    if not (runner_buf and vim.api.nvim_buf_is_valid(runner_buf)) then
        vim.notify('No runner session yet. Use <leader>zz first.', vim.log.levels.INFO)
        return
    end

    -- If the runner window is currently visible, close it
    if runner_win and vim.api.nvim_win_is_valid(runner_win) then
        local cur = vim.api.nvim_get_current_win()
        if cur == runner_win then
            -- We're inside the terminal — go back to code
            vim.api.nvim_win_hide(runner_win)
            runner_win = nil
        else
            -- Focus the terminal window
            vim.api.nvim_set_current_win(runner_win)
            vim.cmd('startinsert')
        end
    else
        -- Re-open the split and reuse the existing terminal buffer
        vim.cmd('botright ' .. split_height .. 'split')
        vim.api.nvim_win_set_buf(0, runner_buf)
        runner_win = vim.api.nvim_get_current_win()

        vim.wo[runner_win].number         = false
        vim.wo[runner_win].relativenumber = false
        vim.wo[runner_win].signcolumn     = 'no'

        vim.cmd('startinsert')
    end
end

-- Resize keymaps (only active when cursor is in the terminal split)
-- Increase/decrease height with <C-Up> / <C-Down> from normal mode
vim.keymap.set('n', '<C-Up>', function()
    if runner_win and vim.api.nvim_win_is_valid(runner_win) then
        split_height = split_height + 2
        vim.api.nvim_win_set_height(runner_win, split_height)
    end
end, { silent = true, desc = 'Runner: increase height' })

vim.keymap.set('n', '<C-Down>', function()
    if runner_win and vim.api.nvim_win_is_valid(runner_win) then
        split_height = math.max(5, split_height - 2)
        vim.api.nvim_win_set_height(runner_win, split_height)
    end
end, { silent = true, desc = 'Runner: decrease height' })

vim.keymap.set('n', '<leader>zz', run_code,      { silent = true, desc = 'Run code' })
vim.keymap.set('n', '<leader>zx', toggle_runner, { silent = true, desc = 'Toggle code runner' })
