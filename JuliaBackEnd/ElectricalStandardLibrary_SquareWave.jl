function ElectricalStandardLibrary_SquareWave(;name, T = 5, )
@named outlet = ElectricalPort()

@parameters T=T


eqs = Equation[]
@equations outlet.i = 0.01
@equations outlet.v = ifelse((t / T) - trunc(t / T) < T / 2, 1, -1)
return compose(ODESystem(eqs, t, [], [T;]; name=name), [outlet;])
end