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
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	--for copy effect
	e1:SetLabel(CARD_AZEGAHL)
	e1:SetTarget(cod.sptg)
	e1:SetOperation(cod.spop)
	c:RegisterEffect(e1)
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	--for copy effect
	e2:SetLabel(CARD_AZEGAHL)
	e2:SetTarget(cod.pltg)
	e2:SetOperation(cod.plop)
	c:RegisterEffect(e2)

	--[ Monster Effects ]
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(3100)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cod.imcon)
	e3:SetValue(cod.efilter)
	c:RegisterEffect(e3)
	--Gain Effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cod.fuscon)
	e4:SetOperation(cod.apop)
	c:RegisterEffect(e4)
	--Place
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCondition(cod.pencon)
	e5:SetTarget(cod.pentg)
	e5:SetOperation(cod.penop)
	c:RegisterEffect(e5)
end

--fusion filter
function cod.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,fc,sumtype,tp) and not c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end

--[ pendulum effects ]
--special summon
function cod.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_PZONE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_PZONE,0,1,1,e:GetHandler(),e,tp)
	if #g<=0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

--place in pzone (p-effect)
function cod.plfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsType(TYPE_EFFECT)
end
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cod.plfilter(chkc) end
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(cod.plfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
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
--immune
function cod.imcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFusionSummoned() and c:IsStatus(STATUS_SPSUMMON_TURN)
end
function cod.efilter(e,te)
	if te:GetHandler():GetCode()==id then return false end
	return te:GetOwner()~=e:GetOwner()
end

--apply peffects
function cod.confilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf2) and not c:IsType(TYPE_EFFECT)
end
function cod.fuscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mats=c:GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and #mats>0 and mats:IsExists(cod.confilter,1,nil)
end
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
					c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(tc:GetCode(),10))
				end
			end
		end
	end
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
