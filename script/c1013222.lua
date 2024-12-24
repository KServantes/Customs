--Blood Omen - Gerti
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function cod.initial_effect(c)
	--activate from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cod.actcost)
	e1:SetTarget(cod.acttg)
	e1:SetOperation(cod.actop)
	c:RegisterEffect(e1)
	--return blood cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(cod.scost)
	e2:SetCondition(cod.scon)
	e2:SetTarget(cod.stg)
	e2:SetOperation(cod.sop)
	c:RegisterEffect(e2)
end

function cod.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cod.actfilter(c,e,tp)
	return c:IsSetCard(SET_BLOOD_OMEN) and c:IsType(TYPE_BLOOD_TRAP)
end
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(cod.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,cod.actfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g<=0 then return end
	Duel.SSet(tp,g)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	g:GetFirst():RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(3300)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	g:GetFirst():RegisterEffect(e2,true)
end

function cod.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function cod.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function cod.scon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(cod.cfilter,1,nil,1-tp)
end
function cod.bfilter(c)
	return c:IsSetCard(SET_BLOOD) and c:IsAbleToHand()
end
function cod.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.bfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
end
function cod.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cod.bfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT,tp)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TO_HAND)
		e1:SetOperation(cod.damop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function cod.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(#eg*300,1-tp,REASON_EFFECT)
end