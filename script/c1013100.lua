--Ciber Skull Servant
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Invocación Enlace
	c:EnableReviveLimit()
	Link.AddProcedure(c,cod.matfilter,2,2)
	--Invocación Enlace 2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cod.lkcon)
	e1:SetTarget(cod.lktg)
	e1:SetOperation(cod.lkop)
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)
	--sirviente de la calavera en el cementerio
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(CARD_SKULL_SERVANT)
	c:RegisterEffect(e2)
	--Invoca del Cementerio y Mano
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,4))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
 	e3:SetCountLimit(1,{id,1})
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(aux.zptcon(Card.IsFaceup))
    e3:SetTarget(cod.spgtg)
    e3:SetOperation(cod.spgop)
    c:RegisterEffect(e3)
	--Evitar destrucción
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(cod.reptg)
	e4:SetValue(cod.repval)
	e4:SetOperation(cod.repop)
	c:RegisterEffect(e4)
end
function cod.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_ZOMBIE,lc,sumtype,tp)
end

--Filtro para Materiales Enlace
function cod.lfitler(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_ZOMBIE)
end
--Segundo filtro para Materiales Enlace
function cod.lgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeckAsCost()
end

--Invocación Enlace Secundario
function cod.lkcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(cod.lgfilter,tp,LOCATION_GRAVE,0,2,nil) 
end
function cod.lktg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(cod.lgfilter,tp,LOCATION_GRAVE,0,nil)
	if #g<2 or Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
	local sg=g:Select(tp,2,2,nil)
	if #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function cod.lkop(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	if Duel.SendtoDeck(g,nil,2,REASON_MATERIAL+REASON_LINK)>0 then
		g:DeleteGroup()
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		local lt={LINK_MARKER_BOTTOM,LINK_MARKER_RIGHT}
		local lm=lt[op+1]
		--Reducir Enlace 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetLabelObject({c,lm})
		e1:SetOperation(cod.lkaop)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		Duel.RegisterEffect(e1,tp)
	end
end

function cod.lkaop(e,tp,eg,ep,ev,re,r,rp)
	local lt=e:GetLabelObject()
	if not lt then return end
	local lc,marker=lt[1],lt[2]
	lc:UpdateLink(-1)
	lc:LinkMarker(marker)
end

--Invoca del Cementerio y Mano
function cod.spfilter1(c,e,tp)
	return c:IsLevel(1) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end		
function cod.spgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_DECK) and chkc:IsControler(tp) and cod.spfilter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.spfilter1,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_DECK)
end
function cod.spgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.spfilter1,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g<=0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

--evitar destrucción
function cod.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) 
		and c:IsCode(36021814) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end
function cod.rfilter(c)
	return c:IsAbleToHand() and c:IsCode(CARD_SKULL_SERVANT)
end
function cod.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(cod.filter,1,nil,tp)
		and Duel.GetFlagEffect(tp,id)==0
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) 
		and Duel.IsExistingMatchingCard(cod.rfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return Duel.SelectYesNo(tp,aux.Stringid(id,5))
end
function cod.repval(e,c)
	return cod.filter(c,e:GetHandlerPlayer())
end
function cod.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.rfilter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,nil)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT+REASON_REPLACE)
end