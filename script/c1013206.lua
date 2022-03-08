--Blood Omen - Lyria
local cod,id=GetID()
-- Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(cod.negcon)
	e1:SetCost(cod.negcost)
	e1:SetTarget(cod.negtg)
	e1:SetOperation(cod.negop)
	c:RegisterEffect(e1)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(cod.acttg)
	e2:SetOperation(cod.actop)
	c:RegisterEffect(e2)
end

--negate
function cod.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function cod.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cod.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cod.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

--activate
function cod.actfilter(c,e,tp)
	return c:IsSetCard(0xd3d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetActivateEffect():IsActivatable(tp,true,false)
end
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.actfilter,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local se=sc:GetActivateEffect()
	local tg=se:GetTarget()
	local op=se:GetOperation()
	e:SetCategory(se:GetCategory())
	sc:CreateEffectRelation(se)
	if tg then tg(se,tp,eg,ep,ev,re,r,rp,1) end
	sc:CancelToGrave(false)
	Duel.BreakEffect()
	sc:SetStatus(STATUS_ACTIVATED,true)
	if op and not sc:IsDisabled() then op(se,tp,eg,ep,ev,re,r,rp,1) end
	sc:ReleaseEffectRelation(se)
end
