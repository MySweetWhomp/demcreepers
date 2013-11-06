module.exports = (grunt) ->
    grunt.initConfig
        coffee :
            compile :
                expand : yes
                cwd : 'scripts/coffee'
                src : [ '**/*.coffee' ]
                dest : 'scripts/js'
                ext : '.js'
        watch :
            files : 'scripts/coffee/**/*.coffee'
            tasks : [ 'coffee' ]

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.registerTask 'default', 'Watches scripts for changes', [ 'coffee', 'watch' ]