--Skelegon
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013051.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,29491031,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON))
	--Place
	Qued.AddRPepeEffect(c,id)
	--Direct Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	c:RegisterEffect(e1)
	--Change DMG
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(cod.rdcon)
	e2:SetTargetRange(0,1)
	e2:SetValue(cod.rdval)
	c:RegisterEffect(e2)
	--Pendulum
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_PZONE)
	e3:SetOperation(cod.indop)
	c:RegisterEffect(e3)
end

function cod.rdcon(e)
	local tp=e:GetHandlerPlayer()
	local ac=Duel.GetAttacker()
	return ac:GetControler()==tp and ac:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
		and Duel.GetAttackTarget()==nil and ac:IsRace(RACE_ZOMBIE) 
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end

function cod.rdval(e,damp)
	local ac=Duel.GetAttacker()
	if ac:GetAttack()<=1700 then
		return -1
	else
		return 1700
	end
end

function cod.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
		and (not e or c:IsRelateToEffect(e))
end
function cod.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(cod.cfilter,nil,nil,tp)
	if #g<=0 then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		--Unaffected by other cards
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(cod.econ)
		e1:SetValue(cod.efilter)
		e1:SetLabel(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

function cod.econ(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function cod.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end