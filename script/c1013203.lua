--Blood Omen - Beatrice
local cod,id=GetID()
cod.atts={["ctpe"]=0x1021}
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--attributes
	Qued.AddAttributes(c,false)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetTarget(cod.acttg)
	e1:SetOperation(cod.actop)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cod.handcon)
	c:RegisterEffect(e2)
	--Synchro Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(cod.sctg)
	e3:SetOperation(cod.scop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(cod,function()
		cod.val={}
		cod.val[0]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RECOVER)
		ge1:SetOperation(cod.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_PHASE+PHASE_END)
		ge2:SetCountLimit(1)
		ge2:SetOperation(cod.resetop)
		Duel.RegisterEffect(ge2,0)
	end)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,cod.chainfilter)
end
function cod.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rec=cod.val[0]
	local c=e:GetHandler()
	if ep==tp then
		rec=rec+ev
		if rec>=1300 then
			Duel.RaiseEvent(Group.FromCards(c),EVENT_CUSTOM+id,re,r,rp,ep,ev)
		end
		cod.val[0]=rec
	end
end
function cod.resetop(e,tp,eg,ep,ev,re,r,rp)
	cod.val[0]=0
end
--
function cod.chainfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xd3d))
end
function cod.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>1
end

--Special Summon
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

--syncrho summon
function cod.scfilter(c,tc)
	return c:IsSetCard(0xd3d) and c:IsSynchroSummonable(tc)
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