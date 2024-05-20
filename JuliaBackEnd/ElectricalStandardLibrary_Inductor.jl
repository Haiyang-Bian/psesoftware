function ElectricalStandardLibrary_Inductor(;name, L = 20, )
@named inlet = ElectricalPort()
@named outlet = ElectricalPort()

@parameters L=L

@variables v(t)=0 [bounds=(-Inf, Inf),]
v = setmetadata(v, Ai4EnergyMetaData, "Data(:Voltage, 0, (-Inf, Inf), 1, false, (), V, 1.0, :Equal, nothing)")
@variables i(t)=0 [bounds=(-Inf, Inf),]
i = setmetadata(i, Ai4EnergyMetaData, "Data(:Current, 0, (-Inf, Inf), 1, false, (), A, 1.0, :Equal, nothing)")

eqs = Equation[]
@equations inlet.v - outlet.v = v
@equations inlet.i + outlet.i = 0
@equations i = inlet.i
@equations v = L * Diff(i)
return compose(ODESystem(eqs, t, [v;i;], [L;]; name=name), [inlet;outlet;])
end