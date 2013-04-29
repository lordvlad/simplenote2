fs         = require 'fs'
{exec}     = require 'child_process'
util       = require 'util'

lessDir = 'src/less/'
coffeeDir = 'src/coffee/'

lessFiles = [
  "body"
]

coffeeFiles = [
  "rostrum"
  "simplenote"
  "node"
  "caudum"
]

task 'watch', 'Watch prod source files and build changes', ->
    invoke 'build'
    util.log "Watching for changes in src"

    for file in coffeeFiles.map((n)->coffeeDir+n+'.coffee') then do (file) ->
        fs.watchFile file, (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{file}"
                invoke 'buildCoffee'
    for file in lessFiles.map((n)->lessDir+n+'.less') then do (file)->
        fs.watchFile file, (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "saw change in #{file}"
                invoke 'buildLess'
                
task 'stop', 'Stop watchin source files', ->
    for file in [].concat.apply( coffeeFiles.map((n)->coffeeDir+n+'.coffee'), lessFiles.map((n)->lessDir+n+'.less') ) then do (file) ->
      fs.unwatchFile file  

task 'build', 'build css and js files from less and coffee source files', ->
    invoke 'buildLess'
    invoke 'buildCoffee'
    
task 'buildLess', 'build single css file from less source files', ->
  util.log 'baking cake'
  util.log '.. collecting ingredients'
  lessContents = new Array remainingLess = lessFiles.length
  for file, index in lessFiles then do ( file, index ) ->
    fs.readFile lessDir + file + '.less', 'utf8', (err, fileContents) ->
      throw err if err
      lessContents[index] = fileContents
      processLess() if --remainingLess is 0
  processLess = ->
    util.log '.. mixing'
    fs.writeFile 'pub/app.less', lessContents.join('\n\n'),'utf8', (err) ->
      throw err if err
      exec 'lessc pub/app.less > pub/app.css', ( err, stdout, stderr) ->
        if err
          util.log ".. Error compiling less file.\n #{err}"
        else
          fs.unlink 'pub/app.less', (err)->
            if err
              util.log 'Couldn\'t delete app.less'
            util.log '.. cake ready'

task 'buildCoffee', 'Build single js file from coffee source files', ->
  util.log 'brewing coffee'
  util.log '.. collecting beans'
  coffeeContents = new Array remainingCoffee = coffeeFiles.length
  for file, index in coffeeFiles then do (file, index) ->
    fs.readFile coffeeDir + file + '.coffee', 'utf8', (err, fileContents) ->
      throw err if err
      coffeeContents[index] = fileContents
      processCoffee() if --remainingCoffee is 0
  processCoffee = ->
    util.log '.. mangling'
    fs.writeFile 'pub/app.coffee', coffeeContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee -o ./pub/ --compile pub/app.coffee', (err, stdout, stderr) ->
        if err
          util.log ".. Error compiling coffee file.\n #{err}"
        else
          fs.unlink 'pub/app.coffee', (err) ->
            if err
              util.log '.. Couldn\'t delete app.coffee'
            util.log '.. coffee ready'