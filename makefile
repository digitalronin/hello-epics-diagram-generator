diagram.png: diagram.gv
	dot -Tpng -Gdpi=300 diagram.gv -o diagram.png
	open diagram.png

diagram.gv: graph-from-trello.rb
	source .env; ./graph-from-trello.rb > diagram.gv

clean:
	rm diagram.*

.PHONY: clean
