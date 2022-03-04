
module {

    public type Artist = {
        createdAt: Int;
        tools: [ToolUpdate];
    };

    public type Art = {
        artistPpal: Principal;
        title: Text;
        artType: ArtTypeUpdate;
        artCategory: ArtCategoryUpdate;
        tools: [ToolUpdate];
        tags: [Text];
        about: Text;
        artGalleries: [Nat]; //DUDA
    };

    public type ArtGallery = {
        name: Text;
        description: Text;
        artIds: [Nat];
    };

    public type ArtType = {
        name: Text;
        description: Text;
    };

    public type ArtTypeUpdate = {
        id: Text;
        name: Text;
        description: Text;
    };

    public type ArtCategory = {
        name: Text;
        description: Text;
    };

    public type ArtCategoryUpdate = {
        id: Text;
        name: Text;
        description: Text;
    };

    public type Tool = {
        category: ToolCategoryUpdate;
        name: Text;
        description: Text;
    };

    public type ToolUpdate = {
        id: Text;
        category: ToolCategoryUpdate;
        name: Text;
        description: Text;
    };

    public type ToolCategory = {
        artType: ArtTypeUpdate;
        name: Text;
        description: Text;
    };

    public type ToolCategoryUpdate = {
        id: Text;
        artType: ArtTypeUpdate;
        name: Text;
        description: Text;
    };

    public type Error = {
        #AlreadyExists;
        #NotAuthorized;
        #Unauthorized;
        #NotFound;
        #InvalidRequest;
        #AuthorizedPrincipalLimitReached : Nat;
        #Immutable;
        #FailedToWrite : Text;
    };

    //DAB Registry standard.

    // type detail_value = variant {
    //     True;
    //     False;
    //     I64       : int64;
    //     U64       : nat64;
    //     Vec       : vec detail_value;
    //     Slice     : vec nat8;
    //     Text      : text;
    //     Float     : float64;
    //     Principal : principal;
    // };

    // type metadata = record {
    //     name         : text;
    //     description  : text;
    //     thumbnail    : text;
    //     frontend     : opt text;
    //     principal_id : principal;
    //     details      : vec record { text; detail_value }
    // };

    // type error = variant {
    //     NotAuthorized;
    //     NonExistentItem;
    //     BadParameters;
    //     Unknown : text;
    // };

    // type response = variant {
    //     Ok  : opt text;
    //     Err : error;
    // };
    
};