require 'logging'
require 'environment.rb'
require 'stringio'

log = Logger.new('log_file.log')
log.level = :debug

log.debug('Created logger')
log.info('Program started')
