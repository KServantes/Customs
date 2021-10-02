--Shadow Pendulum Specter
--[[You can destroy this card in your Pendulum Zone, and if you do, this card gains this effect while face-up in the Extra Deck:
● If you have only 1 card in your Pendulum Zone: You can select 1 face-up Pendulum card in your Extra Deck or field; place it in your Pendulum Zone.
● If you have 2 cards in your Pendulum Zones: You can destroy both cards, and if you do, draw 1 card.
You can only activate each effect of "Shadow Pendulum Specter" once per turn.]]--
local cod,id = GetID()
function cod.initial_effect(c)
	--Pendulum Set
	Pendulum.AddProcedure(c)
	--Gain Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
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
	if Duel.Destroy(c)>0 then
		--Place in Pzone
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_EXTRA)
		e2:SetLabel(1)
		e2:SetCountLimit(1,id)
		e2:SetCondition(cod.plcon)
		e2:SetTarget(cod.pltg)
		e2:SetOperation(cod.plop)
		e2:SetReset(RESETS_STANDARD)
		c:RegisterEffect(e2)
		--Draw
		local e3=e2:Clone()
		e3:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
		e3:SetLabel(2)
		e3:SetTarget(cod.drtg)
		e3:SetOperation(cod.drop)
		c:RegisterEffect(e3)
end

--Common Condition
function cod.plcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFaceup, LOCATION_PZONE, 0, nil)==e:GetLabel()
end

--Place in Pzone
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local filter = aux.AND(aux.FilterBoolFunction(Card.IsType, TYPE_PENDULUM), Card.IsFaceup)
	if chk==0 then return Duel.IsExistingMatchingCard(filter, LOCATION_EXTRA+LOCATION_FIELD, 0, 1, nil) end
end
function cod.plop(e,tp,eg,ep,ev,re,r,rp)
	local filter = aux.AND(aux.FilterBoolFunction(Card.IsType, TYPE_PENDULUM), Card.IsFaceup)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp, filter, tp, LOCATION_EXTRA+LOCATION_FIELD, 0, 1, 1, nil)
	if #g<0 or not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) return end
	Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

--Draw
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_PZONE,0,2,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_PZONE,0,2,2,nil)
	if #g<2 then return end
	Duel.Destroy(g,REASON_EFFECT)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end