local ok, cmp = pcall(require, "cmp")

if ok then
    cmp.register_source("rg", require("cmp-rg").new())
end
