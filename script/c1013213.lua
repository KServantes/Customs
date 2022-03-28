--Blood Omen - Sophia
local cod,id=GetID()
cod.atts={["ctpe"]=0x1021}
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--attributes
	Qued.AddAttributes(c,false)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(cod.acttg)
	e1:SetOperation(cod.actop)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cod.handcon)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(cod.acttg)
	e3:SetOperation(cod.actop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,cod.chainfilter)
end
--
function cod.chainfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xd3d))
end
function cod.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
end

--special summon
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xd3d,0x1021,1300,0,3,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_BLOOD_OMEN,0,0)
	cod.flag[0]=1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xd3d,0x1021,1300,0,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TUNER)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		c:AddMonsterAttributeComplete()
	end
	Duel.SpecialSummonComplete()
end

--activate spell card
function cod.actfilter(c)
	return c:IsSetCard(0xd3d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetActivateEffect():IsActivatable(tp,true,false)
end
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(cod.actfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) 
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
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
	Duel.RaiseEvent(Group.FromCards(sc),EVENT_CHAINING,se,r,rp,ep,ev)
	sc:CancelToGrave(false)
	Duel.BreakEffect()
	sc:SetStatus(STATUS_ACTIVATED,true)
	if op and not sc:IsDisabled() then op(se,tp,eg,ep,ev,re,r,rp,1) end
	sc:ReleaseEffectRelation(se)
end