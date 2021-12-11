--Reitslicer, Pendulum Pirate
local cod,id=GetID()
function cod.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),4,2)
	c:EnableReviveLimit()
	--Pendulum Summon
	Pendulum.AddProcedure(c)
end
