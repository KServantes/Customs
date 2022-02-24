--Dreigasch, Pendulum Skeleteer
local cod,id=GetID()
function c1013074.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon
	Pendulum.AddProcedure(c,false)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_ZOMBIE),1,99, cod.matfilter1)
	--[[ Pendulum Effects ]]
	--battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cod.bdcon)
	e1:SetOperation(cod.bdop)
	c:RegisterEffect(e1)
	--lp gain

	--[[ Monster Effects ]]
	--no tuner check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(80896940)
	c:RegisterEffect(e3)
	--apply effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cod.syccon)
	e4:SetOperation(cod.apop)
	c:RegisterEffect(e4)
	--skip bp
end

--Synchro Summon
function cod.matfilter1(c,scard,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,scard,sumtype,tp) and c:IsRace(RACE_ZOMBIE,scard,sumtype,tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end


--Pendulum effects
--change battle damage
function cod.bdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() or Duel.IsBattlePhase()
end
function cod.bdop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

--gain lp and destroy


--Monster effects
--apply effects
function cod.confilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf2) and not c:IsType(TYPE_EFFECT)
end
function cod.syccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mats=c:GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and #mats>0 and mats:IsExists(cod.confilter,1,nil)
end
function cod.apop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g<=0 then return end
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_PENDULUM) and tc:IsSetCard(0xf2) and not tc:IsType(TYPE_EFFECT) then
			if c:GetFlagEffect(id+tc:GetCode())>0 then return end
			local effs={tc:GetCardEffect()}
			for _,eff in ipairs(effs) do
				if eff:GetLabel()==CARD_AZEGAHL then
					local ex=eff:Clone()
					ex:SetRange(LOCATION_MZONE)
					ex:SetReset(RESET_EVENT+RESETS_STANDARD)
					c:RegisterEffect(ex)
					c:RegisterFlagEffect(id+tc:GetCode(),RESET_EVENT+RESETS_STANDARD,0,1)
					c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(tc:GetCode(),10))
				end
			end
		end
	end
end