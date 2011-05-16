AS_FILES = FileList["src/**/*.as"]
LIBRARIES = ['lib/as3corelib/bin/as3corelib.swc']
DIST_SWC = 'dist/lib/echo-nest-flash-api.swc'

task :clean do
  sh 'rm -rf dist'
end

directory 'dist/lib'

file DIST_SWC => AS_FILES + LIBRARIES do
  library_path = LIBRARIES.join(',')
  include_classes = AS_FILES.pathmap("%{^src/,}X")

  sh "compc -source-path src -include-classes #{include_classes} -library-path+=#{library_path} -o #{DIST_SWC}"
end

# EXAMPLES

task :examples => 'dist/examples/analysis.swf'

directory 'dist/examples'

file 'dist/examples/analysis.swf' => ['dist/examples', DIST_SWC, 'examples/download-analysis/analysis.mxml'] do
  sh "mxmlc -library-path+=#{DIST_SWC} -o dist/examples/analysis.swf examples/download-analysis/analysis.mxml"
end

# DOCS

task :docs => :asdoc

directory 'dist/docs/asdoc'

task :asdoc => 'dist/docs/asdoc' do
  library_path = LIBRARIES.join(',')
  sh "asdoc -source-path src -doc-sources src -library-path+=#{library_path} -output dist/docs/asdoc -window-title 'Echo Nest Flash API Documentation'"
end

# DEPENDENCIES

task :submodule do
  sh 'git submodule init'
  sh 'git submodule update'
end

file 'lib/as3corelib/build/build.xml' => :submodule

file 'lib/as3corelib/bin/as3corelib.swc' => 'lib/as3corelib/build/build.xml' do
  sh 'cd lib/as3corelib/build && ant'
end
