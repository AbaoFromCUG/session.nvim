local path = require("session.path")

describe("path escape&unescape", function()
    it("linux", function()
        local raw = "/tmp/te_20st/a\b.txt"
        local escaped = path.escape_path(raw)
        assert.are.truthy(escaped:match("^[%w_]+$"))
        local unescaped = path.unescape_path(escaped)
        assert.are.equal(raw, unescaped)
    end)
    it("windows", function()
        local raw = "c:\tm?p\te<st>\a.txt"
        local escaped = path.escape_path(raw)
        assert.are.truthy(escaped:match("^[%w_]+$"))
        local unescaped = path.unescape_path(escaped)
        assert.are.equal(raw, unescaped)
    end)

    it("chinese", function()
        local raw = "/tmp/文件/a_b.txt"
        local escaped = path.escape_path(raw)
        assert.are.truthy(escaped:match("^[%w_]+$"))
        local unescaped = path.unescape_path(escaped)
        assert.are.equal(raw, unescaped)
    end)
    it("unicode", function()
        local raw = "/tmp/󰻐/😀/a_b.txt"
        local escaped = path.escape_path(raw)
        assert.are.truthy(escaped:match("^[%w_]+$"))
        local unescaped = path.unescape_path(escaped)
        assert.are.equal(raw, unescaped)
    end)
end)
