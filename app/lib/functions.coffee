

@typeIsArray = Array.isArray || ( value ) -> 
    return {}.toString.call( value ) is '[object Array]'


@objectToArray = (obj) ->
    out = []
    for k, v of obj
        out.push(v)
    out
    
@uniqueTags = (tags) ->
    tagObj = {}
    for tag in tags
        tagObj[tag.tag] = tag
    objectToArray(tagObj)


#
#  Function to massage data so that simple scheme is a little bit smarter
#
@massageFormData = (data, schema) ->
    for key, val of schema
        #if typeOf(val.type) is 'function'

        if not val.optional or data[key]?

            if _.isArray(val.type) and not _.isArray(data[key])
                console.log("Make into an array", key, data[key])
                data[key] = [data[key]] # A single item should also count as an array
            else
                switch val.type
                    when Boolean
                        if data[key] is 'on'
                            data[key] = true
                        else
                            data[key] = false
                    when Date 
                        if data[key] is ''
                            delete data[key]
                        else
                            m = moment(data[key])
                            if m.isValid()
                                data[key] = m.toDate()
    data