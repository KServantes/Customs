--The Wandering Doomed
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Pendulum Proc
	Pendulum.AddProcedure(c)
	---==Pendulum Effect==---
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cod.ctg)
	e1:SetOperation(cod.cop)
	c:RegisterEffect(e1)
end
function cod.ctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_EXTRA, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_EXTRA, 0, 1, 1, nil)
end
function cod.cop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	e:GetHandler():CopyEffect(tc:GetCode(), RESET_EVENT+RESETS_STANDARD)
end