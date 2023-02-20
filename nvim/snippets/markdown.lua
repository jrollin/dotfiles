local ls = require("luasnip")

local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

-- nb: table start at position 1 in lua
--
ls.add_snippets("markdown", {
    s("totot", fmt("- [{}] {}", { c(2, { t(" "), t("-"), t("x") }), i(1, "task") })),
    s(
        "mine",
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
})
