-- Define the function to show the main menu
function ShowMainMenu()
    local items = {
        {title = '1. NeoTree', action = ShowNeoTreeMenu},
        {title = '2. LazyGit', action = ShowLazyGitMenu}
    }

    local labels = {}
    for _, item in ipairs(items) do table.insert(labels, item.title) end

    vim.ui.select(labels, {prompt = 'Keymap Menu'}, function(selected)
        for _, item in ipairs(items) do
            if selected == item.title then item.action() end
        end
    end)
end

-- Define the function to show the NeoTree menu
function ShowNeoTreeMenu()
    local items = {
        '01. Open NeoTree: <leader>o', '02. Close NeoTree: q',
        '03. Add File/Directory: a', '04. Delete File/Directory: d',
        '05. Rename File/Directory: r', '06. Copy File/Directory: y',
        '07. Paste File/Directory: p', '08. Refresh NeoTree: R',
        '09. Show File details: i', "10. Switch Tabs: < >", "11. Close node: C",
        "12. Open in Vertical Split: s", "13. Open in Horizontal Split: S"
    }
    vim.ui.select(items, {prompt = 'NeoTree Menu'}, function() end)
end

function ShowLazyGitMenu()
    local items = {
        '01. Open LazyGit: <leader>gg', '02. Close LazyGit: q',
        '03. Stage Changes: <space>', '04. Inc./Dec. Context size : { }',
        '05. Commit: c', '06. Push: P', '07. Pull: p', '08. Search: /',
        '09. Discard changes: d', "10. New Branch: b",
        "11. Pull Request open/options: o, O",
        "12. Copy pull-request url: <c-y>", "13. Open Keybinds: ?"
    }
    vim.ui.select(items, {prompt = 'LazyGit Menu'}, function() end)
end

-- Map the function to the keybind <leader>\
vim.api.nvim_set_keymap('n', '<leader>\\', '<cmd>lua ShowMainMenu()<CR>',
                        {noremap = true, silent = true})
