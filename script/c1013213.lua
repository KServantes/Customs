--Blood Omen - Sophia
local cod,id=GetID()
cod.atts={["ctpe"]=0x1021}
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--attributes
	Qued.AddAttributes(c,false)
	--spell counter
	Qued.AddSpellCounter(c,id)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(Qued.BloodTarget(id,c:GetMetatable()))
	e1:SetOperation(Qued.BloodOperation(id,c.__index))
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cod.handcon)
	c:RegisterEffect(e2)
	--synchro summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(cod.sctg)
	e3:SetOperation(cod.scop)
	c:RegisterEffect(e3)
end

function cod.actcon(e,tp,eg,ep,ev,re,r,rp)
	return  
end

function cod.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
end

--syncrho summon
function cod.scfilter(c,tc)
	return c:IsSetCard(SET_BLOOD_OMEN) and c:IsSynchroSummonable(tc)
end
function cod.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.scfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cod.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.scfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),e:GetHandler())
	end
end