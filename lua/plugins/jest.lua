return {
	"mattkubej/jest.nvim",
	config = function()
		require("nvim-jest").setup({
			silent = true,
		})
	end,
}
