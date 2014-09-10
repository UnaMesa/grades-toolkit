

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


validateUserEmail = (user) ->
    console.log("validateUserEmail", user?.services?.google?.email)
    throw new Meteor.Error(403, "You are not authorized to use this site") unless user?.services?.google?.email?
    
    email = user.services.google.email.toLowerCase()
    validEmail = ValidUsers.findOne
        email: email
    if not validEmail
        console.log("Invalid email not in list", email)
        throw new Meteor.Error(403, "You are not authorized to use this site")
    else
        true

Accounts.validateNewUser (user) ->
    validateUserEmail(user)
    

Accounts.validateLoginAttempt (attempt) ->
    validateUserEmail(attempt.user)
    



