# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Video.create(title: "south park", description: "a funny show", small_cover_url: '/tmp/south_park.jpg')
Video.create(title: "family guy", description: "another funny show", small_cover_url: '/tmp/family_guy.jpg')