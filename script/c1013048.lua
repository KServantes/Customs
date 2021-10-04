--Flame Pendulum Ghost
local cod, id = GetID()
function c1013048.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c,false)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_FIRE))
	--Pendulum Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
end

function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp, 1000, REASON_EFFECT)
end