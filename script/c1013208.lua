--Blood Omen - Philo
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function cod.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cod.actcost)
	e1:SetTarget(cod.acttg)
	e1:SetOperation(cod.actop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(cod.spcost)
	e2:SetCondition(cod.spcon)
	e2:SetTarget(cod.sptg)
	e2:SetOperation(cod.spop)
	c:RegisterEffect(e2)
end
cod.listed_series={SET_FUSION}

--effect 1 activate and banish
function cod.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cod.actfilter(c,e,tp)
	if not c:IsType(TYPE_BLOOD_SPELL) then return end
	return c:IsSetCard(SET_BLOOD_OMEN) and c:GetActivateEffect():IsActivatable(tp,true,false)
end
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(cod.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(cod.actfilter,tp,LOCATION_DECK,0,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    --activate
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_CHAIN_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(sc)
    e1:SetOperation(cod.faop)
    Duel.RegisterEffect(e1,tp)
    --banish
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCountLimit(1)
	e2:SetLabelObject(sc)
	e2:SetCondition(cod.bcon)
	e2:SetOperation(cod.bop)
	Duel.RegisterEffect(e2,tp)
end
--activate blood spell
function cod.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep) then
        Duel.Activate(te)
    end
    e:Reset()
end
--banish opponent's spell
function cod.bcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	local rc=re:GetHandler()
	return ep==tp and rc==tc
end
function cod.bop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_SZONE,nil)
	if #g<=0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,1,nil)
	if #sg<=0 then return end
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	e:Reset()
end


--effect 2 special summon
function cod.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
function cod.filterm(c,tp)
	return c:IsSetCard(0xd3d) and c:GetReasonPlayer()~=tp and c:IsType(TYPE_SPELL|TYPE_TRAP)
end
function cod.spcon(e,tp,eg,ep,ev,re,r,p)
	return #eg>0 and eg:IsExists(cod.filterm,1,nil,tp)
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_GRAVE,1,nil,e,0,tp,false,false,POS_FACEUP,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,0)<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_GRAVE,nil,e,0,tp,false,false,POS_FACEUP,tp)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	local pg=Duel.GetMatchingGroup(aux.AND(aux.FilterBoolFunction(Card.IsSetCard,SET_FUSION),Card.IsAbleToHand),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and #pg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=pg:Select(tp,1,1,nil)
		if #hg<=0 then return end
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,hg)
	end
end