function ElectricalStandardLibrary_IGBT(;name,  )
@named G = ElectricalPort()
@named E = ElectricalPort()
@named C = ElectricalPort()



eqs = Equation[]
@equations C.v - E.v = ifelse(G.v > 0, 0, 10^9)
@equations C.i + E.i = 0
return compose(ODESystem(eqs, t, [], []; name=name), [G;E;C;])
end