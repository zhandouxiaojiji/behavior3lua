codes = true
color = true

std = "max"

include_files = {
    "lualib/*",
}


ignore = {
    "423", -- Shadowing a loop variable
    "211", -- Unused local variable
    "212", -- Unused argument
    "212/self", -- ignore self
    "213", -- Unused loop variable
}
