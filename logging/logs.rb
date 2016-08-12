require 'logging'
require 'environment.rb'

# Creates a logfile with the level 'debug'
#   that appends to log_file.log
log = Logging.logger['log_file']
log.level = :debug
log.add_appenders \
   Logging.appenders.file('log_file.log')

log.debug('Created logger')
log.info('Program started')
