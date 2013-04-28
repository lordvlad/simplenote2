fs         = require 'fs'
{exec}     = require 'child_process'
util       = require 'util'
uglifyJS   = require 'uglify-js'

lessDir = 'src/less/'
coffeeDir = 'src/coffee/'

lessFiles = [
]

coffeeFiles = [
]

task 'watch', 'Watch prod source files and build changes', ->
    invoke 'build'
    util.log "Watching for changes in src"

    for file in coffeeFiles then do (file) ->
        fs.watchFile file, (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{file}"
                invoke 'build'

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
    fs.writeFile 'pub/app.less', lessContents.join('\n\n'),'utf8', (err) ->
      throw err if err
      exec 'lessc pub/app.less >> pub/app.css', ( err, stdout, stderr) ->
        if err
          util.log "Error compiling less file.\n #{err}"
        else
          fs.unlink 'pub/app.less', (err)->
            if err
              util.log 'Couldn\'t delete app.less'
            util.log 'Less > CSS done'
  processCoffee = ->
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

task 'wre', 'combine and compress lib/wre', ->
  filelist = []
  traverseFileSystem = (currentPath) ->
    files = fs.readdirSync currentPath
    for file in files
      do (file) ->
        currentFile = currentPath + '/' + file
        stats = fs.statSync(currentFile)
        if stats.isFile() and filelist.join('=').indexOf("#{currentFile}") < 0
          filelist.push currentFile
        else if stats.isDirectory()
          traverseFileSystem currentFile
  traverseFileSystem 'lib/wre'
  appContents = new Array remaining = filelist.length
  for file, index in filelist then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    
    result uglifyJS.minify( filelist )
    fs.writeFile 'lib/wre.extensions.min.js', result.code, 'utf8', (err) ->
      throw err if err
      util.log 'done minifying lib/wre'