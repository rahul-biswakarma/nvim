--[[
  MCP Hub - MCP Client for Neovim
  
  Manages MCP servers and provides access to Chrome tabs for browser context tracking.
  Integrates with buddy system to provide browser context.
  
  Setup:
  1. Install MCP Hub globally: npm install -g mcp-hub@latest
  2. Install Chrome tabs MCP server: npm i @pokutuna/mcp-chrome-tabs
  3. Configuration is handled via ~/.config/mcphub/config.json
  4. Example config:
     {
       "mcpServers": {
         "chrome-tabs": {
           "command": "npx",
           "args": ["-y", "@pokutuna/mcp-chrome-tabs@latest"]
         }
       }
     }
]]

return {
  'ravitemer/mcphub.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('mcphub').setup({
      -- Configuration is in ~/.config/mcphub/config.json
      -- Chrome tabs MCP server should be configured there as:
      -- {
      --   "mcpServers": {
      --     "chrome-tabs": {
      --       "command": "npx",
      --       "args": ["-y", "@pokutuna/mcp-chrome-tabs@latest"]
      --     }
      --   }
      -- }
      -- 
      -- Prerequisites:
      -- 1. Install MCP Hub: npm install -g mcp-hub@latest
      -- 2. Install Chrome tabs server: npm i @pokutuna/mcp-chrome-tabs
    })
  end,
}

