

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


