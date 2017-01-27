// RUN: %target-swift-frontend -emit-silgen %s | %FileCheck %s

protocol Associated {
  associatedtype Assoc
}

struct Abstracted<T: Associated, U: Associated> {
  let closure: (T.Assoc) -> U.Assoc
}

struct S1 {}
struct S2 {}

// CHECK-LABEL: sil hidden @_TF21same_type_abstraction28callClosureWithConcreteTypes
// CHECK:         function_ref @_TTR
func callClosureWithConcreteTypes<T: Associated, U: Associated>(x: Abstracted<T, U>, arg: S1) -> S2 where T.Assoc == S1, U.Assoc == S2 {
  return x.closure(arg)
}

// Problem when a same-type constraint makes an associated type into a tuple

protocol MyProtocol {
    associatedtype ReadData
    associatedtype Data

    func readData() -> ReadData
}

extension MyProtocol where Data == (ReadData, ReadData) {
  // CHECK-LABEL: sil hidden @_TFe21same_type_abstractionRxS_10MyProtocolwx4DatazTwx8ReadDatawxS2__rS0_11currentDatafT_wxS1_ : $@convention(method) <Self where Self : MyProtocol, Self.Data == (Self.ReadData, Self.ReadData)> (@in_guaranteed Self) -> (@out Self.ReadData, @out Self.ReadData)
  func currentData() -> Data {
    // CHECK: bb0(%0 : $*Self.ReadData, %1 : $*Self.ReadData, %2 : $*Self):
    // CHECK:   [[READ_FN:%.*]] = witness_method $Self, #MyProtocol.readData!1 : $@convention(witness_method) <τ_0_0 where τ_0_0 : MyProtocol> (@in_guaranteed τ_0_0) -> @out τ_0_0.ReadData
    // CHECK:   apply [[READ_FN]]<Self>(%0, %2) : $@convention(witness_method) <τ_0_0 where τ_0_0 : MyProtocol> (@in_guaranteed τ_0_0) -> @out τ_0_0.ReadData
    // CHECK:   [[READ_FN:%.*]] = witness_method $Self, #MyProtocol.readData!1 : $@convention(witness_method) <τ_0_0 where τ_0_0 : MyProtocol> (@in_guaranteed τ_0_0) -> @out τ_0_0.ReadData
    // CHECK:   apply [[READ_FN]]<Self>(%1, %2) : $@convention(witness_method) <τ_0_0 where τ_0_0 : MyProtocol> (@in_guaranteed τ_0_0) -> @out τ_0_0.ReadData
    // CHECK:   return
    return (readData(), readData())
  }
}
