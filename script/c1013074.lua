--Dreigasch, Pendulum Skeleteer
local cod,id=GetID()
function c1013074.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon
	Pendulum.AddProcedure(c,false)
	--Synchro Summon
	Synchro.AddProcedure(c,cod.tfilter,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_ZOMBIE),1,99,cod.matfilter1)
	--[[ Pendulum Effects ]]
	--negate battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetLabel(CARD_AZEGAHL)
	e1:SetCondition(cod.negatkcon)
	e1:SetOperation(cod.negatkop)
	c:RegisterEffect(e1)
	--destroy all
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetLabel(CARD_AZEGAHL)
	e2:SetCondition(cod.descon)
	e2:SetTarget(cod.destg)
	e2:SetOperation(cod.desop)
	c:RegisterEffect(e2)
	--[[ Monster Effects ]]
	--place in pendy zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cod.plcon)
	e3:SetTarget(cod.pltg)
	e3:SetOperation(cod.plop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(cod.mainop)
	c:RegisterEffect(e4)
	--negate effects in zones
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(function(e,tp,_,ep) return ep==1-tp and e:GetLabel()==1 end)
	e5:SetCost(cod.chcost)
	e5:SetOperation(cod.chop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(cod.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
--Tuner filter
function cod.tfilter(c,lc,smtyp,tp)
	return c:IsRace(RACE_ZOMBIE,lc,smtyp,tp) and c:IsSetCard(0xf2,lc,smtyp,tp)
end
--Alt Synchro Summon
function cod.matfilter1(c,scard,sumtype,tp)
	return c:IsSetCard(0xf2,scard,sumtype,tp) and c:IsType(TYPE_PENDULUM,scard,sumtype,tp) and c:IsRace(RACE_ZOMBIE,scard,sumtype,tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end


--Pendulum Effects--
--change battle damage
function cod.negatkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return a:IsControler(1-tp) and at and at:IsControler(tp)
end
function cod.pfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function cod.negatkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.pfilter,tp,LOCATION_EXTRA,0,nil)
	if #g<=0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local sg=g:Select(tp,1,1,nil)
	if #sg<=0 then return end
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 and Duel.NegateAttack() then
		--skip battle phase
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end

--destroy monsters below atk
function cod.descon(e)
	local c=e:GetHandler()
	return c:IsReleasable() and c:IsFaceup() and not c:IsStatus(STATUS_CHAINING)
end
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function cod.dfilter(c,atk)
	return c:IsAttackBelow(atk) and c:IsDestructable()
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local atk=tc:GetAttack()
	local g=Duel.GetMatchingGroup(cod.dfilter,tp,0,LOCATION_MZONE,nil,atk)
	Duel.Destroy(g,REASON_EFFECT)
end


--Monster effects--
--place after battle
function cod.mainop(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if ph==PHASE_MAIN2 then
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,ep,ev)
	end
end
function cod.plcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function cod.plop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--synchro mat check
function cod.cfilter(c)
	return c:IsSetCard(0xf2) and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ZOMBIE)
end
function cod.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(cod.cfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

--change card effect
function cod.pafilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function cod.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.pafilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cod.pafilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function cod.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,cod.repop)
end
function cod.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	local res=c:IsLocation(LOCATION_SZONE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetTarget(cod.distg)
	e1:SetLabelObject({seq,res})
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,1-tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	Duel.RegisterEffect(e2,1-tp)
end
function cod.distg(e,c)
	local seq=e:GetLabelObject()[1]
	local res=e:GetLabelObject()[2]
	local adjmz=(c:IsLocation(LOCATION_MZONE) and c:IsSequence(seq-1,seq+1))
	if res then
		return adjmz or (c:GetSequence()==seq and c:IsLocation(LOCATION_SZONE))
	end
	return c:GetSequence()==seq or adjmz
end