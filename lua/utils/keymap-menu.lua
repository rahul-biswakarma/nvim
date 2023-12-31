-- Define the function to show the main menu
function ShowMainMenu()
    local items = {{title = '1. NeoTree', action = ShowNeoTreeMenu}}

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
        '09. Show File details: i', "10.  Switch Tabs: < >",
        "11. Close node: C", "12. Open in Vertical Split: s",
        "13. Open in Horizontal Split: S"
    }
    vim.ui.select(items, {prompt = 'NeoTree Menu'}, function() end)
end

-- Map the function to the keybind <leader>\
vim.api.nvim_set_keymap('n', '<leader>\\', '<cmd>lua ShowMainMenu()<CR>',
                        {noremap = true, silent = true})
