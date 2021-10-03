--Pendulum Bone Mouse
--[[If you Fusion Summon a Pendulum Monster and the materials used for its Summon are in the Extra Deck: 
You can destroy this card; add the face-up materials from the Extra Deck to your hand. 
You can only activate this effect of "Pendulum Bone Mouse" once per turn. 
Once, while this card is on the field: You can shuffle up to 5 face-up cards in your Extra Deck (min. 3) into the Deck, and if you do, draw 1 card for every 2 cards sent.]]--
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
	e2:SetTarget(cod.drtg)
	e2:SetOperation(cod.drop)
	c:RegisterEffect(e2)
end

function cod.sumfilter(c)
	return c:GetType()==TYPE_FUSION+TYPE_PENDULUM and c:GetSummonType()==SUMMON_TYPE_FUSION
		and c:GetMateriaCount() == c:GetMaterial():FilterCount(aux.AND(Card.IsFaceup, aux.FilterBoolFunction(Card.IsLocation,LOCATION_EXTRA)),nil)
end
function cod.rccon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(cod.sumfilter,1,nil) then
		if #eg==1 then
			e:SetLabel(eg:GetFirst():GetMaterialCount())
			e:SetLabelObject(eg:GetFirst():GetMaterial())
		else
			e:SetLabel(99)
			e:SetLabelObject(eg)
		end
	end
end
function cod.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() 
		and Duel.IsExistingMatchingCard(cod.sumfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Destroy(e:GetHandler(), REASON_EFFECT)
	local g
	if e:GetHandler()~=99 then
		g = e:GetLabelObject()
	else
		Duel.Hint(HINT_SELECTMSG,tp, HINTMSG_ATOHAND)
		local sc=e:GetLabelObject():FilterSelect(cod.sumfilter,1,1,nil)
		g = sc:GetMaterial()
		e:SetLabelObject(g)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_EXTRA)
end
function cod.rcop(e,tp,eg,ep,ev,re,r,rp)
	local mats=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=mats:Select(tp,#mats,#mats,true,nil)
	if #g<=0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end

function cod.helper(tp)
	local i = 1
	table = [1, 2, 3]
	draw = 0
	for i in table do
		if not Duel.IsPlayerCanDraw(tp, i) then
			draw = i
		end
	end
end
function cod.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp, 1) 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_EXTRA,0,2,nil) end
	local ct = cod.helper(tp)
	local max = ct*2
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_EXTRA,0,2,max,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end