--Blood Omen - Beatrice
local cod,id=GetID()
cod.atts={["ctpe"]=0x1021}
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--attributes
	Qued.AddAttributes(c,false)
	--custom activity
	Qued.AddSpellCounter(c,id)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function (_,_,_,_,_,re) return re end)
	e1:SetTarget(Qued.BloodTarget(id,cod.__index))
	e1:SetOperation(Qued.BloodOperation(id,cod.__index))
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cod.handcon)
	c:RegisterEffect(e2)
	--Capture
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(cod.capcon)
	e3:SetTarget(cod.captg)
	e3:SetOperation(cod.capop)
	c:RegisterEffect(e3)
end

--act from hand
function cod.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
end

--take
function cod.capcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_SYNCHRO~=0)
		and e:GetHandler():GetReasonCard():IsSetCard(SET_BLOOD_OMEN)
end
function cod.captg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,1-tp,LOCATION_MZONE)
end
function cod.capop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if Duel.CheckLPCost(1-tp,1000) and Duel.SelectYesNo(1-tp,aux.Stringid(80764541,1)) then
		Duel.PayLPCost(1-tp,1000)
		Duel.Destroy(tc,REASON_EFFECT)
	else
		Duel.GetControl(tc,tp)
	end
end