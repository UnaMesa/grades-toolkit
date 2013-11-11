
Meteor.startup ->
    console.log("Server Startup")

    # Update cases with no tag
    Cases.find(
        "tag":
            "$exists" : false
    ).forEach (rec) ->
        tag = createCaseTag(rec.name)
        console.log("Adding tag for case #{rec.name} -> #{tag}")
        Cases.update rec._id,
            $set:
                tag: tag
        , (error, result) ->
            if error
                console.log("Error adding tag", error)
            else
                console.log("Adding Tag successful")


    Meteor.users.find().forEach (rec) ->
        console.log('user', rec.profile.name, rec.tag)
        if rec.tag?[0] is '#'
            tag = createUserTag(rec.profile.name)
            Meteor.users.update rec._id,
                $set:
                    tag: tag
            , (error, result) ->
                if error
                    console.log("Error changing user tag", error)
                else
                    console.log("Adding user tag successful")

    gDrive.authTest()

    gDrive.getFamilyList()

    #
    #  Redefine the callback
    #
    ###
    origROR = Package.oauth.Oauth._renderOauthResults

    Package.oauth.Oauth._renderOauthResults = (res, query) ->
        console.log("_renderOauthResults")
        ##console.log(res)
        console.log(query)
        if false # query.close?
            console.log("close request")
            res.writeHead 302, 
                'Location': "http://localhost:3000/cases"
            res.end();  
            #
            #res.writeHead 200, 
            #    'Content-Type': 'text/html' 
            #content = '<html><head><script>document.location="/home";</script></head><body>Here</body></html>'
            #res.end(content, 'utf-8');
            #   
        else
            origROR(res, query)

    
    Package.oauth.Oauth._renderOauthResults = (res, query) ->
        console.log("_renderOauthResults")
        if 'close' in query
            console.log("close request")
            res.writeHead 200, 
                'Content-Type': 'text/html' 
            content = '<html><head><script>window.close()</script></head></html>'
            res.end(content, 'utf-8');   
        else if query.redirect?
            res.writeHead 302,
                'Location': query.redirect
            res.end(); 
        else
            console.log("Unknown Oauth Call")
            res.writeHead 200, 
                'Content-Type': 'text/html' 
            res.end("", 'utf-8'); 
    ###
    
