local ls = require("luasnip")

local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
--
-- nb: table start at position 1 in lua

ls.add_snippets("lua", {
    -- mine
    s(
        "loc",
        fmt(
            [[
            local {} = function({})
                {}
            end
            ]],
            {
                i(1, ""),
                c(2, { t(""), t("myArg") }),
                i(3, ""), -- i node is children of node choice, so pos 1
            }
        )
    ),
    s(
        "req",
        fmt(
            [[
            local {} = require("{}");
            ]],
            {
                i(1, ""),
                rep(1),
            }
        )
    ),
})
