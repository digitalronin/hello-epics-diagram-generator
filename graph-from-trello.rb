#!/usr/bin/env ruby

require 'bundler/setup'
require 'trello'

# Script to generate a graphviz file from the parent/child card relationships
# of a [trello](https://trello.com) board that features the
# [HelloEpics](https://helloepics.com/) power-up

BOARD_ID = '{{{{ ID OF THE TRELLO BOARD GOES HERE }}}}'

@attrs        = []
@links        = {}
@initials     = {}
@list_colours = {}

def main
  configure
  walk_the_tree
  output_graphviz_config
end

def walk_the_tree
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

  board = Trello::Board.find(BOARD_ID)

  backlog = board.lists.find {|l| l.name.downcase == 'backlog'}
  doing   = board.lists.find {|l| l.name.downcase == 'doing'}
  done    = board.lists.find {|l| l.name.downcase == 'done'}

  # Depending on whether the card is in the Backlog/Doing/Done list,
  # we want the corresponding node to be red/orange/green.
  @list_colours[backlog.id] = 'red'
  @list_colours[doing.id]   = 'orange'
  @list_colours[done.id]    = 'green'
end

def get_card_by_name(name)
  Trello::Board.find(BOARD_ID).cards.detect {|card| card.name == name}
end

main
