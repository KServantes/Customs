--Blood Omen - Charity
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function c1013212.initial_effect(c)
	--Linku
	c:EnableReviveLimit()
	Qued.AddLinkProc(c,id,4)
	--Become Quick
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(id)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	c:RegisterEffect(e2)
end