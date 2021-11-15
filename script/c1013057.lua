--Super Pendulum Fusion
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsType,TYPE_PENDULUM),
		matfilter=Fusion.OnFieldMat,
		extrafil=cod.fextra,
		extratg=cod.extratg
	}
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(cod.cost)
	c:RegisterEffect(e1)
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cod.pltg)
	e2:SetOperation(cod.plop)
	c:RegisterEffect(e2)
end
function cod.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cod.filter(c,tp)
	return (c:IsLocation(LOCATION_MZONE) and c:GetControler()==1-tp) or (c:IsFaceup() and c:IsAbleToGrave())
 end
function cod.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(cod.filter,tp,LOCATION_EXTRA+LOCATION_PZONE,LOCATION_MZONE,0,nil)
end
function cod.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

function cod.cfilter(c)
	return c:GetType()&(TYPE_FUSION+TYPE_PENDULUM)==TYPE_PENDULUM+TYPE_FUSION
end
function cod.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function cod.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp,cod.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g<0 or not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end
	Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end