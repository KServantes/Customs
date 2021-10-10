--Flame Pendulum Ghost
local cod, id = GetID()
function c1013048.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_FIRE))
	--Pendulum Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(cod.sptg)
	e1:SetOperation(cod.spop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(cod,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(cod.checkop)
		Duel.RegisterEffect(ge2,0)
	end)
end

function cod.cfilter(c)
	local seq=c:GetSequence()
	return c:GetFlagEffect(id+seq)==0 and (not c:IsPreviousLocation(LOCATION_PZONE) or c:GetPreviousSequence()~=seq)
end
function cod.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tot=Duel.IsDuelType(DUEL_SEPARATE_PZONE) and 13 or 4
	local g=Duel.GetMatchingGroup(cod.cfilter,tp,LOCATION_PZONE,0,nil)
	if #g>0 then
		for tc in aux.Next(g) do
			tc:ResetFlagEffect(id+tot-tc:GetSequence())
			Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,tp,tp,0)
			tc:RegisterFlagEffect(id+tc:GetSequence(),RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end

function cod.spfilter(c,e,tp,min,max)
	if min == max then return false end
	local lv = c:GetLevel()
	return lv>=min and lv<=max and c:IsType(TYPE_FUSION) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.helper(c)
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
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local min, max = cod.helper(e:GetHandler())
	if chk==0 then return Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,min,max) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local min, max = cod.helper(e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp, cod.spfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, min, max)
	if #g<=0 or Duel.GetLocationCountFromEx(tp)==0 then return end
	local tc=g:GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(cod.descon)
		e1:SetOperation(cod.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function cod.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
