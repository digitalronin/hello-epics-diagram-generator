# Trello board diagram generator

This project generates a PNG file showing the relationship
of cards on a Trello board which represent interdependent
tasks.

The ruby script graph-from-trello.rb walks a (hardcoded)
Trello board that uses the HelloEpics plugin to define
parent/child relationships between cards.

## Usage

`make`

This will run the ruby script to fetch data from Trello
and create the `diagram.gv` file. It will then run `dot`
to generate `diagram.png` and open it (using Preview).

Make will only run the script if either diagram.gv or
diagram.png is out of date. Use `make clean` to delete
all the `diagram.*` files, then run `make` to recreate
them.

## Requirements

* [ruby](https://www.ruby-lang.org)
* [bundler](https://bundler.io/)
* [graphviz](https://www.graphviz.org/)

## Installation

* `bundle install` - or your own variant of it
* Visit [https://trello.com/app-key](https://trello.com/app-key) and generate Trello API credentials
* `cp dotenv.example .env` - then edit .env to add your Trello API credentials

## TODO

* Generate clickable diagram, with nodes linked to trello cards (SVG or html image-map)
* Set up a hosted version that auto-generates the clickable diagram every N minutes
