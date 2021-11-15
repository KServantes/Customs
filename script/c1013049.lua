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
	e1:SetTarget(cod.tg)
	e1:SetValue(cod.val)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCondition(cod.descon)
	e2:SetTarget(cod.destg)
	e2:SetOperation(cod.desop)
	c:RegisterEffect(e2)
end

function cod.tg(e,c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsType(TYPE_EFFECT)
end

function cod.val(e)
	local c=e:GetHandler()
	return Qued.GetBaseAttackOnField(c)/2
end

function cod.filter(c,tp)
	return	c:IsReason(REASON_BATTLE) and c:GetReasonCard():IsType(TYPE_PENDULUM+TYPE_NORMAL)
		and c:IsControler(1-tp) and c:GetReasonCard():IsControler(tp) and c:GetPreviousLocation()==LOCATION_MZONE
end
function cod.descon(e,tp,eg,ep,ev,re,r,rp)
	if #eg>1 then return end
	if cod.filter(eg:GetFirst(),tp) then
		e:SetLabel(eg:GetFirst():GetPreviousSequence())
		return true
	end
end
function cod.desf(c,seq)
	if seq<=4 then
		if seq-1<=0 then return true end
		if seq+1>=4 then return true end
		return	c:IsSequence(seq-1) or c:IsSequence(seq+1)
	else
		return c:IsSequence(5) or c:IsSequence(6)
	end
end
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.desf,tp,0,LOCATION_MZONE,1,nil,e:GetLabel()) end
	local g=Duel.GetMatchingGroup(cod.desf,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,LOCATION_MZONE)
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.desf,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.Destroy(g,REASON_EFFECT)
end