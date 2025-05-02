local PATH = (...):match("(.-)[^%.]+$") .. "juin."

local M = {}

M.UI = require(PATH .. '.src.ui')

return M
