--Pendulum Zombie Warrior
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013049.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),aux.FilterBoolFunctionEx(Card.IsRace, RACE_WARRIOR))
	--Place
	Qued.AddRPepeEffect(c,id)
	--Gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetTargetRange(1,0)
	e1:SetValue(cod.val)
	c:RegisterEffect(e1)
	--Destroy
end

function (e,c)
	return Duel.GetMatchingGroup(Card.IsRace,c:GetControler(),LOCATION_MZONE,0,nil,RACE_ZOMBIE):GetSum(Card.GetAttack)/2
end
