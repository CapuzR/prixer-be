
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import List "mo:base/List";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "./types";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Source "mo:uuid/async/SourceV4";
import UUID "mo:uuid/UUID";
import Static "./uploader/static";
import Rels "./Rels";

actor {

    //Types definitions.
    type Artist = Types.Artist;
    type Art = Types.Art;
    type ArtUpdate = Types.ArtUpdate;
    type ArtGallery = Types.ArtGallery;
    type ArtGalleryUpdate = Types.ArtGalleryUpdate;
    type ArtType = Types.ArtType;
    type ArtTypeUpdate = Types.ArtTypeUpdate;
    type ArtCategory = Types.ArtCategory;
    type ArtCategoryUpdate = Types.ArtCategoryUpdate;
    type Tool = Types.Tool;
    type ToolUpdate = Types.ToolUpdate;
    type ToolCategory = Types.ToolCategory;
    type ToolCategoryUpdate = Types.ToolCategoryUpdate;

    type Error = Types.Error;

    //State definition.
    stable var artists : Trie.Trie<Principal, Artist> = Trie.empty();
    stable var arts : Trie.Trie<Text, Art> = Trie.empty();
    stable var artGalleries : Trie.Trie<Text, ArtGallery> = Trie.empty();

    stable var artTypes : List.List<ArtTypeUpdate> = List.nil();
    stable var artCategories : List.List<ArtCategoryUpdate> = List.nil();
    stable var tools : List.List<ToolUpdate> = List.nil();
    stable var toolCategories : List.List<ToolCategoryUpdate> = List.nil();

    stable var artAssetsEntries : [(
        Text,        // Asset Identifier (path).
        Static.Asset // Asset data.
    )] = [];
    let artAssets = Static.Assets(artAssetsEntries);

    stable var artistArtRelEntries : [(
        Principal,
        Text
    )] = [];

    let artistArtRel = Rels.Rels<Principal, Text>((Principal.hash, Text.hash), (Principal.equal, Text.equal), artistArtRelEntries);
    
    stable var artGalleryArtRelEntries : [(
        Text,
        Text
    )] = [];

    let artGalleryArtRel = Rels.Rels<Text, Text>((Text.hash, Text.hash), (Text.equal, Text.equal), artGalleryArtRelEntries);
    
    stable var artistArtGalleryRelEntries : [(
        Principal,
        Text
    )] = [];

    let artistArtGalleryRel = Rels.Rels<Principal, Text>((Principal.hash, Text.hash), (Principal.equal, Text.equal), artistArtGalleryRelEntries);
    
    system func preupgrade() {
        if(Trie.size(arts) > 0){
            let artIter : Iter.Iter<(Text, Art)> = Trie.iter(arts);
            let artTemp : [(Text, Art)] = Iter.toArray(artIter);
            var artistArtRelTemp: Buffer.Buffer<(Principal, Text)> = Buffer.Buffer(1);
            var artGalleryArtRelTemp: Buffer.Buffer<(Text, Text)> = Buffer.Buffer(1);

            for(a in artTemp.vals()) {
                let artistArt = artistArtRel.get1(a.0);
                let artGArt = artGalleryArtRel.get1(a.0);
                if(artistArt.size() > 0) {
                    artistArtRelTemp.add(artistArt[0], a.0);
                };
                if(artGArt.size() > 0) {
                    artGalleryArtRelTemp.add(artGArt[0], a.0);
                };
            };
            artistArtRelEntries := artistArtRelTemp.toArray();
            artGalleryArtRelEntries := artGalleryArtRelTemp.toArray();
        };


        if(Trie.size(artGalleries) > 0){
            let artGIter : Iter.Iter<(Text, ArtGallery)> = Trie.iter(artGalleries);
            let artGTemp : [(Text, ArtGallery)] = Iter.toArray(artGIter);
            var artistArtGalleryRelTemp: Buffer.Buffer<(Principal, Text)> = Buffer.Buffer(1);
        
            for(a in artGTemp.vals()) {
                let artistArtGallery = artistArtGalleryRel.get1(a.0);
                if(artistArtGallery.size() > 0) {
                    artistArtGalleryRelTemp.add(artistArtGallery[0], a.0);
                };
            };
            artistArtGalleryRelEntries := artistArtGalleryRelTemp.toArray();
        };
        artAssetsEntries := Iter.toArray(artAssets.entries());
    };

    system func postupgrade() {
        artistArtRelEntries := [];
        artGalleryArtRelEntries := [];
        artistArtGalleryRelEntries := [];
        artAssetsEntries := [];
    };

//Functions.

    //Artist................................................................................
    public shared(msg) func createArtist (tools: [ToolUpdate]) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let artist: Artist = {
            createdAt = Time.now();
            tools = tools;
        };

        let (newArtists, existing) = Trie.put(
            artists,           // Target trie
            key(callerId),      // Key
            Principal.equal,    // Equality checker
            artist
        );

        // If there is an original value, do not update
        switch(existing) {
            // If there are no matches, update artists
            case null {
                artists := newArtists;
                #ok(());
            };
            // Matches pattern of type - opt Artist
            case (? v) {
                #err(#AlreadyExists);
            };
        };
    };

    public query(msg) func readArtist () : async Result.Result<Artist, Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result : ?Artist = Trie.find(
            artists,           //Target Trie
            key(callerId),      // Key
            Principal.equal     // Equality Checker
        );
        
        switch (result){
            case null {
                #err(#NotFound);
            };
            case (? v) {
                #ok(v);
            };
            };
    };

    public shared(msg) func updateArtist (tools : [ToolUpdate]) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let artist: Artist = {
            createdAt = Time.now();
            tools = tools;
        };

        let result = Trie.find(
            artists,           //Target Trie
            key(callerId),     // Key
            Principal.equal           // Equality Checker
        );

        switch (result){
            // Do not allow updates to artists that haven't been created yet
            case null {
                #err(#NotFound)
            };
            case (? v) {
                artists := Trie.replace(
                    artists,           // Target trie
                    key(callerId),      // Key
                    Principal.equal,    // Equality checker
                    ?artist
                ).0;
                #ok(());
            };
        };
    };

    public shared(msg) func deleteArtist () : async Result.Result<(), Error> {
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            artists,           //Target Trie
            key(callerId),      // Key
            Principal.equal     // Equality Checker
        );

        switch (result){
            // Do not try to delete an artist that hasn't been created yet
            case null {
                #err(#NotFound);
            };
            case (? v) {
                artists := Trie.replace(
                    artists,           // Target trie
                    key(callerId),     // Key
                    Principal.equal,   // Equality checker
                    null
                ).0;
                #ok(());
            };
        };       
    };

    //Art...............................................................................
    public shared(msg) func createArt (art : ArtUpdate) : async Result.Result<(), Error> {
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId); 

        let g = Source.Source();
        let artId = UUID.toText(await g.new());

        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        switch (art.artRequest) {
            case (#Put(data)) {
                let assetTest : Static.AssetRequest = (
                    #Put({
                        key = artId;
                        contentType = data.contentType;
                        payload = data.payload;
                        callback = data.callback;
                    })
                );

                switch (await artAssets.handleRequest(assetTest)) {
                    case (#ok())   {
                        let newArt : Art = {
                            artistPpal = callerId;
                            artBasics = art.artBasics;
                            createdAt = Time.now();
                        };

                        let (newArts, existing) = Trie.put(
                            arts,         
                            keyText(artId), 
                            Text.equal,    
                            newArt
                        );

                        switch(existing) {
                            case null {
                                arts := newArts;
                                artistArtRel.put(callerId, artId);
                                switch(art.artBasics.artGalleries) {
                                    case (null) {
                                        if(artGalleryArtRel.get1(artId).size() > 0) {
                                            artGalleryArtRel.delete(artGalleryArtRel.get1(artId)[0], artId);
                                        };
                                    };
                                    case (? ag) {
                                        if(artGalleryArtRel.get1(artId).size() > 0) {
                                            artGalleryArtRel.delete(artGalleryArtRel.get1(artId)[0], artId);
                                            artGalleryArtRel.put(ag, artId);
                                        } else {
                                            artGalleryArtRel.put(ag, artId);
                                        };
                                    }
                                };
                                #ok(());
                            };
                            case (? v) {
                                #err(#AlreadyExists);
                            };
                        };
                    };
                    case (#err(e)) { #err(#FailedToWrite(e)); };
                };
            };
            case (#Remove(_)) {
                return #err(#InvalidRequest); 
            }; 
            case (#StagedWrite(_)) {
                return #err(#InvalidRequest); 
            };
        };
    };

    public query(msg) func privReadArt (id : Text) : async Result.Result<(Art, ?Static.Asset), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };
        
        let result : ?Art = Trie.find(
            arts,           //Target Trie
            keyText(id),      // Key
            Text.equal     // Equality Checker
        );
        Debug.print(debug_show("LMAAO"));
        switch (result){
            case null {
                #err(#NotFound)
            };
            case (? r) {
                if( Principal.equal(r.artistPpal, callerId) ){
                    switch(artAssets.getToken(id)) {
                        case (#err(_)) {
                            #ok((r, null));
                        };
                        case (#ok(v))  {
                            #ok((r, ?{ contentType = v.contentType; payload = v.payload }));
                        };
                    };
                } else {
                    return #err(#NotAuthorized);
                };
            };
        };
    };

    public query(msg) func readArtById (id : Text) : async Result.Result<(Art, ?Static.Asset), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result : ?Art = Trie.find(
            arts,           //Target Trie
            keyText(id),      // Key
            Text.equal     // Equality Checker
        );
        switch (result){
            case null {
                #err(#NotFound)
            };
            case (? r) {
                switch(artAssets.getToken(id)) {
                    case (#err(_)) {
                        #ok((r, null));
                    };
                    case (#ok(v))  {
                        #ok((r, ?{ contentType = v.contentType; payload = v.payload }));
                    };
                };
            };
        };
    };

    public query(msg) func readArtsByArtist (artistPpal : Principal) : async Result.Result<[(Text, Art, Static.Asset)], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };
        //Con get0 obtengo todos los Id's de las fotos del artista
        let artistArtIds : [Text] = artistArtRel.get0(artistPpal);
        let artistArts : Buffer.Buffer<(Text, Art, Static.Asset)> = Buffer.Buffer(1);

        label af for (id in artistArtIds.vals()) {
            let result : ?Art = Trie.find(
                arts,           //Target Trie
                keyText(id),      // Key
                Text.equal     // Equality Checker
            );

            switch (result){
                case null {
                    continue af;
                };
                case (? a) {
                    switch(artAssets.getToken(id)) {
                        case (#err(_)) {
                            continue af;
                        };
                        case (#ok(v))  {
                            artistArts.add((id, a, { contentType = v.contentType; payload = v.payload })); 
                        };
                    };
                };
            };
        };
        #ok(artistArts.toArray());
    };

    public query(msg) func readArtsByArtGallery (artGalleryId : Text) : async Result.Result<[(Text, Art, Static.Asset)], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };
        //Con get0 obtengo todos los Id's de las fotos del artista
        let artGalleryArtIds : [Text] = artGalleryArtRel.get0(artGalleryId);
        let artGalleryArts : Buffer.Buffer<(Text, Art, Static.Asset)> = Buffer.Buffer(1);
        Debug.print(debug_show(artGalleryArtIds));
        label af for (id in artGalleryArtIds.vals()) {
            let result : ?Art = Trie.find(
                arts,
                keyText(id),
                Text.equal
            );

            switch (result){
                case null {
                    continue af;
                };
                case (? a) {
                    switch(artAssets.getToken(id)) {
                        case (#err(_)) {
                            continue af;
                        };
                        case (#ok(v))  {
                            artGalleryArts.add((id, a, { contentType = v.contentType; payload = v.payload })); 
                        };
                    };
                };
            };
        };
        #ok(artGalleryArts.toArray());
    };

    public query func getAssets () : async [(Text, Static.Asset)] {
        return Iter.toArray(artAssets.entries());
    };
    //Importante cambiar el Result : Result.Result<([(Text, Art, Static.Asset)]), Error>. Para esto se debe iterar y cambiar el return.
    public query(msg) func readAllArt () : async Result.Result<([(Text, Art)], [(Text, Static.Asset)]), Error> {
        
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result : Iter.Iter<(Text, Art)> = Trie.iter(arts);
        #ok((Iter.toArray(result), Iter.toArray(artAssets.entries())));
    };

    public shared(msg) func updateArt (art : ArtUpdate, artId : Text) : async Result.Result<(), Error> {
        
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);  

        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            arts,
            keyText(artId),
            Text.equal 
        );

        switch(result) {
            case null {
                #err(#NotFound)
            };
            case (? v) {
                if(Principal.equal(v.artistPpal, callerId)) {
                    switch (art.artRequest) {
                        case (#Put(data)) {
                            let assetTest : Static.AssetRequest = (
                                #Put({
                                    key = artId;
                                    contentType = data.contentType;
                                    payload = data.payload;
                                    callback = data.callback;
                                })
                            );
                            
                            switch (await artAssets.handleRequest(assetTest)) {
                                case (#ok())   {
                                    let newArt : Art = {
                                        artistPpal = v.artistPpal;
                                        artBasics = art.artBasics;
                                        createdAt = v.createdAt;
                                    };

                                    arts := Trie.replace(
                                        arts,     
                                        keyText(artId), 
                                        Text.equal,  
                                        ?newArt
                                    ).0;
                                    switch(art.artBasics.artGalleries) {
                                        case (null) {
                                            if(artGalleryArtRel.get1(artId).size() > 0) {
                                                artGalleryArtRel.delete(artGalleryArtRel.get1(artId)[0], artId);
                                            };
                                        };
                                        case (? ag) {
                                            if(artGalleryArtRel.get1(artId).size() > 0) {
                                                artGalleryArtRel.delete(artGalleryArtRel.get1(artId)[0], artId);
                                                artGalleryArtRel.put(ag, artId);
                                            } else {
                                                artGalleryArtRel.put(ag, artId);
                                            };
                                        };
                                    };
                                    return #ok(());
                                };
                                case (#err(e)) { #err(#FailedToWrite(e)); };
                            };
                        };
                        case (#Remove(_)) {
                            return #err(#InvalidRequest); 
                        }; 
                        case (#StagedWrite(_)) {
                            return #err(#InvalidRequest); 
                        };
                    };
                } else {
                    return #err(#NotAuthorized);
                };
            };
        };
    };

    public shared(msg) func deleteArt (artId : Text) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);  

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            arts,
            keyText(artId),
            Text.equal 
        );

        switch(result) {
            case null {
                #err(#NotFound)
            };
            case (? v) {
                if(Principal.equal(v.artistPpal, callerId)) {
                    let assetTest : Static.AssetRequest = (
                        #Remove({
                            key = artId;
                            callback = null;
                        })
                    );
                    
                    switch (await artAssets.handleRequest(assetTest)) {
                        case (#ok())   {
                            arts := Trie.replace(
                                arts,           // Target trie
                                keyText(artId),      // Key
                                Text.equal,    // Equality checker
                                null
                            ).0;
                            artistArtRel.delete(callerId, artId);
                            return #ok(());
                        };
                        case (#err(e)) { #err(#FailedToWrite(e)); };
                    };
                } else {
                    return #err(#NotAuthorized);
                };
            };
        };
    };

    //ArtGallery...............................................................................
    public shared(msg) func createArtGallery (artGallery : ArtGalleryUpdate) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId); 

        let g = Source.Source();
        let artGalleryId = UUID.toText(await g.new());

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let artG : ArtGallery = {
            artistPpal = callerId;
            name = artGallery.name;
            description = artGallery.description;
            artGalleryBanner = artGallery.artGalleryBanner; // ArtId
        };

        let (newArtGalleries, existing) = Trie.put(
            artGalleries,           
            keyText(artGalleryId), 
            Text.equal,    
            artG
        );

        switch(existing) {
            case null {
                artGalleries := newArtGalleries;
                artistArtGalleryRel.put(callerId, artGalleryId);
                #ok(());
            };
            case (? v) {
                #err(#AlreadyExists);
            };
        };
    };

    public query(msg) func readArtGalleriesByArtist (artistPpal : Principal) : async Result.Result<[(Text, ArtGallery)], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };
        //Con get0 obtengo todos los Id's de las fotos del artista
        let artistArtGalleryIds : [Text] = artistArtGalleryRel.get0(artistPpal);
        let artistArtGalleries : Buffer.Buffer<(Text, ArtGallery)> = Buffer.Buffer(1);

        label af for (id in artistArtGalleryIds.vals()) {
            let result : ?ArtGallery = Trie.find(
                artGalleries,
                keyText(id),
                Text.equal
            );

            switch (result){
                case null {
                    continue af;
                };
                case (? ag) {
                    artistArtGalleries.add((id, ag)); 
                };
            };
        };
        #ok(artistArtGalleries.toArray());
    };

    public shared(msg) func updateArtGallery (artGallery : ArtGalleryUpdate, artGalleryId : Text) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId); 

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            artGalleries,
            keyText(artGalleryId),
            Text.equal 
        );

        switch(result) {
            case null {
                #err(#NotFound)
            };
            case (? v) {
                if(Principal.equal(v.artistPpal, callerId)) {
                    let artG : ArtGallery = {
                        artistPpal = callerId;
                        name = artGallery.name;
                        description = artGallery.description;
                        artGalleryBanner = artGallery.artGalleryBanner; // ArtId
                    };

                    artGalleries := Trie.replace(
                        artGalleries,       
                        keyText(artGalleryId), 
                        Text.equal,  
                        ?artG
                    ).0;
                    if(artistArtGalleryRel.get1(artGalleryId).size() != 0) {
                        artistArtGalleryRel.delete(callerId, artGalleryId);
                        artistArtGalleryRel.put(callerId, artGalleryId);
                    };
                    return #ok(());
                };
                return #err(#NotAuthorized);
            };
        };
    };

    public shared(msg) func deleteArtGallery (artGalleryId : Text) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId); 

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            artGalleries,
            keyText(artGalleryId),
            Text.equal 
        );

        switch(result) {
            case null {
                #err(#NotFound)
            };
            case (? v) {
                if(Principal.equal(v.artistPpal, callerId)) {
                    artGalleries := Trie.replace(
                        artGalleries,
                        keyText(artGalleryId),
                        Text.equal,
                        null
                    ).0;
                    if(artistArtGalleryRel.get1(artGalleryId).size() != 0) {
                        artistArtGalleryRel.delete(callerId, artGalleryId);
                    };
                    return #ok(());
                };
                return #err(#NotAuthorized);
            };
        };
    };

//Admin...............................................................................
    //ArtType...............................................................................
    public shared(msg) func createArtType (artType: ArtType) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        //ID
        let g = Source.Source();
        let tempArtType: ArtTypeUpdate = {
            id = UUID.toText(await g.new());
            name = artType.name;
            description = artType.description;
        };

        let newArtTypes : List.List<ArtTypeUpdate> = List.push(tempArtType, artTypes);
        artTypes := newArtTypes;
        #ok(());
    };

    public query(msg) func readArtType (id : Text) : async Result.Result<ArtTypeUpdate, Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ArtTypeUpdate, Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(artTypes)) { return #err(#NotFound); };

        List.iterate(
            artTypes, 
            func (at : ArtTypeUpdate) { 
                if(at.id == id) {
                    val := #ok(at);
                }; 
            }
        );
        return val;
    };

    public shared(msg) func updateArtType (artType: ArtTypeUpdate) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<(), Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(artTypes) ) {
            let filteredArtTypes : List.List<ArtTypeUpdate> = List.filter(
                artTypes, 
                func ( a : ArtTypeUpdate ) : Bool {
                    if(a.id != artType.id) {
                        return true; 
                    } else {
                        false;
                    }
                }
            );
            
            let tempArtType: ArtTypeUpdate = {
                id = artType.id;
                name = artType.name;
                description = artType.description;
            };

            let newArtTypes : List.List<ArtTypeUpdate> = List.push(tempArtType, filteredArtTypes);
            artTypes := newArtTypes;
            val := #ok(());
        };
        return val;
    };

    public shared(msg) func deleteArtType (id: Text) : async Result.Result<(), Error> {
        let callerId = msg.caller;
        var tempArtTypes :  List.List<ArtTypeUpdate> = List.nil();
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(artTypes) ) {
            List.iterate(
                artTypes, 
                func (at : ArtTypeUpdate) { 
                    if(at.id != id) {
                        tempArtTypes := List.push(at, tempArtTypes);
                    };
                }
            );
            if( List.size(artTypes) != List.size(tempArtTypes) ) {
                artTypes := tempArtTypes;
                return #ok(());
            };
        };
        return #err(#NotFound);     
    };

    public query(msg) func readAllArtTypes () : async Result.Result<[ArtTypeUpdate], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ArtTypeUpdate, Error> = #err(#NotFound);
        let temp : Buffer.Buffer<ArtTypeUpdate> = Buffer.Buffer(1);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(artTypes)) { return #err(#NotFound); };

        List.iterate(
            artTypes,
            func (a : ArtTypeUpdate) {
                temp.add(a);
            }
        );

        return #ok(temp.toArray());
    };

    //ArtCategory...............................................................................
    public shared(msg) func createArtCategory (artCategory: ArtCategory) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        //ID
        let g = Source.Source();
        let tempArtCategory: ArtCategoryUpdate = {
            id = UUID.toText(await g.new());
            name = artCategory.name;
            description = artCategory.description;
        };

        let newArtCategories : List.List<ArtCategoryUpdate> = List.push(tempArtCategory, artCategories);
        artCategories := newArtCategories;
        #ok(());
    };

    public query(msg) func readArtCategory (id : Text) : async Result.Result<ArtCategoryUpdate, Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ArtCategoryUpdate, Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(artCategories)) { return #err(#NotFound); };

        List.iterate(
            artCategories, 
            func (at : ArtCategoryUpdate) { 
                if(at.id == id) {
                    val := #ok(at);
                }; 
            }
        );
        return val;
    };

    public shared(msg) func updateArtCategory (artCategory: ArtCategoryUpdate) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<(), Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(artCategories) ) {
            let filteredArtCategories : List.List<ArtCategoryUpdate> = List.filter(
                artCategories, 
                func ( a : ArtCategoryUpdate ) : Bool {
                    if(a.id != artCategory.id) {
                        return true; 
                    } else {
                        false;
                    }
                }
            );
            
            let tempArtCategory: ArtCategoryUpdate = {
                id = artCategory.id;
                name = artCategory.name;
                description = artCategory.description;
            };

            let newArtCategories : List.List<ArtCategoryUpdate> = List.push(tempArtCategory, filteredArtCategories);
            artCategories := newArtCategories;
            val := #ok(());
        };
        return val;
    };

    public shared(msg) func deleteArtCategory (id: Text) : async Result.Result<(), Error> {
        let callerId = msg.caller;
        var tempArtCategories :  List.List<ArtCategoryUpdate> = List.nil();
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(artCategories) ) {
            List.iterate(
                artCategories, 
                func (at : ArtCategoryUpdate) { 
                    if(at.id != id) {
                        tempArtCategories := List.push(at, tempArtCategories);
                    };
                }
            );
            if( List.size(artCategories) != List.size(tempArtCategories) ) {
                artCategories := tempArtCategories;
                return #ok(());
            };
        };
        return #err(#NotFound);     
    };

    public query(msg) func readAllArtCategories () : async Result.Result<[ArtCategoryUpdate], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ArtCategoryUpdate, Error> = #err(#NotFound);
        let temp : Buffer.Buffer<ArtCategoryUpdate> = Buffer.Buffer(1);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(artCategories)) { return #err(#NotFound); };
        
        List.iterate(
            artCategories,
            func (a : ArtCategoryUpdate) {
                temp.add(a);
            }
        );

        return #ok(temp.toArray());
    };

    //Tool...............................................................................
    public shared(msg) func createTool (tool: Tool) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        //ID
        let g = Source.Source();
        let tempTool: ToolUpdate = {
            id = UUID.toText(await g.new());
            category = tool.category;
            name = tool.name;
            description = tool.description;
        };

        let newTools : List.List<ToolUpdate> = List.push(tempTool, tools);
        tools := newTools;
        #ok(());
    };

    public query(msg) func readTool (id : Text) : async Result.Result<ToolUpdate, Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ToolUpdate, Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(tools)) { return #err(#NotFound); };

        List.iterate(
            tools, 
            func (at : ToolUpdate) { 
                if(at.id == id) {
                    val := #ok(at);
                }; 
            }
        );
        return val;
    };

    public shared(msg) func updateTool (tool: ToolUpdate) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<(), Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(tools) ) {
            let filteredTools : List.List<ToolUpdate> = List.filter(
                tools, 
                func ( a : ToolUpdate ) : Bool {
                    if(a.id != tool.id) {
                        return true; 
                    } else {
                        false;
                    }
                }
            );
            
            let tempTool: ToolUpdate = {
                id = tool.id;
                category = tool.category;
                name = tool.name;
                description = tool.description;
            };

            let newTools : List.List<ToolUpdate> = List.push(tempTool, filteredTools);
            tools := newTools;
            val := #ok(());
        };
        return val;
    };

    public shared(msg) func deleteTool (id: Text) : async Result.Result<(), Error> {
        let callerId = msg.caller;
        var tempTools :  List.List<ToolUpdate> = List.nil();
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(tools) ) {
            List.iterate(
                tools, 
                func (at : ToolUpdate) { 
                    if(at.id != id) {
                        tempTools := List.push(at, tempTools);
                    };
                }
            );
            if( List.size(tools) != List.size(tempTools) ) {
                tools := tempTools;
                return #ok(());
            };
        };
        return #err(#NotFound);     
    };

    public query(msg) func readAllTools () : async Result.Result<[ToolUpdate], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ToolUpdate, Error> = #err(#NotFound);
        let temp : Buffer.Buffer<ToolUpdate> = Buffer.Buffer(1);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(tools)) { return #err(#NotFound); };
        List.iterate(
            tools,
            func (t : ToolUpdate) {
                temp.add(t);
            }
        );

        return #ok(temp.toArray());
    };

    //ToolCategory...............................................................................
    public shared(msg) func createToolCategory (toolCategory: ToolCategory) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        //ID
        let g = Source.Source();
        let tempToolCategory: ToolCategoryUpdate = {
            id = UUID.toText(await g.new());
            artType = toolCategory.artType;
            name = toolCategory.name;
            description = toolCategory.description;
        };

        let newToolCategories : List.List<ToolCategoryUpdate> = List.push(tempToolCategory, toolCategories);
        toolCategories := newToolCategories;
        #ok(());
    };

    public query(msg) func readToolCategory (id : Text) : async Result.Result<ToolCategoryUpdate, Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ToolCategoryUpdate, Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(toolCategories)) { return #err(#NotFound); };

        List.iterate(
            toolCategories, 
            func (at : ToolCategoryUpdate) { 
                if(at.id == id) {
                    val := #ok(at);
                }; 
            }
        );
        return val;
    };

    public shared(msg) func updateToolCategory (toolCategory: ToolCategoryUpdate) : async Result.Result<(), Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<(), Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(toolCategories) ) {
            let filteredToolCategories : List.List<ToolCategoryUpdate> = List.filter(
                toolCategories, 
                func ( a : ToolCategoryUpdate ) : Bool {
                    if(a.id != toolCategory.id) {
                        return true; 
                    } else {
                        false;
                    }
                }
            );
            
            let tempToolCategory: ToolCategoryUpdate = {
                id = toolCategory.id;
                artType = toolCategory.artType;
                name = toolCategory.name;
                description = toolCategory.description;
            };

            let newToolCategories : List.List<ToolCategoryUpdate> = List.push(tempToolCategory, filteredToolCategories);
            toolCategories := newToolCategories;
            val := #ok(());
        };
        return val;
    };

    public shared(msg) func deleteToolCategory (id: Text) : async Result.Result<(), Error> {
        let callerId = msg.caller;
        var tempToolCategories :  List.List<ToolCategoryUpdate> = List.nil();
        let textCallerId : Text = Principal.toText(callerId);

        // Reject AnonymousIdentity
        if(textCallerId == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if( not List.isNil(toolCategories) ) {
            List.iterate(
                toolCategories, 
                func (at : ToolCategoryUpdate) { 
                    if(at.id != id) {
                        tempToolCategories := List.push(at, tempToolCategories);
                    };
                }
            );
            if( List.size(toolCategories) != List.size(tempToolCategories) ) {
                toolCategories := tempToolCategories;
                return #ok(());
            };
        };
        return #err(#NotFound);     
    };

    public query(msg) func readAllToolCategories () : async Result.Result<[ToolCategoryUpdate], Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ToolCategoryUpdate, Error> = #err(#NotFound);
        let temp : Buffer.Buffer<ToolCategoryUpdate> = Buffer.Buffer(1);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(toolCategories)) { return #err(#NotFound); };

        List.iterate(
            toolCategories,
            func (t : ToolCategoryUpdate) {
                temp.add(t);
            }
        );

        return #ok(temp.toArray());
    };

//Utils.
    private func key(x : Principal) : Trie.Key<Principal> {
        return { key = x; hash = Principal.hash(x) }
    };

    private func keyText(x : Text) : Trie.Key<Text> {
        return { key = x; hash = Text.hash(x) }
    };

};
