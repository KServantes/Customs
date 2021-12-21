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
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_PZONE)
		--for copy effect
	e1:SetLabel(CARD_AZEGAHL)
	e1:SetTarget(cod.tg)
	e1:SetValue(1200)
	c:RegisterEffect(e1)
	
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
			--for copy effect
	e2:SetLabel(CARD_AZEGAHL)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(cod.discon)
	e2:SetOperation(cod.disop)
	c:RegisterEffect(e2)
end

function cod.tg(e,c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsType(TYPE_EFFECT)
end

function cod.discon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and not a:IsType(TYPE_EFFECT) and a:IsRace(RACE_ZOMBIE)
end
function cod.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e2)
	Duel.AdjustInstantly(tc)
end