--Blood Omen - Zona
local cod,id=GetID()
function cod.initial_effect(c)
	c:AddSetcodesRule(id,false,0x601)
	--dark synchro summon
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTunerEx(Card.IsSetCard,0xd3d),aux.FilterBoolFunctionEx(Card.IsSetCard,0xd3d),5)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cod.condition)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.operation)
	c:RegisterEffect(e1)
	--tribute
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_EQUIP)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(cod.con)
	e2:SetTarget(cod.contg)
	e2:SetOperation(cod.conop)
	c:RegisterEffect(e2)
end

--banish
function cod.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) 
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)  end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #g<=0 then return end
	Duel.Remove(g,nil,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end

function cod.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0xd3d)
end
function cod.filter(c)
	return c:IsAbleToChangeControler() and (c:GetSequence()<5 or Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0)
end
function cod.contg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(1-tp,Card.IsFaceup,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,0,0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function cod.tfilter(c,g)
	return g:IsContains(c)
end
function cod.conop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g<=0 then return end
	local tg=g:GetMaxGroup(Card.GetAttack)
	local rg=Duel.SelectReleaseGroup(1-tp,cod.tfilter,1,1,nil,tg)
	if not rg then return end
	Duel.Release(rg,REASON_RULE)
end