module("jason.repo_filters", package.seeall)

function generate_commit_summary(repo, filetypes)
	local commits = count_files_in_each_commit(repo, filetypes)
	local times = sorted_commit_times(commits)
	local summary = CommitSummary.new(commits, times)
	
	return summary
end

function fcount(filelist, filetypes)
	local count = 0
	for i, f in ipairs(filelist) do
		for i2, ft in ipairs(filetypes) do
			if string.sub(f,-string.len(ft))==ft then count = count + 1 end
		end
	end
	return count
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
	local commit_times = {}
	for n in pairs(commits) do commit_times[#commit_times + 1] = n end
	table.sort(commit_times)
	return commit_times
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