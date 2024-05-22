function ElectricalStandardLibrary_IdealDiode(;name,  )
@named inlet = ElectricalPort()
@named outlet = ElectricalPort()



eqs = Equation[]
@equations inlet.v - outlet.v = ifelse(inlet.v > outlet.v, 0, 10^9)
@equations inlet.i + outlet.i = 0
return compose(ODESystem(eqs, t, [], []; name=name), [inlet;outlet;])
end