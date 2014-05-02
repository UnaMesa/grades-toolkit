
# Object to encapsulate the JSEncrypt object
encryptObj = 
    _listeners: null
    _privateKey:  null
    _publicKey:  null
    _generating: false
    _keySize: 512
    _time: null
    _encrypted: false

    init: ->
        console.log("encryptObj Init")
        if not encryptObj._listeners?
            encryptObj._listeners = new Deps.Dependency()
        #if not encryptObj._crypt
        #   encryptObj._crypt = new JSEncrypt()

    privateKey: ->
        encryptObj._listeners.depend()
        encryptObj._privateKey

    publicKey: ->
        encryptObj._listeners.depend()
        encryptObj._publicKey

    generatingKeys: ->
        encryptObj._listeners.depend()
        encryptObj._generating

    generateKeys: ->
        encryptObj._generating = true
        encryptObj._listeners.changed()
        encryptObj._crypt = new JSEncrypt
            default_key_size: encryptObj._keySize
        encryptObj._time = - (new Date()).getTime()
        console.log("generate keys")
        encryptObj._crypt.getKey ->
            encryptObj._time += (new Date()).getTime()
            encryptObj._generating = false
            encryptObj._privateKey = encryptObj._crypt.getPrivateKey()
            encryptObj._publicKey = encryptObj._crypt.getPublicKey()
            encryptObj._listeners.changed()

    keySize: ->
        if not encryptObj._listeners.depend()
            console.log("Depend Failed?")
        console.log('keySize', encryptObj._listeners.hasDependents())
        encryptObj._keySize

    setKeySize: (size) ->
        encryptObj._keySize = size
        console.log("setKeySize", encryptObj._keySize)
        encryptObj._listeners.changed()
        console.log('setKeySize', encryptObj._listeners.hasDependents())
        
    getGenerationTimeString: ->
        encryptObj._listeners.depend()
        if encryptObj._time and not encryptObj._generating
            moment.duration(encryptObj._time).asSeconds()

    encrypted: ->
        encryptObj._listeners.depend()
        encryptObj._encrypted

    encrypt: (data) ->
        encryptObj._encrypted = true
        encryptObj._listeners.changed()
        encryptObj._crypt.encrypt(data)

    decrypt: (data) ->
        encryptObj._encrypted = false
        encryptObj._listeners.changed()
        encryptObj._crypt.decrypt(data)


encryptObj.init()

#Template.encryptObjTest.created = ->
#    encryptObj.init()

Template.cryptoTest.helpers
    publicKey: ->
        encryptObj.publicKey()

    privateKey: ->
        encryptObj.privateKey()

    haveKeys: ->
        encryptObj.privateKey()? and encryptObj.publicKey()?

    generatingKeys: ->
        encryptObj.generatingKeys()

    generationTime: ->
        encryptObj.getGenerationTimeString()

    keySize: ->
        encryptObj.keySize()

    encrypted: ->
        encryptObj.encrypted()


Template.cryptoTest.events
    "click #generate-key": (e) ->
        e.preventDefault()
        encryptObj.generateKeys() # $("[name=seed]").val())

    "mouseup .change-key-size": (e) ->
        encryptObj.setKeySize($(e.target).attr('data-value'))
        
    "click #execute": (e) ->
        if not encryptObj.encrypted()
            $('#crypted').val(encryptObj.encrypt($('#input').val()))
            $('#input').val('')
        else
            $('#input').val(encryptObj.decrypt($('#crypted').val()))
            $('#crypted').val('')



