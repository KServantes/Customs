--Kansallor, Ancient Pendulum Soldier
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function cod.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--[[ Pendulum Effects ]]
	--ritual summon
	local filter,lvtype,lv,extrafil,matfilter,location,forcedselection=
	aux.FilterBoolFunction(Card.IsCode,id),RITPROC_GREATER,10,cod.exgroup,cod.mfilter,LOCATION_PZONE,nil
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	-- e1:SetLabel(CARD_AZEGAHL)
	e1:SetTarget(Qued.RitualTargetK(filter,lvtype,lv,extrafil,matfilter,location,forcedselection))
	e1:SetOperation(Qued.RitualOperationK(filter,lvtype,lv,extrafil,matfilter,location,forcedselection))
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DRAW)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetLabel(CARD_AZEGAHL)
	e2:SetCost(cod.drcost)
	e2:SetTarget(cod.drtg)
	e2:SetOperation(cod.drop)
	c:RegisterEffect(e2)
	--[[ Monster Effects ]]
	--cannot special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(cod.splimit)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function (e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetHandler():IsFaceup() end)
	e4:SetTarget(cod.destg)
	e4:SetOperation(cod.desop)
	c:RegisterEffect(e4)
	--negate chains
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(cod.chainop)
	c:RegisterEffect(e5)
	--negate effect or summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(cod.negcon)
	e6:SetCost(cod.negcost)
	e6:SetTarget(cod.negtg)
	e6:SetOperation(cod.negop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_REMOVE)
	e7:SetLabel(1)
	e7:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e7)
end
cod.listed_series={0xf2}

--splimit
function cod.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM)
		or (c:IsLocation(LOCATION_PZONE) and (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL)
end

--==Penulum Effects==--
--Ritual Param Funcs
function cod.emfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function cod.exgroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(cod.emfilter,tp,LOCATION_EXTRA,0,nil)
end
function cod.mfilter(c)
	return (c:IsLocation(LOCATION_HAND) and c:IsSetCard(0xf2)) or (c:IsLocation(LOCATION_EXTRA) and c:IsRace(RACE_ZOMBIE))
end

--Draw
function cod.pfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsMonster()
end
function cod.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.pfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cod.pfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--==Monster Effects==--
--Destroy
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,LOCATION_MZONE)
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if c:IsStatus(STATUS_DISABLED) then return end
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	local ph=Duel.GetCurrentPhase()
	local p=Duel.GetTurnPlayer()
	if ph==PHASE_MAIN1 then
		Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_EP)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN)
		Duel.RegisterEffect(e2,tp)
	else
		Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(p,PHASE_END,RESET_PHASE+PHASE_END,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_TURN)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		Duel.RegisterEffect(e1,tp)
		Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE+PHASE_END,2)
		Duel.SkipPhase(p,PHASE_STANDBY,RESET_PHASE+PHASE_END,2)
		Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE+PHASE_END,2)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_EP)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN)
		Duel.RegisterEffect(e2,tp)
	end
end

--Negate Chains
function cod.chainop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain(true)>1 then
		Duel.NegateEffect(ev)
	end
end

--Negate Effect or Summon
function cod.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsStatus(STATUS_PROC_COMPLETE) then return false end
	if e:GetLabel()==1 then
		return Duel.GetCurrentChain(true)==0 and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
	end
	return re and re:GetHandler():IsLocation(LOCATION_HAND|LOCATION_GRAVE) and Duel.IsChainNegatable(ev)
end
function cod.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function cod.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	--if summon
	if e:GetLabel()==1 then
		local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
		end
	end
end
function cod.negop(e,tp,eg,ep,ev,re,r,rp)
	--if summon
	if e:GetLabel()==1 then
		local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
		Duel.NegateSummon(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	else
		Duel.NegateActivation(ev)
		if not re:GetHandler():IsRelateToEffect(re) then return end
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end