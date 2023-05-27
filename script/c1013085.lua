--Fragments of Nightmare
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function (e) return Duel.IsMainPhase() end)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
end
local function drchk(tp)
	local t={}
	for n=1,3 do
		if Duel.IsPlayerCanDraw(tp,n) then
			table.insert(t,n)
		end
	end
	return t
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dt=drchk(tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,30459350) and dt and #dt>0 end
	local no=Duel.AnnounceNumber(tp,table.unpack(dt))
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(no)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,no)
end
function cod.hfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_NORMAL|TYPE_PENDULUM)
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	Duel.ShuffleHand(p)
	Duel.BreakEffect()
	local hct=Duel.GetMatchingGroupCount(cod.hfilter,tp,LOCATION_HAND,0,nil)
	local sct=0
	if hct>=ct then
		--if has max cards
		sct=ct
	elseif hct<=ct and hct>0 then
		--if has some card(s)
		sct=hct
	end
	if sct==0 then
		--if has no card(s)
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)==0 then
			Duel.ConfirmCards(1-p,sg)
			Duel.ShuffleHand(p)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,cod.hfilter,tp,LOCATION_HAND,0,sct,sct,nil)
		if #g<=0 then return end
		local exct=Duel.SendtoExtraP(g,nil,REASON_EFFECT)
		local zct=Duel.GetMatchingGroupCount(cod.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		if zct<exct then exct=zct end
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) and exct>0 and Duel.IsPlayerCanSendtoHand(p) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local thg=Duel.SelectMatchingCard(p,cod.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,exct,nil)
			if #thg>0 then
				Duel.SendtoHand(thg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-p,thg)
				Duel.ShuffleHand(p)
			end
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cod.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cod.thfilter(c)
	return c:IsLevelBelow(5) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function cod.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end