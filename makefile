# configured in ~/.ssh/config
HOST := '{{{{ Your VPS name }}}'

sync:
	rm -f diagram.gv
	make public/diagram.svg

public/diagram.svg: diagram.gv
	dot -Tsvg diagram.gv -o public/diagram.svg

diagram.gv: graph-from-trello.rb
	. ./.env; ./graph-from-trello.rb > diagram.gv

clean:
	rm -f diagram.* public/diagram.*

deploy:
	rsync -rv * $(HOST):

ssh:
	ssh $(HOST)

.PHONY: clean sync deploy ssh
