

Template.familySummaryEdit.helpers
    name: ->
        @["firstname"] + " " + @["lastname"]

    type: ->
        'family'