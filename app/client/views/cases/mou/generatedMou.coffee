
Template.generatedMou.helpers
    today: ->
        moment().format('LL')

    dateOfCustody: ->
        moment(MOU.dataOfCustody).format('LL')