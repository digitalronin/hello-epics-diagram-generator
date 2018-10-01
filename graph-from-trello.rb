#!/usr/bin/env ruby

require 'bundler/setup'
require 'trello'
require 'pry-byebug'
require 'pp'

# Script to generate a graphviz file from the parent/child card relationships
# of a [trello](https://trello.com) board that uses the [HelloEpics](https://helloepics.com/) power-up

BOARD_ID = '{{{{ ID OF THE TRELLO BOARD GOES HERE }}}}'

@labels = []
@links  = {}

def main
  walk_the_tree
  output_graphviz_config
end

def walk_the_tree
  configure
  [
   '{{{{ Titles of all root cards go here }}}}',
  ].each {|name| process_card get_card_by_name(name)}
end

def output_graphviz_config
  puts <<EOF
digraph G {
  overlap="false"
  node [color="black", shape="rectangle", fontname="Maax", style="rounded", penwidth=3]

EOF

  puts @labels.join("\n")
  @links.each {|_key, tuple| puts %["#{tuple[0]}" -> "#{tuple[1]}"]}
  puts "}"
end

def process_card(card)
  @labels << %{"#{card.id}"    [label="#{card.name}", color="red"]}

  child_card_ids(card).each do |id|
    crd = Trello::Card.find(id)
    key = [id, card.id].join
    @links[key] = [id, card.id]
    process_card crd
  end
end

def child_card_ids(card)
  card.attachments
    .find_all {|a| a.url =~ /^https:..trello.com.c/}
    .map {|c| c.url}
    .map {|url| url.split('/').last}
end

def configure
  Trello.configure do |config|
    config.developer_public_key = ENV.fetch('TRELLO_API_KEY')
    config.member_token = ENV.fetch('TRELLO_MEMBER_TOKEN')
  end
end

def get_card_by_name(name)
  Trello::Board.find(BOARD_ID).cards.detect {|card| card.name == name}
end

main
