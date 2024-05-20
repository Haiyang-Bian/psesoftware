function ElectricalStandardLibrary_Capacitor(;name, C = 200, )
@named inlet = ElectricalPort()
@named outlet = ElectricalPort()

@parameters C=C

@variables v(t)=0 [bounds=(-Inf, Inf),]
v = setmetadata(v, Ai4EnergyMetaData, "Data(:Voltage, 0, (-Inf, Inf), 1, false, (), V, 1.0, :Equal, nothing)")
@variables i(t)=0 [bounds=(-Inf, Inf),]
i = setmetadata(i, Ai4EnergyMetaData, "Data(:Current, 0, (-Inf, Inf), 1, false, (), A, 1.0, :Equal, nothing)")

eqs = Equation[]
@equations inlet.v - outlet.v = v
@equations inlet.i + outlet.i = 0
@equations i = inlet.i
@equations i = C * Diff(v)
return compose(ODESystem(eqs, t, [v;i;], [C;]; name=name), [inlet;outlet;])
end