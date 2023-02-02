.PHONY: run new push

TITLE=""

run:
	hugo server

new:
	hugo new  --kind post post/$(TITLE)

push:
	git add .
	git commit -m 'new blog'
	git push --set-upstream origin $(git symbolic-ref --short HEAD)
