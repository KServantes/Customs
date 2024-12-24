--Blood Omen - Theoliss
local cod,id=GetID()
function cod.initial_effect(c)
	c:AddSetcodesRule(id,false,0x601)
	--dark synchro summon
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTunerEx(Card.IsSetCard,0xd3d),aux.FilterBoolFunctionEx(Card.IsSetCard,0xd3d),3)
	--back to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return (e:GetHandler():GetSummonType()&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO) end)
	e3:SetTarget(cod.rettg)
	e3:SetOperation(cod.retop)
	c:RegisterEffect(e3)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_EQUIP)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(cod.condition)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.operation)
	c:RegisterEffect(e1)
end

--synchro unsummon
function cod.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) then return end
	Duel.SetChainLimitTillChainEnd(function(e,re,rp) return rp~=tp end)
end

--banish and draw
function cod.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re and re:GetHandler()
	return rc and rc:IsSetCard(SET_BLOOD_OMEN)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.Draw(tp,1,REASON_EFFECT)
end

--lp cost filters
function cod.sumtg(e,c)
	return c:GetRace()~=RACE_ZOMBIE
end
function cod.ccost(e,c,tp)
	return Duel.CheckLPCost(tp,1000)
end
function cod.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,1000)
end

function cod.rfilter(c,codes)
	return c:IsAbleToDeck() and (c:IsCode(codes) or c:ListsCodeWithArchetype(codes) or c:ListsCode(codes) or c:ListsCodeAsMaterial(codes))
end
function cod.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cod.rfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e:GetHandler():GetCode())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
end
function cod.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cod.rfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e:GetHandler():GetCode())
	local og=g:Filter(Card.IsControler,nil,tp)
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,tp)
	Duel.SendtoDeck(og,1-tp,SEQ_DECKSHUFFLE,1-tp)
end