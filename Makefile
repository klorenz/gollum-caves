help:
	@echo "serve - serve gollum caves wiki"
	@echo "init  - initialize this wiki"

init:
	mkdir -p wiki/wiki/
	git init --bare wiki/wiki/me.git
	git init --bare wiki/wiki/home.git
	git init --bare wiki/wiki/skeleton.git

serve:
	rackup config.ru
