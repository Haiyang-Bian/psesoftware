function ElectricalStandardLibrary_Ground(;name,  )
@named inlet = ElectricalPort()



eqs = Equation[]
@equations inlet.v = 0
return compose(ODESystem(eqs, t, [], []; name=name), [inlet;])
end