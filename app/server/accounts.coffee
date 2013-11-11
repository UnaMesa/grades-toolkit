

Accounts.onCreateUser (options, user) ->
    if options.profile
        user.profile = options.profile
        if user.profile.name?
            user.tag = createUserTag(user.profile.name)
            console.log("New User", user.profile.name, user.tag)
        else
            console.log("No profile.name for new user", user) 
    else
        console.log("No profile for new user", user) 
    user

