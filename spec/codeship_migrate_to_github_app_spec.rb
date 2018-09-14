require 'spec_helper'

RSpec.describe CodeshipMigrateToGithubApp do
  it "has a version number" do
    expect(CodeshipMigrateToGithubApp::VERSION).not_to be nil
  end
end

RSpec.describe CodeshipMigrateToGithubApp::CLI do
  JSON_TYPE = {"Content-Type" => "application/json"}

  let(:codeship_user) { "josh" }
  let(:codeship_pass) { "s3cr3t" }
  let(:github_token) { "abc123" }

  let(:args) { ["start", "--codeship-user=#{codeship_user}",
                "--codeship-pass=#{codeship_pass}",
                "--github-token=#{github_token}" ]
            }

  let(:command) { CodeshipMigrateToGithubApp::CLI.start(args) }

  let(:urls) do
    {
        codeship_auth: "https://api.codeship.com/v2/auth",
        github_orgs: "https://api.github.com/user/orgs",
        codeship_migration: "https://api.codeship.com/v2/github_migration_info"
   }
  end

  describe "#start" do
    before(:each) do
      stub_request(:post, urls[:codeship_auth]).to_return(status: 200, headers: JSON_TYPE, body: '{"access_token": "abc123", "organizations":[{"uuid":"86ca6be0-413d-0134-079f-1e81b891aacf","name":"joshco"},{"uuid":"c00d11a0-383b-0136-dfac-0aa9c93fd8f3","name":"partial-match-76"}]}')
      stub_request(:get, urls[:github_orgs]).to_return(status: 200, headers: JSON_TYPE, body: '[{"login": "joshco", "id": 123, "url": "https://api.github.com/orgs/joshco"}]')
      stub_request(:get, urls[:codeship_migration]).to_return(status: 200, headers: JSON_TYPE, body: '[{"installation_id":"123","repositories":[{"repository_id":"7777"},{"repository_id":"8888"}]},{"installation_id":"456","repositories":[{"repository_id":"9999"}]}]')
    end

    context "valid arguments" do
      it { expect{command}.to_not raise_error }
      it { expect{command}.to output(a_string_including("Migrated!")).to_stdout }
    end

    context "codeship username not found" do
      before(:each) do
        stub_request(:post, urls[:codeship_auth]).to_return(status: 401, headers: JSON_TYPE, body: '{"errors":["Unauthorized"]}')
      end

      it { expect{command}.to raise_error(SystemExit) }
      it { expect{begin; command; rescue SystemExit; end}.to output(a_string_including("Error authenticating to CodeShip: 401")).to_stderr }
    end

    context "codeship password wrong" do
      before(:each) do
        stub_request(:post, urls[:codeship_auth]).to_return(status: 401, headers: JSON_TYPE, body: '{"errors":["Unauthorized"]}')
      end

      it { expect{command}.to raise_error(SystemExit) }
      it { expect{begin; command; rescue SystemExit; end}.to output(a_string_including("Error authenticating to CodeShip: 401")).to_stderr }
    end

    context "invalid Github token" do
      before(:each) do
        stub_request(:get, urls[:github_orgs]).to_return(status: 401, headers: JSON_TYPE, body: '{"message": "Requires authentication", "documentation_url": "https://developer.github.com/v3/orgs/#list-your-organizations"}')
      end

      it { expect{command}.to raise_error(SystemExit) }
      it { expect{begin; command; rescue SystemExit; end}.to output(a_string_including("Error authenticating to Github: 401")).to_stderr }
    end

    context "error contacting CodeShip for migration information" do
      before(:each) do
        stub_request(:get, urls[:codeship_migration]).to_return(status: 500, headers: JSON_TYPE, body: '{"errors":["Unknown system error"]}')
      end

      it { expect{command}.to raise_error(SystemExit) }
      it { expect{begin; command; rescue SystemExit; end}.to output(a_string_including("Error retreiving migration info from CodeShip: 500")).to_stderr }
    end
  end
end
