
assert = require("assert") #require("assert")

suite "Cases", ->
  test "Case insert test", (done, server, client) ->
    

    server.eval ->
      console.log("server eval")
      Cases.find().observe
        added: addedNewCase
      addedNewCase = (theCase) ->
        emit "case", theCase
    

    server.once "case", (theCase) ->
      assert.equal theCase.name, "Test Me"
      done()
    

    client.eval ->
      rtn = Meteor.call "newCase",
        name: "Test Me"
      console.log("rtn", rtn)
      emit "insert", rtn


    client.once "insert", (rtn) ->
      console.log("insert done")
      #assert.equal rtn, 1



