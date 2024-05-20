@connector ElectricalPort begin
v(t)=0.0, [bounds=(-Inf, Inf),]
begin
	v = setmetadata(v, Ai4EnergyMetaData, "Data(:Voltage, 0.0f0, (-Inf, Inf), 1, false, (), V, 1, :Equal, nothing)")
end

i(t)=0.0, [bounds=(-Inf, Inf),connect=Flow]
begin
	i = setmetadata(i, Ai4EnergyMetaData, "Data(:Current, 0.0f0, (-Inf, Inf), 1, false, (), A, 1, :Flow, nothing)")
end

end
@connector ElectricalPort begin
v(t)=0.0, [bounds=(-Inf, Inf),]
begin
	v = setmetadata(v, Ai4EnergyMetaData, "Data(:Voltage, 0.0f0, (-Inf, Inf), 1, false, (), V, 1, :Equal, nothing)")
end

i(t)=0.0, [bounds=(-Inf, Inf),connect=Flow]
begin
	i = setmetadata(i, Ai4EnergyMetaData, "Data(:Current, 0.0f0, (-Inf, Inf), 1, false, (), A, 1, :Flow, nothing)")
end

end
