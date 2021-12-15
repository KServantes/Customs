--Reitslicer, Pendulum Pirate
local cod,id=GetID()
function cod.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,cod.xyzfilter,4,2)
	c:EnableReviveLimit()
	--Pendulum Summon
	Pendulum.AddProcedure(c)

	--[ Pendulum Effects ]
	--xyz 
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_ADJUST)
    e1:SetRange(LOCATION_PZONE)
    e1:SetLabel(1013058)
    e1:SetCondition(cod.adjustcon)
    e1:SetOperation(cod.adjustop)
    c:RegisterEffect(e1)

	--[ Monster Effects ]
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(cod.valcheck)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(cod.spcost)
	e3:SetTarget(cod.sptg)
	e3:SetOperation(cod.spop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	--attach
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(cod.xyzcon)
	e4:SetTarget(cod.xyztg)
	e4:SetOperation(cod.xyzop)
	c:RegisterEffect(e4)
end

--pendulum level
cod.pendulum_level=4
--xyz filter
function cod.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,xyz,sumtype,tp) and c:IsRace(RACE_ZOMBIE,xyz,sumtype,tp)
end

--send back to extra
function cod.confilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_ZOMBIE)
end
function cod.adjustcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(cod.confilter,nil)==#g
end
function cod.mfilter(c)
    return c:IsFaceup() and not c:IsRace(RACE_ZOMBIE) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function cod.adjustop(e,tp,eg,ep,ev,re,r,rp)
    local phase=Duel.GetCurrentPhase()
    if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
    local sg=Group.CreateGroup()
    for p=0,1 do
        local g=Duel.GetMatchingGroup(cod.mfilter,p,LOCATION_MZONE,0,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local dg=g:Select(p,#g,#g,nil)
            sg:Merge(dg)
        end
    end
    if sg:GetCount()>0 then
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_RULE)
        Duel.Readjust()
    end
end

--atk add
function cod.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	for tc in aux.Next(g) do
		local catk=tc:GetTextAttack()
		atk=atk+(catk>=0 and catk or 0)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end

--special summon
function cod.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function cod.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or not c:IsLocation(LOCATION_EXTRA))
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,loc,0,1,1,nil,e,tp)
	if #g<=0 then return end
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--attach
function cod.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function cod.xyzfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER)
end
function cod.xyzfilter2(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end
function cod.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cod.xyzfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(cod.xyzfilter2,tp,0,LOCATION_MZONE,1,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectTarget(tp,cod.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g2=Duel.SelectTarget(tp,cod.xyzfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g=g+g2
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetTargetCard(g)
end
function cod.mtfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
function cod.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(cod.mtfilter,nil,e)
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if #g<=0 then return end
	Duel.Overlay(c,g)
end
