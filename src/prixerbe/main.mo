
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import List "mo:base/List";
import Time "mo:base/Time";
import Types "./types";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Source "mo:uuid/async/SourceV4";
import UUID "mo:uuid/UUID";

actor {

    //Types definitions.
    type Artist = Types.Artist;
    type Art = Types.Art;
    type ArtGallery = Types.ArtGallery;
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
    stable var arts : Trie.Trie<Nat, Art> = Trie.empty();
    stable var artGalleries : Trie.Trie<Nat, ArtGallery> = Trie.empty();

    stable var artTypes : List.List<ArtTypeUpdate> = List.nil();
    stable var artCategories : List.List<ArtCategoryUpdate> = List.nil();
    stable var tools : List.List<ToolUpdate> = List.nil();
    stable var toolCategories : List.List<ToolCategoryUpdate> = List.nil();


    //CRUD Methods.

    //Artist CRUD.
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

//Admin CRUDs
    //ArtType CRUD.
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
        Debug.print(debug_show(UUID.toText(await g.new())));

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
            // List.iterate(
            //     artTypes, 
            //     func (at : ArtTypeUpdate) { 
            //         if(at.id == artType.id) {
            //             let id = at.id;
            //             let tempArtType: ArtTypeUpdate = {
            //                 id = at.id;
            //                 name = artType.name;
            //                 description = artType.description;
            //             };
            //             // deleteArtType(id); //Debo arreglar esto.
            //             let partArtTypes : List.List<ArtTypeUpdate> = List.partition(
            //                 artTypes, 
            //                 func ( a : ArtTypeUpdate ) { if(a.id == artType.id) { return true; }; return false; }).0;
            //             let newArtTypes : List.List<ArtTypeUpdate> = List.push(tempArtType, partArtTypes);
            //             artTypes := newArtTypes;
            //             val := #ok(());
            //         };
            //     }
            // );
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

    public query(msg) func readAllArtTypes () : async Result.Result<List.List<ArtTypeUpdate>, Error> {
        // Get caller principal
        let callerId = msg.caller;
        let textCallerId : Text = Principal.toText(callerId);
        var val : Result.Result<ArtTypeUpdate, Error> = #err(#NotFound);

        // Reject AnonymousIdentity
        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        if(List.isNil(artTypes)) { return #err(#NotFound); };

        return #ok(artTypes);
    };

    //Utils.
    private func key(x : Principal) : Trie.Key<Principal> {
        return { key = x; hash = Principal.hash(x) }
    };

    //DAB Registry standard.

    // public func name() : async Text {
    //     return "Hello, " # name # "!";
    // };

    // public func get(name : Text) : async Text {
    //     return "Hello, " # name # "!";
    // };

    // public func add(name : Text) : async Text {
    //     return "Hello, " # name # "!";
    // };

    // public func remove(name : Text) : async Text {
    //     return "Hello, " # name # "!";
    // };

};
