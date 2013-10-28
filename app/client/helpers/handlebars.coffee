
Handlebars.registerHelper 'pluralize', (n, thing) -> # fairly stupid pluralizer
    if n is 1
        '1 ' + thing
    else
        n + ' ' + thing + 's'

Handlebars.registerHelper 'formatDate', (time) ->
    new Date(time).toString()