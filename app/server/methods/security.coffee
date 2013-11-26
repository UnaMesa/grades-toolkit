
Meteor.methods getHash: (myString) ->
  CryptoJS.HmacSHA256(myString, "XLBMgXXf2E_K_73bRIUJ53RMyBYBZjO4ViWMOoA_").toString()

