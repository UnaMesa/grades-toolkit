

Router.map ->

    # Hook for Google Push Notifications once we have a valid SSL cert
    @route "googleCallback",
        path: "/notifications/:id"
        where: 'server'

        action: ->
            switch (@params.id)
                when "familyListUpdate"
                    console.log("Family update callback called")
                    @response.writeHead 200,
                        'Content-Type': 'text/html'
                    @response.write "Updated Family List"
                else
                    console.log("Bad callback call")
                    @response.writeHead 404,
                        'Content-Type': 'text/html'
                    @response.write "Not Found"
            

   