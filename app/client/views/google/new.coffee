

Template.newGoogleDoc.created = ->
    console.log("newGoogleDoc Template created")

Template.newGoogleDoc.rendered = ->
    console.log("googleDocTest renderd")    
    gDrive.init()


Template.newGoogleDoc.events
    "click #cancel": (e) ->
        e.preventDefault()
        Router.go("googleDocs")

    "submit form": (e) ->
        e.preventDefault()

        doc =
            title: $(e.target).find("[name=documentTitle]").val()
            body: $(e.target).find("[name=documentBody]").val()

        if not doc.title
            CoffeeAlerts.error("Please fill in a document title")
            return


        console.log("create new doc via javascript on client", doc)

        boundary = "-------314159265358979323846"
        delimiter = "\r\n--" + boundary + "\r\n"
        close_delim = "\r\n--" + boundary + "--"
        contentType = "text/plain"
        metadata = 
            title: doc.title
            mimeType: contentType

        # Insert into current directory
        if gDrive.currentParent()?
            metadata.parents = [gDrive.currentParent()]

        base64Data = btoa(doc.body)

        multipartRequestBody = delimiter + 
            "Content-Type: application/json\r\n\r\n" + 
            JSON.stringify(metadata) + delimiter + 
            "Content-Type: " + contentType + "\r\n" + 
            "Content-Transfer-Encoding: base64\r\n" + 
            "\r\n" + base64Data + close_delim
        
        gapi.client.request(
            path: "/upload/drive/v2/files"
            method: "POST"
            params:
                uploadType: "multipart"
            headers:
                "Content-Type": "multipart/mixed; boundary=\"" + boundary + "\""

            body: multipartRequestBody
        ).execute (file) ->
            console.log("Created file", file)
            if file?.error?
                CoffeeAlerts.success("Error creating document #{file?.error?.message} #{file?.error?.code}")
            else if file.title is doc.title
                CoffeeAlerts.success("Created new doc")            
                # TODO: This needs to change.  Probably make this a modal on main page...
                Router.go("googleDocs")
            else
                CoffeeAlerts.error("Error creating document")

        
                