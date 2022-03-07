import Trie "mo:base/Trie";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Prelude "mo:base/Prelude";

import Rel "Rel";

/// OO-based binary relation representation.
///
/// See also: Rel module.
module {


  public type HashPair<X, Y> =
    ( X -> Hash.Hash,
      Y -> Hash.Hash );

  public type EqualPair<X, Y> =
    ( (X, X) -> Bool,
      (Y, Y) -> Bool) ;

      public type Relat<X, Y> = [(X,Y)];

  public class Rels<X, Y>(
    hash : HashPair<X, Y>,
    equal : EqualPair<X, Y>,
    init: [(X,Y)])
  {
    var rel = Rel.empty<X,Y>(hash, equal);

    if (init.size() != 0) {
      for(v in init.vals()) {
        rel := Rel.put(rel, (v.0, v.1));
      };
    };

    public func put(x : X, y : Y) {
      rel := Rel.put(rel, (x, y))
    };
    
    public func delete(x : X, y : Y) {
      rel := Rel.delete(rel, (x, y))
    };
    public func isMember(x : X, y : Y) : Bool {
      Rel.isMember(rel, x, y)
    };
    public func get0(x : X) : [Y] {
      Iter.toArray(Rel.getRelated0(rel, x))
    };
    public func get1(y : Y) : [X] {
      Iter.toArray(Rel.getRelated1(rel, y))
    };
    public func get0Size(x : X) : Nat {
      Iter.size(Rel.getRelated0(rel, x))
    };
    public func get1Size(y : Y) : Nat {
      Iter.size(Rel.getRelated1(rel, y))
    };
    public func getMap0<Z>(x : X, f : Y -> Z) : [Z] {
      Iter.toArray(Iter.map(Rel.getRelated0(rel, x), f))
    };
    public func getMap1<Z>(y : Y, f : X -> Z) : [Z] {
      Iter.toArray(Iter.map(Rel.getRelated1(rel, y), f))
    };
  };
}