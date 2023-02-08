.PHONY: run new push

TITLE=""
BRANCH:=$(shell git symbolic-ref --short HEAD)

run:
	hugo server

new:
	hugo new  --kind post post/$(TITLE)

push:
	git add .
	git commit -m '$(BRANCH)'
	git push --set-upstream origin $(BRANCH)

