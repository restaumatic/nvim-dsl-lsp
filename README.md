# nvim-dsl-lsp

This is a Neovim plugin for interacting with a DSL language server.

## Using lazy.nvim 
```
return {
  "restaumatic/nvim-dsl-lsp",
  config = function()
    require("dsl-lsp").setup({})
  end,
}
```
