--Pendulum Bone Mouse
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function c1013047.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Sub
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(cod.subcon)
	e1:SetValue(function (e,c) return c:IsRace(RACE_ZOMBIE) end)
	c:RegisterEffect(e1)
	--Search 1 Level 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	--for copy effect
	e2:SetLabel(CARD_AZEGAHL)
	e2:SetCondition(cod.scon)
	e2:SetTarget(cod.stg)
	e2:SetOperation(cod.sop)
	c:RegisterEffect(e2)
end

--Fusion
function cod.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_PZONE) or e:GetHandler():HasFlagEffect(CARD_AZEGAHL,1)
end

--Search
function cod.ffilter(c,tp)
	return c:GetType()&(TYPE_NORMAL|TYPE_FUSION)~=0 and c:IsRace(RACE_ZOMBIE)
		and c:IsSetCard(0xf2) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function cod.scon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cod.ffilter,1,nil,tp)
end
function cod.sfilter(c)
	return c:GetLevel()==1 and c:IsSetCard(0xf2) and c:IsAbleToHand()
end
function cod.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		and Duel.IsExistingMatchingCard(cod.sfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function cod.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cod.sfilter,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil)
	if #g<=0 then return end
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end