require("nvim-treesitter").install({ "qmljs" })
vim.lsp.enable("qmlls")

-- Disable semantic tokens when any LSP client attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qml" },
	callback = function()
		vim.treesitter.start()
	end,
})

require("conform").setup({
	formatters_by_ft = {
		qml = { "qmlformat" },
	},
	format_on_save = true,
})
