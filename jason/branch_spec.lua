module("jason.branch_spec", package.seeall)


function exclude(branches) 
	return BranchSpec.new(branches)
end

BranchSpec = {}
function BranchSpec.new(excludes)
	local self = {}
	setmetatable(self, {__index = BranchSpec})
	
	self.excludes = branches_to_exclude
	return self
end

function BranchSpec:accepts(branch)
	
	return branch ~= "master"
end