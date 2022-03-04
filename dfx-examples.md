 ## Artist (Falta agregarle id a todos los extras: tools, artType, etc)

 Create

` dfx canister call prixerbe createArtist '(vec { record { id = 0; category = record { id=0; artType= record { id=0; name = "Photo"; description = "The art of capture a moment and its soul."; }; name = "Camera"; description = "Camera"; }; name = "Canon EOS R"; description= "Canon EOS R"; }; } )' ` 

 Read

` dfx canister call prixerbe readArtist '()' ` 

 Update

` dfx canister call prixerbe updateArtist '(vec { record { id = 0; category = record { id=0; artType= record { id=0; name = "Photo"; description = "The art of capture a moment and its soul."; }; name = "Camera"; description = "Camera"; }; name = "Canon EOS R"; description= "Canoooon"; }; } )' ` 

 Delete

` dfx canister call prixerbe deleteArtist '()' `

 ## ArtType

 Create

` dfx canister call prixerbe createArtType '(record { name = "Photo"; description = "The art of capture a moment." } )' ` 

 Read

` dfx canister call prixerbe readArtType '()' ` 

 Update

` dfx canister call prixerbe updateArtType '(record { id = "86053678-D0A3-4F5F-833E-7A7A870D69A2"; name = "Photo"; description = "The art of capture a moment and its soul." } )' ` 

 Delete

` dfx canister call prixerbe deleteArtType '(record { id = UUID_GENERATED })' `

