function System2024_05_22T03_50_32(;name)
@named node_0 = ready_components[][:ElectricalStandardLibrary_Capacitor](C=0.5,)
@named node_1 = ready_components[][:ElectricalStandardLibrary_IdealVoltageSource]()
@named node_3 = ready_components[][:ElectricalStandardLibrary_Resistor]()
@named node_2 = ready_components[][:ElectricalStandardLibrary_Ground]()
eqs = Equation[connect(node_0.outlet, node_1.outlet)
connect(node_1.inlet, node_2.inlet)
connect(node_3.inlet, node_2.inlet)
connect(node_3.outlet, node_0.inlet)
]
return compose(ODESystem(eqs, t, [], []; name=name), [node_0;node_1;node_3;node_2;])
end

@named sys = System2024_05_22T03_50_32()
global system = sys
