--Shadow Pendulum Specter
local cod,id = GetID()
function cod.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c,false)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)

	---[Pendulum Effects]
	--Become Linked
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
		--for copy effect
	e1:SetLabel(1013058)
	e1:SetTarget(cod.lktg)
	e1:SetOperation(cod.lkop)
	c:RegisterEffect(e1)

	---[Monster Effects]
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(cod.plcost)
	e2:SetTarget(cod.pltg)
	e2:SetOperation(cod.plop)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(cod.sptg2)
	e3:SetOperation(cod.spop2)
	c:RegisterEffect(e3)
end

--Activate
function cod.cfilter(c)
	return c:GetLevel()==1 and c:IsAbleToHand()
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(cod.cfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--Become Linked
function cod.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() end
end
function cod.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq,loc=c:GetSequence(),c:GetLocation()
	if not c:IsRelateToEffect(e) 
		or Duel.Destroy(e:GetHandler(),REASON_EFFECT)==0 then return end
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
    e1:SetLabel(seq,loc)
    e1:SetValue(cod.val)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end

function cod.val(e)
	local seq,loc=e:GetLabel()
	local t={0x2,0x1+0x4,0x2+0x8,0x4+0x10,0x8}
	if loc~=LOCATION_MZONE then
		if seq==0 then
			return 0x1+0x2<<16*e:GetHandlerPlayer()
		else
			return 0x8+0x10<<16*e:GetHandlerPlayer()
		end
	else
		if seq<5 then
			return t[seq]<<16*e:GetHandlerPlayer()
		end
	end
end

--Place in Pzone
function cod.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cod.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsLocation(LOCATION_PZONE)
end
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(cod.filter,tp,LOCATION_EXTRA+LOCATION_ONFIELD,0,1,e:GetHandler()) end
end
function cod.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp, cod.filter, tp, LOCATION_EXTRA+LOCATION_ONFIELD, 0, 1, 1, e:GetHandler())
	if #g<0 or not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end
	Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

--Special Summon from Pzone
function cod.pfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and cod.pfilter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsAbleToDeck() 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.pfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function cod.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.pfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g<=0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end