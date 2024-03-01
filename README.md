# coderunner.nvim

Open terminal in a configurable split and execute commands on buffer save.

## Default configuration

```lua
  langs = {
   ruby = {
    { "ruby", "[#file]" },
   },
   lua = {
    { "lua", "[#file]" },
   },
   python = {
    { "python3", "[#file]" },
   },
   javascript = {
    { "clear" }, -- each table is a separate commands
    { "node", "[#file]" },
   },
   cpp = {
    { "clear" }, -- 3 commands are ran.
    -- ctrl-p/n can be used to cycle history.
    { "make", { "[#ask]", "Enter make argument" } },
    { { "[#ask]", "Command to run after make" } },
   },
  },
  split = "horizontal", -- vertical or horizontal
  scale = 0.25,
  filetype = "coderunner",
 },
```

- Each key in `langs` table expects a table of commands.
- `[#file]` tag is replaced by the current filename.
- `{ "[#ask]", "Ask text }` Table prompts for input.

## API

```lua
require("coderunner").run({{split = "horizontal"}})
require("coderunner").run({{split = "vertical"}})
```

## Example setup with lazy.nvim

```lua
local opts = {
  split = "vertical",
  scale = 0.25,
}

return {
  "catgoose/coderunner.nvim",
  opts - opts,
  event = "BufReadPre",
  keys = {
    {"<leader>cc", [[require("coderunner").run({split = "horizontal"})]]),
    {"<leader>cv", [[require("coderunner").run({split = "vertical"})]])},
  }
```

## Todo

- [ ] Allow defining a table of actions to perform as a token
