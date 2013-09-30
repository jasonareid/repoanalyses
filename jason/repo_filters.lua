require "jason.utils"

module("jason.repo_filters", package.seeall)

function generate_commit_summary(repo, filetypes)
	local commits = count_files_in_each_commit(repo, filetypes)
	local times = sorted_commit_times(commits)
	local summary = CommitSummary.new(commits, times)
	
	return summary
end

function fcount(filelist, filetypes)
	return jason.utils.count_if(filelist, function(_k, v_filename, _t)
		return jason.utils.string_ends_with_any_of(v_filename, filetypes)
	end)
end

function count_files_in_each_commit(repo, filetypes)
	local branches = repo:branches()
	local commits = {}
        for key in pairs(branches) do
                local branch = branches[key]
                local iter = repo:iterator(branch)
                if branch ~= "master" then
                        for rev in iter:revisions() do
                                ds = rev:diffstat()
                                fs = ds:files()
                                local fcount = fcount(ds:files(), filetypes)
                                commits[rev:date()] = fcount
                        end
                end
        end
	return commits
end

function sorted_commit_times(commits)
	return jason.utils.sorted_keys(commits)
end

CommitSummary = {}
function CommitSummary.new(commits, times)
	local self = {}
	setmetatable(self, {__index = CommitSummary})
	
	self.commits = commits
	self.times = times
	return self
end

function CommitSummary:grouped_by_intervals(interval)
	local groups = {}

	local current_group_time = self.times[1]
	groups[current_group_time] = {}
	for i,time in ipairs(self.times) do 
		if time > current_group_time + interval then
			current_group_time = current_group_time + interval
			groups[current_group_time] = {}
		end
		group = groups[current_group_time]
		group[#group + 1] = self.commits[time]
	end

	return CommitSummary.new(groups, sorted_commit_times(groups))
end