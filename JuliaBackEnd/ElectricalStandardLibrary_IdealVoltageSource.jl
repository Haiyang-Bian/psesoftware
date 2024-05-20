function ElectricalStandardLibrary_IdealVoltageSource(;name, E = 25, )
@named inlet = ElectricalPort()
@named outlet = ElectricalPort()

@parameters E=E


eqs = Equation[]
@equations inlet.v - outlet.v = E
@equations inlet.i + outlet.i = 0
return compose(ODESystem(eqs, t, [], [E;]; name=name), [inlet;outlet;])
end