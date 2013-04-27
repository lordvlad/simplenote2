fs         = require 'fs'
{exec}     = require 'child_process'
util       = require 'util'

appFiles  = [
  'src/coffee/rostrum.coffee'
  'src/coffee/simplenote.coffee'
  'src/coffee/node.coffee'
  'src/coffee/caudum.coffee'
]

task 'coffeeFiles', 'how much coffee you got?!', ->
  traverseFileSystem = (currentPath) ->
      files = fs.readdirSync currentPath
      for file in files
        do (file) ->
          currentFile = currentPath + '/' + file
          stats = fs.statSync(currentFile)
          if stats.isFile() and currentFile.indexOf('.coffee') > 1 and appFiles.join('=').indexOf("#{currentFile}") < 0
            appFiles.push currentFile
          else if stats.isDirectory()
            traverseFileSystem currentFile

  traverseFileSystem 'src'
  util.log "#{appFiles.length} coffee files found.\n#{file+'\n' for file in appFiles}"
  return appFiles

task 'watch', 'Watch prod source files and build changes', ->
    invoke 'build'
    util.log "Watching for changes in src"

    for file in appFiles then do (file) ->
        fs.watchFile file, (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{file}"
                grrrr 'Whoa. Saw a change. Building. Hold plz.'
                invoke 'build'

task 'build', 'Build single application file from source files', ->
  invoke 'coffeeFiles'
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'lib/app.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee -o . --compile lib/app.coffee', (err, stdout, stderr) ->
        if err
          util.log 'Error compiling coffee file.'
          grrrr 'Uh, your coffee is bad.'
        else
          fs.unlink 'lib/app.coffee', (err) ->
            if err
              util.log 'Couldn\'t delete the app.coffee file/'
            util.log 'Done building coffee file.'
            grrrr 'Okay, coffee is ready.'

grrrr = (message = '') -> 
  util.log message