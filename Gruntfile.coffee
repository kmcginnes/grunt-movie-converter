module.exports = (grunt) ->

  grunt.initConfig
    ffmpeg:
      compile:
        options:
          # debug: true
          # onEnd: (input, output) ->
          #   console.log(input + ' -> ' + output)
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
            src: ['**/*.avi', '**/*.ts']
            dest: '.'
            ext: '.m4v'
          ]

  grunt.task.registerTask 'banner', () ->
    console.log(grunt.file.read('banner.txt'))

  # grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-ffmpeg'

  grunt.registerTask 'default', ['banner','ffmpeg']

  null
