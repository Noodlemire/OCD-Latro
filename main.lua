OCD = {config_entries = {}}

SMODS.Atlas{
	key = "modicon",
	path = "icon.png",
	px = 33,
	py = 33
}

local old_uibox_init = UIBox.init
function UIBox:init(args)
	if pseudorandom("ocd", 1, 2) == 1 then
		OCD.nudge_ui(args.definition, OCD.count_ui(args.definition)+1)
	end
	old_uibox_init(self, args)
end

function OCD.count_ui(node)
	if not node then return end
	local count = 0
	if node.config and node.n ~= G.UIT.ROOT then
		for k, v in pairs(node.config) do
			if OCD.config_entries[k] then
				count = count + 1
			end
		end
	end
	for _, n in ipairs(node.nodes or node) do
		count = count + OCD.count_ui(n)
	end
	return count
end

function OCD.nudge_ui(node, odds)
	if not node then return end
	if node.config and node.n ~= G.UIT.ROOT then
		for k, v in pairs(node.config) do
			if OCD.config_entries[k] and pseudorandom("ocd", 1, odds) == 1 then
				node.config[k] = OCD.config_entries[k](v)
			end
		end
	end
	for _, n in ipairs(node.nodes or node) do
		OCD.nudge_ui(n, odds)
	end
end

function OCD.register_config_entry(key, func)
	if type(key) ~= "string" or type(func) ~= "function" then
		sendWarnMessage("OCD.register_config_entry: 'key' must be of type 'string' and 'func' must be of type 'function'", "OCD-Latro")
		return
	elseif OCD.config_entries[key] then
		sendWarnMessage(("OCD.config_entries[key]: UI Config key '%s' has already been registered."):format(key), "OCD-Latro")
		return
	end
	OCD.config_entries[key] = func
end

function OCD.common_size_nudge(v)
	local margin = math.max(0.01, v * 0.5)
	return v + pseudorandom("ocd") * margin - margin/2
end

for _, k in ipairs({"h", "minh", "maxh", "w", "minw", "maxw", "padding", "r"}) do
	OCD.register_config_entry(k, OCD.common_size_nudge)
end

local all_aligns = {"tl", "tm", "tr", "cl", "cm", "cr", "bl", "bm", "br"}
OCD.register_config_entry("align", function(v)
	local other_aligns = {}
	for _, a in ipairs(all_aligns) do
		if a ~= v then
			table.insert(other_aligns, a)
		end
	end
	return pseudorandom_element(other_aligns, "ocd")
end)

OCD.register_config_entry("colour", function(v)
	local new_color = {}
	for i = 1, #v do
		new_color[i] = v[i]
	end
	local k = pseudorandom("ocd", 1, 3)
	new_color[k] = pseudorandom("ocd")
	return new_color
end)

OCD.register_config_entry("text", function(v)
	local offset = string.rep(" ", pseudorandom("ocd", 1, 3))
	if pseudorandom("ocd", 1, 2) == 1 then
		return v..offset
	else
		return offset..v
	end
end)
