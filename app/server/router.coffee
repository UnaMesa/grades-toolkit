

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
            

    @route "familyImage",
        path: "/family/photos/:_id"
        where: 'server'

        action: ->
            console.log(@userId)
            if false #not @userId
                console.log("Bad image call no user")
                @response.writeHead 403,
                    'Content-Type': 'text/html'
                @response.write "Access Denied"
            else 
                photo = FamilyPhotos.findOne(@params._id)
                if not photo
                    console.log("Bad photo request", @params._id)
                    @response.writeHead 404,
                        'Content-Type': 'text/html'
                    @response.write "Not Found"
                else
                    console.log(photo)
                    @response.writeHead 200,
                        'Content-Type': 'text/html'
                    @response.write photo.picture
   