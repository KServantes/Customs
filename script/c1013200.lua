--Blood Omen - Ririth
local cod,id=GetID()
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--attributes
	Qued.AddAttributes(c,true)
	--Activate
	Qued.BloodOmenSpellActivate(c,id)
	--Equip
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

--equip
function cod.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c.flag and c.flag==1
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
		--indes
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		--gains atk
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetCondition(function (e) return Duel.IsBattlePhase() end)
		e3:SetValue(1300)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e4)
	end
end
--equip limit
function cod.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer() or e:GetHandler():GetEquipTarget()==c
end

function cod.gecon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(SET_BLOOD_OMEN)
end

--gain effect
function cod.geop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	--cannot act to battle
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cod.batcon)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
	--cannot act to effects
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_ACTIVATING)
	e2:SetLabelObject(rc)
	-- e2:SetCondition(function (e) return e:GetLabelObject()~=nil end)
	e2:SetOperation(cod.chainop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(rc,nil,tp,1,0,aux.Stringid(id,0),nil)
end
function cod.batcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() then return false end
	return Duel.GetAttacker()==e:GetHandler()
end

function cod.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local eqc=e:GetLabelObject()
	if not eqc then e:Reset() return end
	if re:IsActiveType(TYPE_MONSTER) and rc==eqc then
		Duel.SetChainLimit(cod.chainlm)
	end
end
function cod.chainlm(e,rp,tp)
	return tp==rp
end