# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is `kckstrt!` - a personalized Neovim configuration based on kickstart.nvim. The configuration follows a modular architecture:

### Core Structure
- **init.lua**: Main configuration entry point containing basic Vim settings, keymaps, and plugin setup via lazy.nvim
- **lua/kickstart/plugins/**: Contains core plugins (autoformat, debug) from the kickstart base
- **lua/custom/plugins/**: Reserved for user-added plugins (currently empty)
- **lua/kiroku/**: Custom module for markdown note-taking functionality

### Plugin Management
- Uses **lazy.nvim** as the plugin manager
- All plugins are configured in init.lua:712-999 using lazy.nvim's declarative syntax
- Plugin configurations can use `opts = {}` for simple setups or `config = function()` for complex configurations
- Dependencies are handled automatically via the `dependencies` key

### Key Components

#### LSP Configuration (init.lua:430-714)
- **Mason**: Automatic LSP server installation and management
- **nvim-lspconfig**: LSP client configuration
- **blink.cmp**: Modern completion engine with LSP integration
- Supports: Go (gopls), Lua (lua_ls), Markdown (marksman), HTML/Templ (html, templ), TailwindCSS, Zig (zls)

#### Key Plugins
- **Telescope**: Fuzzy finder for files, LSP symbols, and more (init.lua:312-426)
- **Treesitter**: Syntax highlighting and parsing (init.lua:901-925)
- **Gitsigns**: Git integration with hunk navigation and staging (init.lua:162-235)
- **TokyoNight**: Color scheme (tokyonight-night variant)
- **Conform**: Code formatting with format-on-save (init.lua:717-756)

#### Custom Features
- **Kiroku**: Note-taking system for markdown files with frontmatter support and title insertion
- **Debugging**: DAP configuration for Go development with UI integration

## Common Development Commands

### Plugin Management
```bash
# Inside Neovim
:Lazy                    # Open lazy.nvim UI
:Lazy update            # Update all plugins
:Lazy clean             # Remove unused plugins
:Lazy sync              # Install missing and update existing plugins
```

### LSP and Development
```bash
# Inside Neovim
:Mason                  # Open Mason UI for LSP/tool management
:LspInfo               # Show attached LSP clients
:ConformInfo           # Show available formatters
:Telescope builtin     # Show all Telescope commands
:KickstartFormatToggle # Toggle autoformatting on/save
```

### Custom Commands
```bash
# Kiroku note-taking
:Kiroku new            # Create new timestamped markdown note
:Kiroku insertTitle    # Insert titles for [[wikilinks]]
```

## Key Mappings

### Leader Key: `<Space>`

### Core Navigation
- `<leader>sf`: Search files (Telescope)
- `<leader>sg`: Live grep search
- `<leader>sw`: Search current word
- `<leader><leader>`: Find buffers
- `<leader>sn`: Search Neovim config files

### LSP Mappings (when LSP attached)
- `grd`: Go to definition
- `grr`: Go to references  
- `gri`: Go to implementation
- `grn`: Rename symbol
- `gra`: Code action
- `gO`: Document symbols
- `gW`: Workspace symbols

### Git Integration
- `]c` / `[c`: Next/previous git hunk
- `<leader>hs`: Stage hunk
- `<leader>hr`: Reset hunk
- `<leader>hp`: Preview hunk
- `<leader>hb`: Git blame line

### Custom Shortcuts
- `jk`: Escape from insert mode
- `<leader>f`: Format buffer
- `<leader>w`: Save file
- `<leader>q`: Quit
- `<leader>sen`: Toggle spell check (English)

## File Types and Language Support

### Supported Languages
- **Go**: Full LSP support with gopls, debugging with delve
- **Lua**: LSP with lua_ls, formatting with stylua
- **Markdown**: LSP with marksman, preview with markdown-preview.nvim
- **HTML/Templ**: LSP support with special handling for Go's templ
- **Zig**: LSP support with zls
- **TailwindCSS**: CSS framework support

### Formatting
- Automatic formatting on save (configurable via ConformInfo)
- Language-specific formatters managed through Mason
- Format-on-save can be toggled with `:KickstartFormatToggle`

## Configuration Patterns

### Adding New Plugins
Add plugins to the lazy.nvim setup in init.lua around line 990, before the closing `})`:

```lua
-- Add new plugin
'author/plugin-name',

-- Or with configuration
{
  'author/plugin-name',
  opts = {
    -- plugin options
  },
},
```

### Adding LSP Servers
Add new servers to the `servers` table in init.lua:637-678:

```lua
local servers = {
  -- existing servers...
  new_server = {
    -- server-specific config
  },
}
```

### Custom Keymaps
Add keymaps after line 91 in init.lua or create them in plugin configurations.