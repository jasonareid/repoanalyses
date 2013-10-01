require "jason.commit_summary"
require "jason.branch_spec"

function describe()
	local r = {}
	r.title = "Commit Sizes over Time"
	r.description = "Shows commit sizes over time"
	return r
end

function run(self)
	local repo = self:repository()
	local branch_spec = jason.branch_spec.exclude({"master", "production"})
	local commits = jason.commit_summary.generate_commit_summary(repo, branch_spec, jason.commit_summary.FILETYPES_RUBY)
	local grouped = commits:grouped_by_intervals(jason.commit_summary.INTERVAL_ONE_WEEK)
	grouped:print_date_meansize_stderrlow_stderrhi()
end