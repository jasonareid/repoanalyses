require "jason.utils"
require "jason.stats"
require "jason.message_spec"

module("jason.commit_summary", package.seeall)

INTERVAL_ONE_DAY  = 60 * 60 * 24
INTERVAL_ONE_WEEK = INTERVAL_ONE_DAY * 7
FILETYPES_RUBY = {".rb", ".scss", ".css", ".js", ".coffee", ".erb", ".html", ".rhtml", ".rake"}

MESSAGES = {}

function generate_commit_summary(repo, branch_spec, filetypes, message_spec)
	message_spec = message_spec or jason.message_spec.accept_all()
	
	local commits  = count_files_in_each_commit(repo, branch_spec, filetypes, message_spec)
	local times    = sorted_commit_times(commits)
	
	return CommitSummary.new(commits, times)
end

function count_files_in_each_commit(repo, branch_spec, filetypes, message_spec)
	local branches = repo:branches()
	local commits = {}
	for k, branch in pairs(branches) do
		if branch_spec:accepts(branch) then
			local iter = repo:iterator(branch)
			for rev in iter:revisions() do
				if message_spec:accepts(rev:message()) then
					--io.stderr:write(os.date("%m/%d/%Y", rev:date()) .. " bug")
					local ds = rev:diffstat()
					local fcount = fcount(ds:files(), filetypes)
					commits[rev:date()] = fcount
					MESSAGES[rev:date()] = rev:message()
				end
			end
		end
	end
	return commits
end

function fcount(filelist, filetypes)
	return jason.utils.count_if(filelist, function(_k, v_filename, _t)
		return jason.utils.string_ends_with_any_of(v_filename, filetypes)
	end)
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
		while time > current_group_time + interval do
			current_group_time = current_group_time + interval
			groups[current_group_time] = {}
		end
		group = groups[current_group_time]
		group[#group + 1] = self.commits[time]
	end

	return CommitSummary.new(groups, sorted_commit_times(groups))
end

function CommitSummary:print_date_meansize_stderrlow_stderrhi()
	local px = {}
	local py = {}
	for i,n in ipairs(self.times) do
		local m = jason.stats.mean(self.commits[n])
		local rn = jason.stats.standardError(self.commits[n])
		px[#px+1] = n

		local y = {}
		y[#y+1] = m
		y[#y+1] = math.max(0, m - rn)
		y[#y+1] = m + rn

		py[#py+1] = y
	end
	for i,n in ipairs(px) do
		print(os.date("%x", px[i]) .. " " .. py[i][1] .. " " .. py[i][2] .. " " .. py[i][3])
	end
end

function CommitSummary:print_date_count()
	local px = {}
	local py = {}
	for i,date in ipairs(self.times) do
		px[#px+1] = date
		py[#py+1] = jason.utils.size(self.commits[date])
	end
	for i,n in ipairs(px) do
		print(os.date("%x", px[i]) .. " " .. py[i])
	end
end

function CommitSummary:print_messages()
	for i,date in ipairs(self.times) do
		print(os.date("%x", date) .. " " .. MESSAGES[date])
	end
end
