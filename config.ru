require 'rubygems'
require 'sinatra'
require 'rack/cache'

require File.expand_path '../app.rb', __FILE__

use Rack::Cache,
  metastore:    'file:/data/code/cache/rack/meta',
  entitystore:  'file:/data/code/cache/rack/body',
  verbose:      true

run Iam
