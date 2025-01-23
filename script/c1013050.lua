--Pendulum Mammoth of Goldfine
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013050.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,29491031,66672569)
	--Place
	Qued.AddRPepeEffect(c,id)
	--Drain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE+LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(function (e,c) return not c:IsNonEffectMonster() end)
	e1:SetValue(function (e,c) return -(c:GetAttack()/2) end)
		--for copy effect
	e1:SetLabel(CARD_AZEGAHL)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_PZONE+LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(cod.limit)
		--for copy effect
	e2:SetLabel(CARD_AZEGAHL)
	c:RegisterEffect(e2)
	--Move
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetCost(cod.mvcost)
	e3:SetTarget(cod.mvtg)
	e3:SetOperation(cod.mvop)
		--for copy effect
	e3:SetLabel(CARD_AZEGAHL)
	c:RegisterEffect(e3)
end

function cod.limit(e,se,sp)
	local sc=se:GetHandler()
	return se:IsMonsterEffect() and se:GetCode()==EVENT_SPSUMMON_SUCCESS and se:IsHasType(EFFECT_TYPE_SINGLE)
end

function cod.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cod.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		seq=c:GetSequence()
	else
		if c:IsSequence(4) then
			seq=3
		else
			seq=1
		end
	end
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_SZONE,seq) end
	e:SetLabel(seq)
end
function cod.mvop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) or not Duel.CheckLocation(tp,LOCATION_SZONE,seq) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT+0x1fc0000)
	c:RegisterEffect(e1)
	if c:GetLocation()==LOCATION_SZONE then
		Duel.MoveSequence(c,seq)
	else
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true,(1<<seq))
	end
end
