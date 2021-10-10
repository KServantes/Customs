--Pendulum Bone Mouse
local cod,id=GetID()
function c1013047.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Recover Materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(cod.rccon)
	e1:SetTarget(cod.rctg)
	e1:SetOperation(cod.rcop)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCost(cod.drcost)
	e2:SetTarget(cod.drtg)
	e2:SetOperation(cod.drop)
	c:RegisterEffect(e2)
end

--Recover
function cod.sumfilter(c)
	if not c:IsType(TYPE_FUSION) then return false end
	return c:IsType(TYPE_PENDULUM) and c:GetSummonType()==SUMMON_TYPE_FUSION and c:GetMaterialCount()~=0
		and c:GetMaterialCount() == c:GetMaterial():FilterCount(aux.AND(Card.IsFaceup, aux.FilterBoolFunction(Card.IsLocation,LOCATION_EXTRA)),nil)
end
function cod.rccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cod.sumfilter,1,nil) 
end
function cod.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() 
		and Duel.IsExistingMatchingCard(cod.sumfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Destroy(e:GetHandler(), REASON_EFFECT)
	local g=Group.CreateGroup()
	if #eg==1 then
		g=eg:GetFirst():GetMaterial()
	else
		Duel.Hint(HINT_SELECTMSG,tp, HINTMSG_ATOHAND)
		local sc=eg:FilterSelect(cod.sumfilter,1,1,nil)
		g=sc:GetMaterial()
	end
	e:SetLabelObject(g)
	g:KeepAlive()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_EXTRA)
end
function cod.rcop(e,tp,eg,ep,ev,re,r,rp)
	local mats=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=mats:Select(tp,#mats,#mats,true,nil)
	if #g<=0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end

--Draw
function cod.helper(tp)
	local draw = 0
	for i=1, 3 do
		if Duel.IsPlayerCanDraw(tp, i) then
			draw = i
		end
	end
	return draw
end
function cod.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_EXTRA,0,2,nil) end
	local ct = cod.helper(tp)
	local max = ct*2
	if max<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_EXTRA,0,2,max,nil)
	local sc=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	e:SetLabel(sc)
end
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel() and Duel.IsPlayerCanDraw(tp, e:GetLabel()/2) end
	Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end