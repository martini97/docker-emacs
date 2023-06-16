emacs-30:
	docker build \
		--build-arg EMACS_BRANCH=master \
		--tag martini97/emacs:30 .

emacs-29:
	docker build \
		--build-arg EMACS_BRANCH=emacs-29 \
		--tag martini97/emacs:29 .

build: emacs-29 emacs-30

publish:
	docker push "martini97/emacs:29"
	docker push "martini97/emacs:30"
