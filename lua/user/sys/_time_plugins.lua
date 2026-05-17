-- Enable Lua module caching
vim.loader.enable()

-- =====================
-- (1) Bootstrap lazy.nvim
-- =====================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =====================
-- TRACKS TIME
-- =====================
local spec_times = {}

local function timed_spec(mod)
    local t = vim.uv.hrtime()
    require(mod)
    local elapsed = (vim.uv.hrtime() - t) / 1e6
    table.insert(spec_times, { mod = mod, ms = elapsed })
    package.loaded[mod] = nil  -- clear cache so lazy can load it normally
    return mod
end
-- =====================
-- Plugins (lazy.nvim)
-- =====================
require('lazy').setup({
    spec = {
    { import = timed_spec('user.specs.core') },
    { import = timed_spec('user.specs.snippets') },
    { import = timed_spec('user.specs.completion') },
    { import = timed_spec('user.specs.lsp') },
    { import = timed_spec('user.specs.formatting') },
    { import = timed_spec('user.specs.dap') },
    { import = timed_spec('user.specs.ui') },
    { import = timed_spec('user.specs.treesitter') },
    { import = timed_spec('user.specs.explorer') },
    { import = timed_spec('user.specs.editor') },
    { import = timed_spec('user.specs.utility') },
    { import = timed_spec('user.specs.session') },
    { import = timed_spec('user.specs.mini') },
    { import = timed_spec('user.specs.colorschemes') },
    },

    -- ============================
    -- Configuration
    -- ============================
    concurrency = 5,

    git = {
        timeout = 300,
        url_format = 'https://github.com/%s.git',
    },

    install = {
        missing = false,
        -- colorscheme = { 'habamax' },
    },

    rocks = {
        enabled = false,
        hererocks = false,
    },

    checker = {
        enabled = false,
        notify = false,
        frequency = 3600,
    },

    change_detection = {
        enabled = false,
        notify = false,
    },

    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            paths = {},
            disabled_plugins = {
                'gzip',
                'matchit',
                'matchparen',
                'netrwPlugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
            },
        },
    },

    defaults = {
        lazy = true,
        version = false,
    },

    ui = {
        size = { width = 0.88, height = 0.9 },
        wrap = true,
        title = '   Lazy Plugin Manager ',
        backdrop = 70,
        icons = {
            cmd        = '󰘳 ',
            config     = '󰒓 ',
            event      = '󰚌 ',
            ft         = '󰈙 ',
            init       = '󰒓 ',
            import     = '󰋺 ',
            keys       = '󰌌 ',
            lazy       = '󰒲 ',
            loaded     = '󰄬 ',
            not_loaded = '󰄱 ',
            plugin     = '󰂖 ',
            runtime    = '󰆦 ',
            source     = '󰉋 ',
            start      = '󰐊 ',
            task       = '󰆕 ',
            list       = { '󰬪', '󰬜', '󰬐', '󰬅' },
        }
    },
})
vim.defer_fn(function()
    table.sort(spec_times, function(a, b) return a.ms > b.ms end)
    local lines = {}
    for _, v in ipairs(spec_times) do
        table.insert(lines, string.format("%.2fms  %s", v.ms, v.mod))
    end
    local f = io.open(vim.fn.stdpath('cache') .. '/spec_times.log', 'w')
    if f then
        f:write(table.concat(lines, '\n'))
        f:close()
    end
end, 500)
