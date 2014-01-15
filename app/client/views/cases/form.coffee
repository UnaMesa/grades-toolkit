
Template.caseForm.rendered = ->
    $(".make-switch").bootstrapSwitch()


Template.caseForm.helpers
    isMale: ->
        if @sex is "female"
            ""
        else
            "checked"
