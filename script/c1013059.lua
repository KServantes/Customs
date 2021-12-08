--Viradik, Necro Pendulumage
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013059.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,cod.ffilter,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	---[ Pendulum Effects ]
	--Place
	Qued.AddRPepeEffect(c,id)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	--for copy effect
	e1:SetLabel(1013058)
	e1:SetTarget(cod.sptg)
	e1:SetOperation(cod.sptop)
	c:RegisterEffect(e1)
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetLabel(1013058)
	e2:SetTarget(cod.pltg)
	e2:SetOperation(cod.plop)
	c:RegisterEffect(e2)
	--[ Monster Effects ]
	--Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cod.thcon)
	e3:SetTarget(cod.thtg)
	e3:SetOperation(cod.thop)
	c:RegisterEffect(e3)
	--Gain Effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cod.thcon)
	e4:SetOperation(cod.apop)
	c:RegisterEffect(e4)
	--Cannot Activate
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(1,1)
	e5:SetValue(cod.actlimit)
	c:RegisterEffect(e5)
	--Place
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCondition(cod.pencon)
	e6:SetTarget(cod.pentg)
	e6:SetOperation(cod.penop)
	c:RegisterEffect(e6)
end

--fusion filter
function cod.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,fc,sumtype,tp) and not c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end

--[ pendulum effects ]
--special summon
function cod.spfitler(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_PZONE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_PZONE,0,1,1,e:GetHandler(),e,tp)
	if #g<=0 then return end
	Duel.SpecialSummon(e,0,tp,tp,false,false,POS_FACEUP)
end

--place in pzone (p-effect)
function cod.plfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsType(TYPE_EFFECT)
end
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cod.plfilter(chkc) end
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(cod.plfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cod.plop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectMatchingCard(tp,cod.plfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g<=0 then return end
	local tc=g:GetFirst()
	if tc:IsFaceup() then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--[ monster effects ]
--search
function cod.confilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x2f) and not c:IsType(TYPE_EFFECT)
end
function cod.thcon(e,tp,eg,ep,ev,re,r,rp)
	local mats=c:GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and mats and mats:IsExists(cod.confilter,1,nil)
end
function cod.cfilter(c)
	return c:IsSetCard(0x2f) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cod.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--apply peffects
function cod.apop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g<=0 then return end
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_PENDULUM) and tc:IsSetCard(0xf2) and not tc:IsType(TYPE_EFFECT) then
			if c:GetFlagEffect(id+tc:GetCode())>0 then return end
			local effs={tc:GetCardEffect()}
			for _,eff in ipairs(effs) do
				if eff:GetLabel()==CARD_AZEGAHL then
					local ex=eff:Clone()
					ex:SetRange(LOCATION_MZONE)
					ex:SetReset(RESET_EVENT+RESETS_STANDARD)
					c:RegisterEffect(ex)
					c:RegisterFlagEffect(id+tc:GetCode(),RESET_EVENT+RESETS_STANDARD,0,1)
				end
			end
		end
	end
end

--cannot activate
function cod.aclimit(e,re,tp)
	local con1=(re:IsHasCategory(CATEGORY_DISABLE+CATEGORY_DESTROY) or re:IsHasCategory(CATEGORY_NEGATE+CATEGORY_DESTROY))
	local con2=(re:IsHasCategory(CATEGORY_DISABLE) or re:IsHasCategory(CATEGORY_NEGATE))
	return (re:IsActiveType(TYPE_MONSTER) or re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP)) 
		and (con1 or con2)
end

--place in pzone (m-effect)
function cod.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function cod.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function cod.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
