 ## Artist (Falta agregarle id a todos los extras: tools, artType, etc)

 Create

` dfx canister call prixerbe createArtist '(vec { record { id = 0; category = record { id=0; artType= record { id=0; name = "Photo"; description = "The art of capture a moment and its soul."; }; name = "Camera"; description = "Camera"; }; name = "Canon EOS R"; description= "Canon EOS R"; }; } )' ` 

 Read

` dfx canister call prixerbe readArtist '()' ` 

 Update

` dfx canister call prixerbe updateArtist '(vec { record { id = 0; category = record { id=0; artType= record { id=0; name = "Photo"; description = "The art of capture a moment and its soul."; }; name = "Camera"; description = "Camera"; }; name = "Canon EOS R"; description= "Canoooon"; }; } )' ` 

 Delete

` dfx canister call prixerbe deleteArtist '()' `

## Art

Create

` dfx --identity default canister call prixerbe createArt '(record {artBasics=record {title= "Camino de Dios"; about= "Beach and sun"; artType= record { id="AF5B725E-7019-4C72-956B-E81084A7E532"; name="Photo"; description="The art of capture a moment and its soul."; }  }; avatarRequest=variant { Put=record{ key= "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae"; contentType= "image/jpeg"; payload = variant{ Payload = vec{ 0x00 } } } } })' `

Read

` dfx canister call prixerbe readAllArt '()' `

` dfx canister call prixerbe privReadArt '("CB40C895-9477-40BD-8970-310C929CF3D7")' `

` dfx canister call prixerbe getAssets '()' `

Update

` dfx --identity default canister call prixerbe updateArt '(record {artBasics=record {title= "Camino de Dios"; artType= record { id="AF5B725E-7019-4C72-956B-E81084A7E532"; name="Photo"; description="The art of capture a moment and its soul."; }  }; avatarRequest=variant { Put=record{ key= "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae"; contentType= "image/jpeg"; payload = variant{ Payload = vec{ 0x00 } } } } }, "CB40C895-9477-40BD-8970-310C929CF3D7")' `



 ## ArtType

 Create

` dfx canister call prixerbe createArtType '(record { name = "Photo"; description = "The art of capture a moment." } )' ` 

 Read

` dfx canister call prixerbe readArtType '()' ` 

 Update

` dfx canister call prixerbe updateArtType '(record { id = "9E3ECA0C-81A5-4EAA-8A3A-51EC8763F188"; name = "Photo"; description = "The art of capture a moment and its soul." } )' ` 

 Delete

` dfx canister call prixerbe deleteArtType '( "9E3ECA0C-81A5-4EAA-8A3A-51EC8763F188" )' `
