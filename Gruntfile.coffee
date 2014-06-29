module.exports = (grunt) ->

  FFmpeg = require 'fluent-ffmpeg'
  ProgressBar = require 'progress'
  path = require 'path'
  chalk = require 'chalk'

  src = grunt.option('src') ? 'demo'
  dest = grunt.option('dest') ? src

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
    grunt.log.subhead "Found #{files.length} videos"
    process = () ->
      if files.length <= 0
        grunt.log.ok
        done()
        return
      
      file = files.pop()
      grunt.verbose.writeln "Source: #{file.src[0]}"
      grunt.verbose.writeln "Destination: #{file.dest}"
      if grunt.file.exists file.dest then grunt.file.delete file.dest

      bar = new ProgressBar "  #{path.basename file.dest} [:bar] :percent :etas",
        total: 100
        width: 60

      options =
        source: file.src[0]
        logger: console.log
      cmd = new FFmpeg options
      cmd.withVideoCodec('libx264')
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
    grunt.log.subhead(grunt.file.read('banner.txt'))

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'

  grunt.registerTask 'default', ['banner','ffmpeg']
  grunt.registerTask 'demo', ['banner','clean','copy','ffmpeg']

  null
