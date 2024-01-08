---- 1. Move Selected Lines in Visual Mode ----

function _G.move_line_up()
	-- Get the range of the selected lines
	local line1 = vim.api.nvim_buf_get_mark(0, "<")[1]
	local line2 = vim.api.nvim_buf_get_mark(0, ">")[1]

	-- Check if the selected range is at the top of the file
	if line1 > 1 then
		-- Move the selected lines up
		vim.cmd(line1 .. "," .. line2 .. "m" .. line1 - 2)
		vim.cmd("normal! gv")
	end
end

function _G.move_line_down()
	-- Get the range of the selected lines
	local line1 = vim.api.nvim_buf_get_mark(0, "<")[1]
	local line2 = vim.api.nvim_buf_get_mark(0, ">")[1]

	-- Check if the selected range is at the bottom of the file
	if line2 < vim.fn.line("$") then
		-- Move the selected lines down
		vim.cmd(line1 .. "," .. line2 .. "m" .. line2 + 1)
		vim.cmd("normal! gv")
	end
end

vim.keymap.set("v", "<C-[>", ":lua move_line_up()<CR>", { noremap = true })
vim.keymap.set("v", "<C-]>", ":lua move_line_down()<CR>", { noremap = true })

---- Endo of 1 ----
