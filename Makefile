help:
	@echo "serve - serve gollum caves wiki"

dev-install-bootstrap:
	cp -r bower_components/bootstrap/dist public/gollum-caves/bootstrap

dev-install-jsonform:
	mkdir -p public/gollum-caves/javascript/jsonform
	cp -r bower_components/jsonform/lib/* public/gollum-caves/javascript/jsonform
	cp -r bower_components/jsonform/deps public/gollum-caves/javascript/jsonform

dev-glyphs:
	fontello-cli install --config public/gollum-caves/fonts/config.json \
	--font public/gollum-caves/fonts/ --css public/gollum-caves/css/

dev-open-fontello:
	fontello-cli open --config public/gollum-caves/fonts/config.json


serve:
	bundle exec rackup config.ru
