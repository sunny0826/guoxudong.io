.PHONY: run new push

BRANCH:=$(shell git symbolic-ref --short HEAD)

run:
	hugo server

new:
	hugo new  --kind post post/$(BRANCH)

push:
	git add .
	git commit -m '$(BRANCH)'
	git push --set-upstream origin $(BRANCH)

