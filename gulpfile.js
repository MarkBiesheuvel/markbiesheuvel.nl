
const gulp = require('gulp')
const csso = require('gulp-csso')
const htmlmin = require('gulp-htmlmin')
const inline = require('gulp-inline')
const livereload = require('gulp-livereload')
const sass = require('gulp-sass')
const svgmin = require('gulp-svgmin')
const uncss = require('gulp-uncss')
const pump = require('pump')

// Directories
const source = 'src'
const destination = 'dist'
const imagesDestination = `${destination}/images`

// Globs
const cssSource = `${source}/*.scss`
const htmlSource = `${source}/*.html`
const svgSource = `${source}/images/*.svg`
const othersSource = [
  `${source}/*.*`,
  `!${cssSource}`,
  `!${htmlSource}`,
  `!${svgSource}`
]

gulp.task('copy', callback => {
  // Task
  pump([
    gulp.src(othersSource),
    gulp.dest(destination),
    livereload()
  ], callback)
})

gulp.task('html', callback => {
  // Settings
  const css = [
    () => sass({includePaths: ['node_modules/bootstrap/scss']}),
    () => uncss({html: [htmlSource]}),
    () => csso({comments: false})
  ]
  const disabledTypes = ['img', 'svg']

  // Task
  pump([
    gulp.src(htmlSource),
    inline({
      base: source,
      css,
      disabledTypes
    }),
    htmlmin({
      collapseWhitespace: true,
      conservativeCollapse: false,
      removeComments: true,
      removeAttributeQuotes: true,
      removeEmptyAttributes: true,
      removeOptionalTags: true,
      removeRedundantAttributes: true,
      sortAttributes: true,
      sortClassName: true
    }),
    gulp.dest(destination),
    livereload()
  ], callback)
})

gulp.task('svg', callback => {
  // Task
  pump([
    gulp.src(svgSource),
    svgmin({}),
    gulp.dest(imagesDestination),
    livereload()
  ], callback)
})

gulp.task('watch', () => {
  // Task
  livereload.listen()
  gulp.watch(othersSource, ['copy'])
  gulp.watch(svgSource, ['svg'])
  gulp.watch([htmlSource, cssSource], ['html'])
})

// Everything together
gulp.task('build', ['copy', 'html', 'svg'])
