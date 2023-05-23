--Fragments of Nightmare
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_SEARCH)
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
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_NORMAL)
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	Duel.ShuffleHand(p)
	Duel.BreakEffect()
	local zct=Duel.GetMatchingGroupCount(cod.hfilter,tp,LOCATION_HAND,0,nil)
	local g
	--if has max cards
	if zct>=ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=Duel.SelectMatchingCard(tp,cod.hfilter,tp,LOCATION_HAND,0,ct,ct,nil)
	--if has some card(s)
	elseif zct<=ct and zct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=Duel.SelectMatchingCard(tp,cod.hfilter,tp,LOCATION_HAND,0,zct,zct,nil)
	--if has no cards
	else
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==0 then
			Duel.ConfirmCards(1-p,sg)
			Duel.ShuffleHand(p)
		end
	end
	if not g or #g<=0 then return end
	if g and #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
		local desg=Duel.GetOperatedGroup():Filter(cod.gfilter,nil)
		if #desg<=0 then return end
		local sg=desg:Clone()
		-- local zdg=sg:Filter()
		local zdg=Duel.GetMatchingGroup(cod.thfilter,tp,LOCATION_DECK,0,nil)
		for tc in sg:Iter() do
			if Duel.SelectYesNo(tp,ux.Stringid(id,1)) and #zdg and Duel.IsPlayerCanSendtoHand(p) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local thg=aux.SelectUnselectGroup(zdg,e,tp,1,1,aux.dncheck,1,tp,HINTMSG_ATOHAND)
				if #thg>0 then
					Duel.SendtoHand(thg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-p,thg)
					Duel.ShuffleHand(p)
				end
			end
		end
	end
end
function cod.gfilter(c)
	return not c:IsLocation(LOCATION_GRAVE)
end
function cod.thfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- function cod.nfilter(c,code,lv)
-- 	return c:GetCode()~=code and c:GetLevel()<=lv
-- end