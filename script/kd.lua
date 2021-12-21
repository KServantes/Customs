--An uneccesary file I made because I could
if not aux.ExtrasDeKedy then
	aux.ExtrasDeKedy = {}
	Qued = aux.ExtraDeKedy
end

if not Qued then
	Qued = aux.ExtrasDeKedy
end

--Common used cards
CARD_AZEGAHL = 1013058

--Common on placed in pzone summon effect
function Qued.AddRPepeEffect(c,id)
	local card = Card.GetMetatable(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+1013048)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(Qued.SpecialTarget(c))
	e1:SetOperation(Qued.SpecialOperation(c,id))
	c:RegisterEffect(e1)
	Qued.PendPlaceCheck(card,c)
end

--"When this card is placed in your Pendulum Zone"
function Qued.PendPlaceCheck(card,c)
	if not card.global_check then
		card.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(Qued.checkop(c,1013048))
		Duel.RegisterEffect(ge1,0)
	end
end

function Qued.chkfilter(c,id)
	local seq=c:GetSequence()
	local prev=(not c:IsPreviousLocation(LOCATION_PZONE) or c:GetPreviousSequence()~=seq)
	return c:GetFlagEffect(id+seq+1)==0 and prev
end
function Qued.checkop(c,id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tot=Duel.IsDuelType(DUEL_SEPARATE_PZONE) and 13 or 4
		local g=Duel.GetMatchingGroup(Qued.chkfilter,tp,LOCATION_PZONE,0,nil,id)
		if #g>0 then
			for tc in aux.Next(g) do
				tc:ResetFlagEffect(id+tot-(tc:GetSequence()+1))
				Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,tp,tp,0)
				tc:RegisterFlagEffect(id+tc:GetSequence()+1,RESET_EVENT+RESETS_STANDARD,0,1)
			end
		end
	end
end

--Min and Max levels between scales
function Qued.GetLvBetween(c)
	local min, max
	local lscale, rscale = c:GetLeftScale(), c:GetRightScale()
	if lscale == rscale then return 0, 0 end
	if lscale > rscale then
		max = lscale -1
		min = rscale +1
	else
		min = lscale +1
		max = rscale -1
	end
	return min, max
end

function Qued.SpecialFilter(c,e,tp,min,max)
	if min == max then return false end
	local lv = c:GetLevel()
	return lv>=min and lv<=max and c:IsType(TYPE_FUSION) 
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Qued.SpecialTarget(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local min, max = Qued.GetLvBetween(c)
		if chk==0 then return Duel.IsExistingMatchingCard(Qued.SpecialFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,min,max) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function Qued.SpecialOperation(c,id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local min, max = Qued.GetLvBetween(c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp, Qued.SpecialFilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, min, max)
		if #g<=0 or Duel.GetLocationCountFromEx(tp)==0 then return end
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
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
	end
end
function Qued.descon(tc,id,fid)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if tc:GetFlagEffectLabel(id)~=fid then
			e:Reset()
			return false
		else return true end
	end
end
function Qued.desop(tc)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--operation for azegahl
function Qued.applyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	for tc in aux.Next(g) do
		if tc:IsRace(RACE_ZOMBIE) and tc:IsSetCard(0xf2) then 
			if tc:GetFlagEffect(CARD_AZEGAHL)>0 then return end
			local effs={tc:GetCardEffect()}
			for _,eff in ipairs(effs) do
				if eff:GetLabel()==CARD_AZEGAHL then
					--apply cloned effect in mzone
					local ex=eff:Clone()
					ex:SetLabel(CARD_AZEGAHL*2)
					ex:SetRange(LOCATION_MZONE)
					ex:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(ex)
					tc:RegisterFlagEffect(CARD_AZEGAHL,RESET_EVENT+RESETS_STANDARD,0,1)
					tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(CARD_AZEGAHL,1))
				end
			end
		end
	end
	if c:GetFlagEffect(CARD_AZEGAHL)==0 then
		local le=Effect.CreateEffect(c)
		le:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		le:SetCode(EVENT_LEAVE_FIELD)
		le:SetOperation(Qued.resetop)
		le:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE)
		c:RegisterEffect(le,true)
		c:RegisterFlagEffect(CARD_AZEGAHL,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end


function Qued.resfilter(c)
	return c:GetFlagEffect(CARD_AZEGAHL)>0
end
function Qued.resetop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Qued.resfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if #g<=0 then return end
	for tc in aux.Next(g) do
		local effs={tc:GetCardEffect()}
		for _,eff in ipairs(effs) do
			--reset each apply effect
			if eff:GetLabel()==(CARD_AZEGAHL*2) then
				eff:Reset()
			end
		end
		--reset flag of card
		tc:ResetFlagEffect(CARD_AZEGAHL)
		--reset hint msg
		tc:ResetFlagEffect(0)
	end
end