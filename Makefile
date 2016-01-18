help:
	@echo "serve - serve gollum caves wiki"
	@echo "init  - initialize this wiki"

init:
	mkdir -p wiki/wiki
	mkdir -p wiki/wiki/me
	mkdir -p wiki/wiki/home
	mkdir -p wiki/wiki/skeleton
	mkdir -p wiki/wiki-plugins/me
	cd wiki/wiki/me && git init
	cd wiki/wiki/home && git init
	cd wiki/wiki/skeleton && git init
	cd wiki/wiki-plugins/me && git init

init-bare:
	mkdir -p wiki/wiki/
	git init --bare wiki/wiki/me.git
	git init --bare wiki/wiki/home.git
	git init --bare wiki/wiki/skeleton.git

serve:
	rackup config.ru
