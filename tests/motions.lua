-- Run with: lua tests/motions.lua
local state, keys, events = {}, {}, {}
ui = { render = function() end }
Status = {}
cx = {
	tabs = { idx = 2 },
	active = { current = { files = { { cha = { is_dir = true } } } } },
}
ya = {
	sync = function(fn) return function(...) return fn(state, ...) end end,
	which = function(opts)
		local key = table.remove(keys, 1)
		for i, candidate in ipairs(opts.cands) do
			if candidate.on == key then return i end
		end
		assert(key == nil, "unknown key: " .. tostring(key))
	end,
	emit = function(name, args) events[#events + 1] = { name, args } end,
}

local plugin = dofile("main.lua")
plugin.setup(state, { enter_mode = "cache" })

local function check(initial, input, expected)
	keys, events = input, {}
	plugin.entry(nil, { args = { tostring(initial) } })
	assert(#events == #expected, "unexpected event count: " .. #events)
	for i, want in ipairs(expected) do
		local got = events[i]
		assert(got[1] == want[1], ("event %d: expected %s, got %s"):format(i, want[1], got[1]))
		for k, value in pairs(want[2]) do
			assert(got[2][k] == value, ("event %d argument %s mismatch"):format(i, k))
		end
	end
end

check(3, { "j" }, { { "arrow", { 3 } } })
check(2, { "k" }, { { "arrow", { -2 } } })
check(3, { "g", "g" }, { { "arrow", { "top" } }, { "arrow", { 2 } } })
check(2, { "h" }, { { "leave", {} }, { "leave", {} } })
check(2, { "l" }, { { "enter", {} }, { "enter", {} } })
check(3, { "g", "t" }, { { "tab_switch", { 2 } } })
check(2, { "H" }, { { "tab_switch", { -2, relative = true } } })
check(2, { "t" }, { { "tab_create", {} }, { "tab_create", {} } })
check(2, { "d", "j" }, { { "visual_mode", {} }, { "arrow", { 2 } }, { "escape", {} }, { "remove", {} } })
check(2, { "y", "y" }, { { "visual_mode", {} }, { "arrow", { 1 } }, { "escape", {} }, { "yank", {} } })
check(2, { "x", "k" }, { { "visual_mode", {} }, { "arrow", { -2 } }, { "escape", {} }, { "yank", { cut = true } } })
check(2, {}, {})
print("motion API tests passed")
