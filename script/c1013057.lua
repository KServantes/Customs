--Super Pendulum Fusion
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,matfilter=Fusion.OnFieldMat,extrafil=cod.fextra,extratg=cod.extratg}
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(cod.cost)
	c:RegisterEffect(e1)
end
function cod.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cod.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,LOCATION_PZONE+LOCATION_EXTRA,0,nil)
	g:Merge(g2)
	return g
end
function cod.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
