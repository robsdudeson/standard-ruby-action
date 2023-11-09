# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "report_adapter"
require_relative "github_check_run_service"
require_relative "github_client"

def read_json(path)
  JSON.parse(File.read(path))
end

@event_json = read_json(ENV["GITHUB_EVENT_PATH"]) if ENV["GITHUB_EVENT_PATH"]
@github_data = {
  sha: ENV["GITHUB_SHA"],
  token: ENV["GITHUB_TOKEN"],
  owner: ENV["GITHUB_REPOSITORY_OWNER"] || @event_json.dig("repository", "owner", "login"),
  repo: ENV["GITHUB_REPOSITORY_NAME"] || @event_json.dig("repository", "name")
}
@report =
  if ENV["REPORT_PATH"]
    read_json(ENV["REPORT_PATH"])
  else
    report = JSON.parse(`standardrb --parallel -f json`)
    pp report
    Dir.chdir(ENV["GITHUB_WORKSPACE"]) { report }
  end

GithubCheckRunService.new(@report, @github_data, ReportAdapter).run

if ENV["STANDARD_RUBY_FAIL_ON_VIOLATIONS"] &&
    ReportAdapter.conclusion(@report) != "success"
  pp "Violations Found"
  exit 1
end
