#
#  Subscriptions
#

Meteor.subscribe "userData"

@ContactsHandle = Meteor.subscribeWithPagination("contacts", 10)

@MessagesHandle = Meteor.subscribeWithPagination("messages", 10)

@CasesHandle = Meteor.subscribeWithPagination("cases", 10)

@FamiliesHandle = Meteor.subscribeWithPagination("families", 10)
