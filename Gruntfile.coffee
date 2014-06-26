module.exports = (grunt) ->

  grunt.initConfig
    ffmpeg:
      video:
        files:
          [
            expand: true
            cwd: 'videos'
            src: ['*.avi', '*.ts']
            dest: 'videos'
            ext: '.mp4'
          ]

  grunt.task.registerTask 'banner', () ->
    console.log(grunt.file.read('banner.txt'))

  # grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-ffmpeg'

  grunt.registerTask 'default', ['banner','ffmpeg']

  null
