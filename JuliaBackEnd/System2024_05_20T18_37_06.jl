function System2024_05_20T18_37_06(;name)
@named node_4 = ready_components[][:ElectricalStandardLibrary_Ground]()
@named node_1 = ready_components[][:ElectricalStandardLibrary_Resistor](R=20000,)
@named node_3 = ready_components[][:ElectricalStandardLibrary_IdealVoltageSource](E=25,)
@named node_2 = ready_components[][:ElectricalStandardLibrary_Capacitor](C=200,)
eqs = Equation[connect(node_1.inlet, node_4.inlet)
connect(node_1.outlet, node_2.inlet)
connect(node_2.outlet, node_3.outlet)
connect(node_3.inlet, node_4.inlet)
]
return compose(ODESystem(eqs, t, [], []; name=name), [node_4;node_1;node_3;node_2;])
end

@named sys = System2024_05_20T18_37_06()
global system = sys
