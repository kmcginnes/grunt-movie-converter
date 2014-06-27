module.exports = (grunt) ->

  filesToDelete = []

  grunt.initConfig
    ffmpeg:
      compile:
        options:
          # debug: true
          onEnd: (input, output) ->
            filesToDelete.push input
          onError: (error, input, output) ->
            console.log('error on: ' + input + ' ['+ error +']')
          # onCodecData: (data, input) ->
          #   console.log(input + ' input is ' + data.audio + ' audio with ' + data.video + ' video')
          FFmpegOptions:
            withVideoCodec: 'libx264'
            withAudioCodec: 'libfaac'
        files:
          [
            expand: true
            cwd: '.'
            src: ['**/*.avi', '**/*.ts', '**/*.wmv']
            dest: '.'
            ext: '.m4v'
          ]
    clean: filesToDelete

  grunt.task.registerTask 'banner', () ->
    grunt.log.subhead(grunt.file.read('banner.txt'))

  grunt.registerTask 'print', () ->
    for file in filesToDelete
      grunt.log.ok 'Deleting ' + file

  # grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-ffmpeg'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', ['banner','ffmpeg','print']

  null
