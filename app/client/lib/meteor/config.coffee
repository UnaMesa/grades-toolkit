#
#  Google Scopes
#
#    Drive Scopes:
#       https://developers.google.com/drive/scopes
#
#     
#

@googleScopes = [
    "https://www.googleapis.com/auth/userinfo.email"
    "https://www.googleapis.com/auth/drive.file"   # Files created by this app ?!?!
    "https://www.googleapis.com/auth/drive.readonly" # Read Only for all Files
    #"https://www.googleapis.com/auth/drive"   # All files?
    "https://www.googleapis.com/auth/drive.appdata"
    "https://www.googleapis.com/auth/drive.scripts"
]

@googleScopes.push("https://www.googleapis.com/auth/userinfo.email")
