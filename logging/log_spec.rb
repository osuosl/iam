# frozen_string_literal: true
require 'logging'
require 'rspec'
require 'rspec/logging_helper'

describe 'The Logging application' do
  def app
    Iam
  end

  # Configure RSpec to capture log messages for each test. The output from the
  # logs will be stored in the @log_output variable. It is a StringIO instance.
  RSpec.configure do |config|
    include RSpec::LoggingHelper
    config.capture_log_messages
  end

  # Now within your specs you can check that various log events were generated.
  # rubocop:disable LineLength
  it 'should be able to read a log message' do
    logger = Logging.logger['SuperLogger']

    logger.debug'foo bar'
    logger.warn 'just a little warning'

    expect(@log_output.readline).to eq("DEBUG  SuperLogger : foo bar\n")
    expect(@log_output.readline).to eq(" WARN  SuperLogger : just a little warning\n")
  end

  # Test existince of log_file.log
  it 'should check if log_file.log exists' do
    expect(File).to exist(Iam.settings.log_file_path)
  end
end
