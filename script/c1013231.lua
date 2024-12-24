--Blood Catasstroviya
local cod,id=GetID()
function cod.initial_effect(c)
	--count special summons
	aux.GlobalCheck(cod,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(cod.spcheckop)
		Duel.RegisterEffect(ge1,0)
	end)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(cod.con)
	e1:SetCost(cod.cost)
	e1:SetTarget(cod.tg)
	e1:SetOperation(cod.op)
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(cod.setcon)
	e2:SetTarget(cod.settg)
	e2:SetOperation(cod.setop)
	c:RegisterEffect(e2)
end

--special summon check func
function cod.spcheckop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
	end
end

--negate summon
function cod.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0 and Duel.GetFlagEffect(1-tp,id)>=3
end
function cod.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function cod.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg+g,#eg+g,0,0)
end
function cod.nfilter(c,...)
	return c:IsCode(...) or c:ListsCode(...) or c:IsSetCardExtra(...)
end
function cod.bfilter(c,eg)
	return c:IsFaceup() and c:IsSetCard(SET_BLOOD_OMEN) and c:IsType(TYPE_SYNCHRO)
		and eg:IsExists(cod.nfilter,1,nil,c:GetCode())
end
function cod.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local bg=Duel.IsExistingMatchingCard(cod.bfilter,tp,LOCATION_MZONE,0,1,nil)
	Duel.SendtoDeck(eg+g,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if #g>1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Set
function cod.cfilter(c,tp)
	return c:GetOwner()~=tp
end
function cod.setcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function cod.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function cod.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTODECK)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end