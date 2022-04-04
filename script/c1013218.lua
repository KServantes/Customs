--Blood Omen - Quitilla
local cod,id=GetID()
function cod.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xd3d),cod.matfilter)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cod.syncon)
	e1:SetTarget(cod.drtg)
	e1:SetOperation(cod.drop)
	c:RegisterEffect(e1)
	--dark tuner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetCondition(cod.syncon)
	e2:SetValue(TYPE_TUNER)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(cod.synlimit)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x600)
	c:RegisterEffect(e4)
	--cannot trigger
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(cod.chainop)
	c:RegisterEffect(e5)
end

--fusion mats
cod.listed_series={0xd3d}
cod.material_setcode={0xd3d}
function cod.matfilter(c,fc,sumtype,tp)
	return c:GetOwner()==1-tp
end

--draw
function cod.syncon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	local h0=Duel.Draw(tp,1,REASON_EFFECT)
	if h0<=0 then return end
	local tc1=Duel.GetOperatedGroup():GetFirst()
	local h1=Duel.Draw(1-tp,1,REASON_EFFECT)
	if h1<=0 then return end
	local tc2=Duel.GetOperatedGroup():GetFirst()
	local t={}
	if tc1 and tc2 then
		Duel.BreakEffect()
		t={tc1,tc2}
	end
	if #t==0 then return end
	for i=1,2 do
		local p=i-1
		if t[i]:IsType(TYPE_SPELL+TYPE_TRAP) then
			Duel.SSet(p,t[i],p,true)
		else
			Duel.SendtoGrave(t[i],REASON_EFFECT)
		end
		Duel.ShuffleHand(p)
	end
end

--dark synchro limit
function cod.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x601)
end

--chain limit
function cod.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsSetCard(0xd3d) and re:IsActiveType(TYPE_SYNCHRO) then
		Duel.SetChainLimit(cod.chainlm)
	end
end
function cod.chainlm(e,rp,tp)
	return tp==rp
end