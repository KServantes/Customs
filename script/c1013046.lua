--Shadow Pendulum Specter
local cod,id = GetID()
function cod.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Gain Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cod.tetg)
	e1:SetOperation(cod.teop)
	c:RegisterEffect(e1)
end

--Gain Effect
function cod.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cod.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.Destroy(c, REASON_EFFECT)>0 then
		--Place in Pzone
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_EXTRA)
		e2:SetLabel(100)
		e2:SetCondition(cod.plcon)
		e2:SetTarget(cod.pltg)
		e2:SetOperation(cod.plop)
		e2:SetReset(RESET_EVENT+0x1bf0000)
		c:RegisterEffect(e2)
		--Draw
		local e3=e2:Clone()
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetCategory(CATEGORY_DRAW)
		e3:SetLabel(200)
		e3:SetTarget(cod.drtg)
		e3:SetOperation(cod.drop)
		c:RegisterEffect(e3)
	end
end

--Common Condition
function cod.plcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFaceup, tp, LOCATION_PZONE, 0, nil)==(e:GetLabel()/100) and Duel.GetFlagEffect(tp, id+e:GetLabel())==0
end

--Place in Pzone
function cod.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsLocation(LOCATION_PZONE)
end
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.filter, tp, LOCATION_EXTRA+LOCATION_ONFIELD, 0, 1, e:GetHandler()) end
	Duel.RegisterFlagEffect(tp, id+e:GetLabel(), RESET_PHASE+PHASE_END, 0, 0)
end
function cod.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp, cod.filter, tp, LOCATION_EXTRA+LOCATION_ONFIELD, 0, 1, 1, e:GetHandler())
	if #g<0 or not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end
	Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

--Draw
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_PZONE,0,2,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_PZONE,0,2,2,nil)
	if #g<2 then return end
	Duel.Destroy(g,REASON_EFFECT+REASON_COST)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.RegisterFlagEffect(tp, id+e:GetLabel(), RESET_PHASE+PHASE_END, 0, 0)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end