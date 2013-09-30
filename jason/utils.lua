module("jason.utils", package.seeall)

function sorted_keys(t)
	local ks = {}
	for n in pairs(t) do ks[#ks + 1] = n end
	table.sort(ks)
	return ks
end
