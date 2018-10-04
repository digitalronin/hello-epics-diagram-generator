#!/usr/bin/env ruby

require 'bundler/setup'
require 'trello'

# Script to generate a graphviz file from the parent/child card relationships
# of a [trello](https://trello.com) board that features the
# [HelloEpics](https://helloepics.com/) power-up

BOARD_ID = '{{{{ ID OF THE TRELLO BOARD GOES HERE }}}}'

@attrs   = []
@links    = {}
@initials = {}

# Depending on whether the card is in the Backlog/Doing/Done list,
# we want the corresponding node to be red/orange/green.
@list_colours = {
  '5bb1e69730291b4a3e4891a4' => '{{{{ ID of backlog list }}}}',
  '5bb1e69aaf5c8744a820ffe6' => '{{{{ ID of doing list }}}}',
  '5bb1e69b64f1246441f6821a' => '{{{{ ID of done list }}}}'
}

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

  puts @attrs.join("\n")
  @links.each {|_key, tuple| puts %["#{tuple[0]}" -> "#{tuple[1]}"]}
  puts "}"
end

def process_card(card)
  attrs = node_attributes(card, @list_colours[card.list_id])
  @attrs << %{"#{card.id}"    #{attrs}}

  child_card_ids(card).each do |id|
    crd = Trello::Card.find(id)
    key = [id, card.id].join
    @links[key] = [id, card.id]
    process_card crd
  end
end

def node_attributes(card, colour)
  initials = initials_for_card(card)
  assignees = initials.any? ? %[\n(#{initials.join(',')})] : ''
  str = "#{card.name}#{assignees}"
  %{[label="#{str}", URL="#{card.url}", target="_blank", color="#{colour}"]}
end

def initials_for_card(card)
  card.member_ids.each do |id|
    @initials[id] ||= Trello::Member.find(id).initials
  end
  card.member_ids.map {|id| @initials[id]}
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
