.PHONY: run new push

TITLE:="new-blog"
BRANCH:=$(shell git symbolic-ref --short HEAD)

run:
	hugo server

new:
	git checkout -b $(TITLE)
	hugo new  --kind post post/$(TITLE)

push:
	git add .
	git commit -m '$(BRANCH)'
	git push --set-upstream origin $(BRANCH)

