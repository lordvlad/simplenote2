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

    for file in [].concat.apply( coffeeFiles.map((n)->coffeeDir+n+'.coffee'), lessFiles.map((n)->lessDir+n+'.less') ) then do (file) ->
        fs.watchFile file, (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{file}"
                invoke 'build'
task 'stop', 'Stop watchin source files', ->
    for file in [].concat.apply( coffeeFiles.map((n)->coffeeDir+n+'.coffee'), lessFiles.map((n)->lessDir+n+'.less') ) then do (file) ->
      fs.unwatchFile file  
  
task 'build', 'Build single application file from source files', ->
  coffeeContents = new Array remainingCoffee = coffeeFiles.length
  lessContents = new Array remainingLess = lessFiles.length
  for file, index in coffeeFiles then do (file, index) ->
    fs.readFile coffeeDir + file + '.coffee', 'utf8', (err, fileContents) ->
      throw err if err
      coffeeContents[index] = fileContents
      processCoffee() if --remainingCoffee is 0
  for file, index in lessFiles then do ( file, index ) ->
    fs.readFile lessDir + file + '.less', 'utf8', (err, fileContents) ->
      throw err if err
      lessContents[index] = fileContents
      processLess() if --remainingLess is 0
  processLess = ->
    util.log 'joining less files'
    fs.writeFile 'pub/app.less', lessContents.join('\n\n'),'utf8', (err) ->
      throw err if err
      exec 'lessc pub/app.less > pub/app.css', ( err, stdout, stderr) ->
        if err
          util.log "Error compiling less file.\n #{err}"
        else
          fs.unlink 'pub/app.less', (err)->
            if err
              util.log 'Couldn\'t delete app.less'
            util.log 'Less > CSS done'
  processCoffee = ->
    util.log 'joining coffee files'
    fs.writeFile 'pub/app.coffee', coffeeContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee -o . --compile pub/app.coffee', (err, stdout, stderr) ->
        if err
          util.log "Error compiling coffee file.\n #{err}"
        else
          fs.unlink 'pub/app.coffee', (err) ->
            if err
              util.log 'Couldn\'t delete app.coffee'
            util.log 'Coffee > JS done'