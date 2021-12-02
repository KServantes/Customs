--Pendulum Bone Mouse
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function c1013047.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Recover Materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
		--for copy effect
	e1:SetLabel(1013058)
	e1:SetCost(cod.spcost)
	e1:SetTarget(cod.sptg)
	e1:SetOperation(cod.spop)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetRange(LOCATION_PZONE)
		--for copy effect
	e2:SetLabel(1013058)
	e2:SetCost(cod.drcost)
	e2:SetTarget(cod.drtg)
	e2:SetOperation(cod.drop)
	c:RegisterEffect(e2)
end

--Special Summon
function cod.cfilter(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_NORMAL+TYPE_PENDULUM)
end
function cod.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cod.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel())
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function cod.spfilter(c,e,tp)
	local types=TYPE_FUSION+TYPE_PENDULUM+TYPE_NORMAL
	return c:GetType()&(types)==types and Duel.GetLocationCountFromEx(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #sg<=0 then return end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	local tc=sg:GetFirst()
	local fid=c:GetFieldID()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCondition(Qued.descon(tc,id,fid))
	e1:SetOperation(Qued.desop(tc))
	Duel.RegisterEffect(e1,tp)
end

--Draw
function cod.helper(tp)
	local draw = 0
	for i=1, 3 do
		if Duel.IsPlayerCanDraw(tp, i) then
			draw = i
		end
	end
	return draw
end
function cod.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_EXTRA,0,2,nil) end
	local ct = cod.helper(tp)
	local max = ct*2
	if max<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_EXTRA,0,2,max,nil)
	local sc=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	e:SetLabel(sc)
end
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel() and Duel.IsPlayerCanDraw(tp, e:GetLabel()/2) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(e:GetLabel()/2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end