require_relative 'parser'

START_PAGE = 1
END_PAGE   = 10

Parser.new(START_PAGE, END_PAGE)
      .parse
      .to_json('items.json')
      .to_csv('items.csv')
