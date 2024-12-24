--Blood Omen - Cynthesia
local cod,id=GetID()
function cod.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xd3d),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xd3d),1,99)
	c:EnableReviveLimit()
	--Add names
	Qued.RegisterExtraCodes(c,id)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(cod.thcon)
	e1:SetTarget(cod.thtg)
	e1:SetOperation(cod.thop)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_EQUIP)
	e2:SetCountLimit(1)
	e2:SetCondition(cod.descon)
	e2:SetTarget(cod.destg)
	e2:SetOperation(cod.desop)
	c:RegisterEffect(e2)
end

--search
function cod.thcon(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetHandler()
	return sc:GetSummonType()&SUMMON_TYPE_SYNCHRO~=0 and sc:IsStatus(STATUS_SPSUMMON_TURN)
end
function cod.thfilter(c)
	return c:IsSetCard(0xd3d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cod.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--destroy
function cod.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0xd3d)
end
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=g:Select(tp,1,1,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end