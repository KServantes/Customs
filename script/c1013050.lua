--Pendulum Mammoth of Goldfine
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013050.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),aux.FilterBoolFunctionEx(Card.IsRace, RACE_WARRIOR))
	--Place
	Qued.AddRPepeEffect(c,id)
	--Drain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(cod.tg)
	e1:SetValue(-2200)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(cod.limit)
	c:RegisterEffect(e2)
end

function cod.tg(e,c)
	local tp=e:GetHandlerPlayer()
	return	return c:IsType() and c:IsControler(1-tp)
end
function cod.limit(e,te,tp)
	return te:IsActiveType(TYPE_MONSTER+TYPE_EFFECT) and te:GetHandler():GetTurnID()==Duel.GetTurnCount()
end