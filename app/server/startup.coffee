
Meteor.startup ->
    console.log("Server Startup")

    console.log("tp", tagToTagObject("tp"))
    console.log("tp1", tagToTagObject("tp1"))
    console.log("nn1", tagToTagObject("nn1"))


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
    
