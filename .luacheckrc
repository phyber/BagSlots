-- vim:ft=lua:
std = "lua51"

-- Show codes for warnings
codes = true

-- Disable colour output
color = false

-- Suppress reports for files without warnings
quiet = 1

-- Disable max line length check
max_line_length = false

-- We don't want to check externals Libs or this config file
exclude_files = {
    ".release/",
    "Libs/",
    ".luacheckrc",
}

-- Ignored warnings
ignore = {
    "211/bagType", -- Used in UpdateSlotCount
    "212/info",    -- Used in getOptions
    "212/self",    -- Used in multiple functions
}

-- Globals that we read/write
globals = {
}

-- Globals that we only read
read_globals = {
    -- Libraries
    "LibStub",

    -- Lua globals

    -- C modules

    -- API Functions
    "GetContainerNumFreeSlots",
    "GetContainerNumSlots",
    "InterfaceOptionsFrame_OpenToCategory",

    -- FrameXML Globals
    "NumberFontNormal",
    "NUM_BAG_SLOTS",

    -- Frames
    "Settings",
}
