UGLIFY_FLAGS = --no-mangle 
VERSION = 'v0.9'

all: test

clean:


test: clean
	@mocha
	@node app.js 2>err.txt 1>out.txt &
	@sleep 1
	@kill -9 `cat pid.txt`

run: test
	@node app.js
  

