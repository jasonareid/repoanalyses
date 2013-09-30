module("jason.utils", package.seeall)

function sorted_keys(t)
	local ks = {}
	for n in pairs(t) do ks[#ks + 1] = n end
	table.sort(ks)
	return ks
end

function count_if(t, filterIter)
	local count = 0
 
	for k, v in pairs(t) do
		if filterIter(k, v, t) then count = count + 1 end
	end

	return count
end

function string_ends_with_any_of(str, endings)
	for i, ending in ipairs(endings) do
		if string_ends_with(str, ending) then return true end
	end
	return false
end

function string_ends_with(str, ending)
	return string.sub(str,-string.len(ending)) == ending
end