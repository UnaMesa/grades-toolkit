Grades Toolkit Change Log
=========================

11/28/13 - TEP
	
	Family photos with carousel.

11/22/13 - TEP

	Added the photo-uploader package so we can now upload or take photos and crop for using with cases and families.  Currently only does the profile picture.

11/15/13 - TEP

	Added code to use the Google Oauth refresh token to retrieve a new one.

11/14/13 - TEP

	Cleaned up CSS so that records look the same.
	Fixed some issues with male/female
	Fixed issues with message counts
	Add a message on case insert
	

11/13/13 - TEP

	Worked on making form validation work better and fixing the schema so it would work with the validation package.  Probably need to write my own validation since the packages leave something to be desired.
	
11/12/13 - TEP

	Fixed a freeze bug that would happen if no google drive records available
	Fixed tag links not showing up in messages.  
	Fixed Family tags wanting to be @ instead of #.
	Deleted old case record with BID embedded in case instead of sub doc.
	

11/11/13 - TEP
	
	Have family records updating from spreadsheet
	Family details view with hooks for family tags in messages
	Google drive from server to server working.  This requests docs that
	have been shared with the server app id.  The email address that google
	assigns.  The files with the credentials are in the private directory 
	and not in github.
	Add beginning hooks for contact details

11/8/13 - TEP

	Passing google auth token around so that we only have to authenticate once. Needs more testing
	Created sub-dirs in the server dir.
	Working on getting the google node api to work.  So we can pull file from google drive when user is offline.


11/7/13 - TEP
	
	On BID or Case update generate a new message for the stream
	More UI tweaks to make it look like twitter and not iChat
	Bug fixes and some bullet proofing


11/6/13 - TEP

	BID form now updates into Cases collection on "submit"
	Changed tags so that users are @ and cases are still #
	Families are currently also set up to be @
	All tags for a message now display below the message with links


11/5/13 - TEP

	Major UI redesign.  Twitter like with blocking dialog for new messages
	Scrolling now in window and not subframe.  iOS Safari behaves better


11/2/2013 - TEP
	
	Links to MOU and BID forms.	
	Unique Tag creation for users
	Bad tag detection on message stream
	Messages can now be filtered by type and a record _id
	Filtered message boxes on other pages
	Message box sizing on case page
	Collapse on case page


11/1/2013-11/2/2013 - TEP
	
	See commit log
	

10/30/2013 - TEP
	
	Turned alert package into an atmosphere package
	Added names on chats
	Formatting of pages
	Bubble arrow
	
10/29/2013 - TEP

    Added in Cases and hooks for notes
    Added back link
    Added bootstrap-switch as a local package for doing the mobile switch
    Added this CHANGELOG
    A bunch of other stuff
    
10/27/2013 - TEP
    
    Changed look and feel targeting iPhone.  
    Google Authentication
    Generic message page.  Look like iMessages
    Contacts page
    Other page stubs
    
10/26/2013 - TEP
	
	Initial start?
