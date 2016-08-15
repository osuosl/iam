# Types of log statements:
#   log.debug "a very nice little debug message"
#   log.info "things are operating nominally"
#   log.warn "this is your last warning"
#   log.error StandardError.new("something went horribly wrong")
#   log.fatal "I Die!"

require 'logging'
require 'environment.rb'

# Creates logfile with the level 'debug'
#   that appends to log_file.log
log = Logging.logger['logfile']
log.level = :debug
log.add_appenders \
   Logging.appenders.file('logging/log_file.log')

log.debug 'Created logger'
log.info 'Program started'
