module.exports = (grunt) ->

  FFmpeg = require 'fluent-ffmpeg'
  ProgressBar = require 'progress'
  path = require 'path'
  chalk = require 'chalk'
  S = require 'string'
  S.extendPrototype()

  src = grunt.option('src') ? 'demo'
  dest = grunt.option('dest') ? src
  codec = grunt.option('codec') ? 'libx264'

  logger =
    debug: (msg) -> grunt.log.debug msg,
    info: (msg) -> grunt.log.writeln msg,
    warn: (msg) -> grunt.log.warn msg,
    error: (msg) -> grunt.log.error msg

  grunt.initConfig
    options:
      force: true
    clean: ['demo']
    copy:
      main:
        files: [
          expand: true
          cwd: 'demo_backup/'
          src: '**'
          dest: 'demo/'
        ]
    ffmpeg:
      videos:
        expand: true
        files: [
          expand: true
          cwd: src
          src: ['**/*.{wmv,ts,mp4,mkv}']
          dest: dest
          ext: '.m4v'
          extDot: 'last'
        ]

  grunt.registerMultiTask 'ffmpeg', 'Converts videos', () ->
    done = this.async()
    files = this.files.slice()
    grunt.log.writeln "Found #{chalk.cyan files.length} videos and using codec #{chalk.cyan codec}"
    process = () ->
      if files.length <= 0
        grunt.log.ok
        done()
        return
      
      file = files.pop()
      grunt.verbose.writeln ""
      grunt.verbose.writeln "Source: #{file.src[0]}"
      grunt.verbose.writeln "Destination: #{file.dest}"
      grunt.verbose.writeln ""
      if grunt.file.exists file.dest
        grunt.verbose.writeln "Destination '#{file.dest}' file already exists"
        grunt.file.delete file.dest

      bar = new ProgressBar "#{chalk.green '➤'} #{S(path.basename file.dest).truncate(50).s} [#{chalk.cyan ':bar'}] :percent :etas",
        total: 100
        width: 80
        complete: '■'
        incomplete: ' '

      options =
        source: file.src[0]
        logger: logger
      cmd = new FFmpeg options
      cmd.withVideoCodec(codec)
      cmd.withAudioCodec('libfaac')
      cmd.on 'error', (err) ->
        grunt.log.error "✖︎ #{file.src[0]}"
        grunt.log.error "  #{err.message}"
        done(false)
      cmd.on 'progress', (progress) ->
        bar.update(progress.percent/100)
      cmd.on 'end', () ->
        bar.update 1 # 100%
        grunt.file.delete file.src[0]
        grunt.verbose.ok "Deleted #{file.src[0]}"
        process()
      cmd.saveToFile file.dest
    process()

  grunt.task.registerTask 'banner', () ->
    console.log(chalk.gray.bold(grunt.file.read('banner.txt')))

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'

  grunt.registerTask 'default', ['banner','ffmpeg']
  grunt.registerTask 'demo', ['banner','clean','copy','ffmpeg']

  S.restorePrototype()

  null
