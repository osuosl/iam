# Sinatra web server
A simple web service
* currently only uses a static JSON file sourced from https://ganeti-psf.osuosl.bak:5080/2/instances?bulk=1

### Installation
```
bundle install
ruby app.rb
```

### Usage
`localhost:4567/data`  
* Returns the entire bulk data in JSON

`localhost:4567/data/<vm #>`
* Returns the specific vm data for the vm # (0, 1, 2 ...) in JSON

`localhost:4567/data/<vm #>/stats`
* Returns data on the VM we care about (name, created time, status, cpus, ram, disk, os, etc...) in JSON

### TODO
* create web front (?)
* fix trailing /'s on routes'
* convert static data source to redis source
* change /data/<vm #>/stats to return data that matches scope
