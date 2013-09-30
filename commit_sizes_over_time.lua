require "jason.stats"
require "jason.commit_summary"
require "pepper.plotutils"

function describe()
	local r = {}
	r.title = "Commit Sizes over Time"
	r.description = "Shows commit sizes over time"
	r.options = {{"-bARG, --branch=ARG", "Select branch"}}
	pepper.plotutils.add_plot_options(r)
	return r
end

function run(self)
	local repo = self:repository()
	local commits = jason.commit_summary.generate_commit_summary(repo, jason.commit_summary.FILETYPES_RUBY)
	local grouped = commits:grouped_by_intervals(jason.commit_summary.INTERVAL_ONE_WEEK)
	print_date_meansize_stderrlow_stderrhi(grouped)
end


function print_date_meansize_stderrlow_stderrhi(summary)
	local px = {}
	local py = {}
	for i,n in ipairs(summary.times) do
		local m = jason.stats.mean(summary.commits[n])
		local rn = jason.stats.standardError(summary.commits[n])
		px[#px+1] = n

		local y = {}
		y[#y+1] = m
		y[#y+1] = math.max(1, m - rn)
		y[#y+1] = m + rn

		py[#py+1] = y
	end
	for i,n in ipairs(px) do
		print(os.date("%x", px[i]) .. " " .. py[i][1] .. " " .. py[i][2] .. " " .. py[i][3])
	end
end
