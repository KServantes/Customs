--Blood Omen - Jula
local cod,id=GetID()
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--attributes
	Qued.AddAttributes(c,true)
	--Activate
	Qued.BloodOmenSpellActivate(c,id)
	--Eqiup
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(cod.eqcon)
	e1:SetTarget(cod.eqtg)
	e1:SetOperation(cod.eqop)
	c:RegisterEffect(e1)
	--Gain Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(cod.gecon)
	e2:SetOperation(cod.geop)
	c:RegisterEffect(e2)
end

function cod.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local card=c:GetMetatable()
	return card.flag==1
end
function cod.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BLOOD_OMEN) and c:IsType(TYPE_SYNCHRO)
end
function cod.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cod.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cod.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,cod.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function cod.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		--equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(cod.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		--unaffected
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetLabelObject({c,tc})
		e3:SetValue(cod.immval)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
--equip limit
function cod.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer() or e:GetHandler():GetEquipTarget()==c
end

--
function cod.immval(e,te)
	local lab=e:GetLabelObject()
	if not te:IsActivated() or e:GetOwnerPlayer()==te:GetOwnerPlayer() then return false end
	local _,g=Duel.GetOperationInfo(0,te:GetCategory())
	return not g or #g<2 or not (g:IsContains(lab[1]) and g:IsContains(lab[2]))
end

--gain effect
function cod.gecon(e,tp,eg,ep,ev,re,r,rp)
	if not re or re:GetHandler() then return end
	local rc=re:GetHandler()
	return rc:IsSetCard({SET_BLOOD_OMEN,0x601}) and rc:IsType(TYPE_SYNCHRO)
end

function cod.geop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	--cannot act effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE,0)
	e1:SetTarget(cod.tg)
	e1:SetValue(cod.val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	--aux.RegisterClientHint(rc,nil,tp,1,0,aux.Stringid(id,0),nil)
end

function cod.tg(e,c)
	return c:IsSetCard(SET_BLOOD_OMEN) and ((c:IsLocation(LOCATION_MZONE) and c:IsStatus(STATUS_SPSUMMON_TURN))
		or (c:IsLocation(LOCATION_GRAVE) and Duel.GetTurnCount()==e:GetHandler():GetTurnID()))
end
function cod.val(e,re)
	local ec=re:GetHandler()
	return ec:IsType(TYPE_MONSTER) and ec:IsAttribute(ATTRIBUTE_DARK)
end