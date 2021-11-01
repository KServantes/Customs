--Pendulum Zombie Warrior
local cod, id = GetID()
Duel.LoadScript('kd.lua')
function c1013049.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),aux.FilterBoolFunctionEx(Card.IsRace, RACE_WARRIOR))
	--Place
	Qued.AddRPepeEffect(c,id)
	--Gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_PZONE)
	e1:SetValue(cod.val)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCondition(cod.descon)
	e2:SetTarget(cod.destg)
	e2:SetOperation(cod.desop)
	c:RegisterEffect(e2)
end
cod.vt={0,0,0,0,0,0}

function cod.val(e)
	Qued.GetValues(e,cod.vt)
	local val=0
	for k,v in ipairs(cod.vt) do
		if type(v)=='table' then
			val=val + v[1]
		end
	end
	return val/2
end

function cod.filter(c,tp)
	return	c:IsReason(REASON_BATTLE) and c:GetReasonCard():IsType(TYPE_PENDULUM+TYPE_NORMAL)
		and c:IsControler(1-tp) and c:GetReasonCard():IsControler(tp)
end
function cod.descon(e,tp,eg,ep,ev,re,r,rp)
	if #eg==1 then
		if cod.filter(eg:GetFirst(),tp) then
			e:SetLabel(eg:GetFirst():GetSequence())
			return true
		end
	else
		--to be removed later?
		if eg:IsExists(cod.filter,1,nil,tp) then
			local seq=nil
			for tc in aux.Next(eg) do
				if seq==nil then
					seq=tc:GetSequence()
				end
			end
			if seq==nil then return false end
			e:SetLabel(seq)
			return true
		end
	end
end
function cod.desf(c,seq)
	if seq<=4 then
		return	c:IsSequence(seq-1) or c:IsSequence(seq+1)
	else
		return c:IsSequence(5) or c:IsSequence(6)
	end
end
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.desf,tp,0,LOCATION_MZONE,1,nil,e:GetLabel()) end
	local g=Duel.GetMatchingGroup(cod.desf,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,LOCATION_MZONE)
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.desf,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.Destroy(g,REASON_EFFECT)
end