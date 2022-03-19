--Blood Metamorphosis 
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(cod.target1)
	c:RegisterEffect(e1)
	--instant
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(cod.cost)
	e2:SetTarget(cod.target2)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,cod.chainfilter)
end
--
function cod.chainfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xd3d))
end

--activate
function cod.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=cod.damtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=cod.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=cod.tdtg(e,tp,eg,ep,ev,re,r,rp,0)
	if Duel.GetFlagEffect(tp,id)==0 and (b1 or b2 or b3) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local op=aux.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)},
			{b3,aux.Stringid(id,4)})
		if op==1 then
			e:SetCategory(CATEGORY_RECOVER)
			e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e:SetOperation(cod.damop)
			cod.damtg(e,tp,eg,ep,ev,re,r,rp,1)
		elseif op==2 then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
			e:SetProperty(0)
			e:SetOperation(cod.thop)
			cod.thtg(e,tp,eg,ep,ev,re,r,rp,1)
		elseif op==3 then
			e:SetCategory(CATEGORY_TODECK)
			e:SetProperty(0)
			e:SetOperation(cod.tdop)
			cod.tdtg(e,tp,eg,ep,ev,re,r,rp,1)
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

function cod.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function cod.target2(e,tp,eg,ep,ev,re,r,rp)
	local b1=cod.damtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=cod.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=cod.tdtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local op=aux.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	if op==1 then
		e:SetCategory(CATEGORY_RECOVER)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(cod.damop)
		cod.damtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetOperation(cod.thop)
		cod.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(0)
		e:SetOperation(cod.tdop)
		cod.tdtg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

--damage
function cod.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam,deg,dep,dev,dre,dr,drp=Duel.CheckEvent(EVENT_DAMAGE,true)
	if chk==0 then return dam and dev>0 and dep==1-tp end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
function cod.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end

--add to hand
function cod.thfilter(c)
	return c:IsSetCard(0xd3d) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function cod.cfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsSummonPlayer(tp) and c:IsSetCard(0xd3d)
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sum,seg,sep,sev,sre,sr,srp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if chk==0 then return sum and seg:FilterCount(cod.cfilter,nil,tp)~=0 
		and Duel.IsExistingMatchingCard(cod.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,cod.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end

--shuffle to deck
function cod.tdfilter(c)
	return c:IsSetCard(0xd3d) and c:IsType(TYPE_MONSTER)
end
function cod.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sct=Duel.GetMatchingGroupCount(cod.tdfilter,tp,LOCATION_GRAVE,0,nil)
	local sact=Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)
	if chk==0 then return sct>=sact and sct~=0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function cod.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cod.tdfilter),tp,LOCATION_GRAVE,0,1,ct,nil)
	if #dg>0 then
		Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)
	end
end