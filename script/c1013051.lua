--Skelegon
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013051.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,29491031,66672569)
	--Place
	Qued.AddRPepeEffect(c,id)
	
end
