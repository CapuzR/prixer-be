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

Create 1

` dfx --identity default canister call prixerbe createArt '(record {artBasics=record {title= "Camino de Dios"; about= "Beach and sun"; artType= record { id="AF5B725E-7019-4C72-956B-E81084A7E532"; name="Photo"; description="The art of capture a moment and its soul."; }  }; artRequest=variant { Put=record{ key= "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae"; contentType= "image/jpeg"; payload = variant{ Payload = vec{ 0x00 } } } } })' `

Read

` dfx canister call prixerbe readAllArt '()' ` 3

` dfx canister call prixerbe privReadArt '("CB40C895-9477-40BD-8970-310C929CF3D7")' `

` dfx canister call prixerbe readArtById '("7277B970-E86A-42FF-B5D2-7FD2735DBA01")' `

` dfx canister call prixerbe getAssets '()' `

Update with Art Gallery 5

` dfx --identity default canister call prixerbe updateArt '(record {artBasics=record {title= "Camino de Dios"; artGalleries=opt "5E5FC525-4418-4172-8C1B-51B9AB8C59D3"; artType= record { id="AF5B725E-7019-4C72-956B-E81084A7E532"; name="Photo"; description="The art of capture a moment and its soul."; }  }; artRequest=variant { Put=record{ key= "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae"; contentType= "image/jpeg"; payload = variant{ Payload = vec{ 0x00 } } } } }, "DB3844C9-91D5-49F6-97F3-7D1048D92274")' `

Update without Art Gallery

` dfx --identity default canister call prixerbe updateArt '(record {artBasics=record {title= "Camino de Dios"; artType= record { id="AF5B725E-7019-4C72-956B-E81084A7E532"; name="Photo"; description="The art of capture a moment and its soul."; }  }; artRequest=variant { Put=record{ key= "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae"; contentType= "image/jpeg"; payload = variant{ Payload = vec{ 0x00 } } } } }, "BF17FC7E-150B-4853-B84B-C30999BC2F4E")' `

Read Art by Artist

` dfx canister call prixerbe readArtsByArtist '( principal "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae" )' `

Read Arts by Art Gallery

` dfx canister call prixerbe readArtsByArtGallery '( "5E5FC525-4418-4172-8C1B-51B9AB8C59D3" )' `


## Art Gallery

Create with artGalleryBanner

` dfx --identity default canister call prixerbe createArtGallery '(record { name= "Test Gallery"; description= "Beach and sun"; artGalleryBanner= "4D7FA36A-918A-4DE0-86DF-C9B5C0E8DE2F"  } )' `

Create without artGallerBanner

` dfx --identity default canister call prixerbe createArtGallery '(record { name= "Test Gallery"; description= "Beach and sun"  } )' ` 2

Update

` dfx --identity default canister call prixerbe updateArtGallery '( record { name= "Test Gallery"; description= "Beach and sun"; artGalleryBanner=opt "7277B970-E86A-42FF-B5D2-7FD2735DBA01"  }, "E5EA61A1-C657-4030-89D6-546857FD8E77")' ` 6

Read ArtGallery by Artist

` dfx canister call prixerbe readArtGalleriesByArtist '( principal "m5spm-rypb4-5dh4x-cfmly-f2ngh-qjvm4-wyntp-kbhfk-5mhn7-ag65r-qae" )' ` 4


 ## ArtType

 Create

` dfx canister call prixerbe createArtType '(record { name = "Photo"; description = "The art of capture a moment." } )' ` 

 Read

` dfx canister call prixerbe readArtType '()' ` 

 Update

` dfx canister call prixerbe updateArtType '(record { id = "9E3ECA0C-81A5-4EAA-8A3A-51EC8763F188"; name = "Photo"; description = "The art of capture a moment and its soul." } )' ` 

 Delete

` dfx canister call prixerbe deleteArtType '( "9E3ECA0C-81A5-4EAA-8A3A-51EC8763F188" )' `
