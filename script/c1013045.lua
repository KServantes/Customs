--The Wandering Doomed
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Pendulum Proc
	Pendulum.AddProcedure(c)
	---==Pendulum Effect==---
	--Swap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cod.ctg)
	e1:SetOperation(cod.cop)
	c:RegisterEffect(e1)
	--Destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(cod.reptg)
	e2:SetValue(cod.repval)
	e2:SetOperation(cod.repop)
	c:RegisterEffect(e2)
end

function cod.ctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_EXTRA, 0, 1, nil) end
end
function cod.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_EXTRA, 0, 1, 1, nil)
	if Duel.SendtoExtraP(c,nil,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.MoveToField(sg:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
	end
end

function cod.filter(c,tp)
	return (c:IsReason(REASON_DESTROY) or c:GetDestination()==LOCATION_REMOVED) 
		and c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_ZOMBIE)
end
function cod.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local con = Duel.GetMatchingGroupCount(Card.IsFaceup, tp, LOCATION_EXTRA, 0, nil)
	if chk==0 then return eg:IsExists(cod.filter,1,nil,tp) and con~=0 and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end
function cod.repval(e,c)
	return cod.filter(c,e:GetHandlerPlayer())
end
function cod.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_EXTRA, 0 , 1, 1, nil)
	Duel.SendtoGrave(g, REASON_EFFECT)
end