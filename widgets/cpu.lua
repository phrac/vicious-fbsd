---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2011, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
--  * (c) 2011, Jörg Thalheim <jthalheim@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local ipairs = ipairs
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
local string = {
    sub = string.sub,
    gmatch = string.gmatch
}
-- }}}


-- Cpu: provides CPU usage for all available CPUs/cores
-- vicious.widgets.cpu
local cpu = {}


-- Initialize function tables
local cpu_usage  = {}
local cpu_total  = {}
local cpu_active = {}

-- {{{ CPU widget type
local function worker(format)
    local cpu_lines = {}

    ---- Get cpu stats
	local cpu_usage_file = io.popen( 'sysctl -n kern.cp_time' )
	local v = splitbywhitespace( cpu_usage_file:read());
	cpu_usage_file:close()

	---- Ensure tables are initialized correctly
	while #cpu_total < 1 do
		table.insert(cpu_total, 0)
	end
	while #cpu_active < 1 do
		table.insert(cpu_active, 0)
	end
	while #cpu_usage < 1 do
		table.insert(cpu_usage, 0)
	end

	---- Setup tables
	local total_new     = {}
	local active_new    = {}
	local diff_total    = {}
	local diff_active   = {}

	---- FreeBSD kern.cp_time combines all CPUs/cores
	local i = 1

	---- Calculate totals
	total_new[i] = v[1] + v[2] + v[3] + v[5]
	active_new[i] = v[1] + v[2] + v[3]

	---- Calculate percentage
	diff_total[i]   = total_new[i]  - cpu_total[i]
	diff_active[i]  = active_new[i] - cpu_active[i]
	cpu_usage[i]    = math.floor( ( diff_active[i] / diff_total[i] ) * 100)

	---- Store totals
	cpu_total[i]    = total_new[i]
	cpu_active[i]   = active_new[i]
    return cpu_usage
end
-- }}}

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })
