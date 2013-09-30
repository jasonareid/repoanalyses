module("jason.branch_spec", package.seeall)


function exclude(branches) 
	return BranchSpec.new(branches)
end

BranchSpec = {}
function BranchSpec.new(excludes)
	local self = {}
	setmetatable(self, {__index = BranchSpec})
	
	self.excludes = excludes
	return self
end

function BranchSpec:accepts(branch)
	if jason.utils.find(self.excludes, function(v) return v == branch end) then
		return false
	end
	return true
end