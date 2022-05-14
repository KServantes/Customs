--Blood Omen - Lyria
local cod,id=GetID()
Duel.LoadScript('kd.lua')
function cod.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(cod.negcost)
	e1:SetTarget(cod.negtg)
	e1:SetOperation(cod.negop)
	c:RegisterEffect(e1)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(cod.acttg)
	e2:SetOperation(cod.actop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(cod,function()
		cod.chain={ct=0}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(cod.chreg)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_END)
		ge2:SetOperation(cod.resetop)
		Duel.RegisterEffect(ge2,0)
	end)
end

--register chain cards and count
function cod.chreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chain=cod.chain
	if not chain[c] then
		chain[c]=Group.CreateGroup()
		chain[c]:KeepAlive()
	end
	local cg,ct=chain[c],chain.ct
	cg:AddCard(re:GetHandler())
	ct=ct+1
	chain.ct=ct
	if cg:IsExists(Card.IsSetCard,1,nil,0xd3d) and Qued.CheckChain(ct) then
		Duel.RaiseEvent(Group.FromCards(c),EVENT_CUSTOM+id,e,0,tp,0,0)
	end
end
function cod.resetop(e,tp,eg,ep,ev,re,r,rp)
	cod.chain[e:GetHandler()]=nil
	cod.chain.ct=0
end

--negate
function cod.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cod.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0)
end
function cod.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cht,cg=Qued.GetChainLinkInfo(cod.chain.ct)
	Duel.Hint(HINTMSG_SELECT,tp,HINTMSG_SPSUMMON)
	local ng=cg:Select(tp,1,1,nil)
	local nc=ng:GetFirst()
	local op=Qued.GetChainLinkid(cht,nc,tp)
	Duel.NegateEffect(op)
end

--activate
function cod.actfilter(c,e,tp)
	local type_spell=TYPE_SPELL+TYPE_QUICKPLAY
	local type_trap=TYPE_TRAP+TYPE_COUNTER
	if not c:IsType(type_spell|type_trap) then return end
	return c:IsSetCard(0xd3d) and c:GetActivateEffect():IsActivatable(tp,true,false)
end
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(cod.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(cod.actfilter,tp,LOCATION_DECK,0,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    --activate
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_CHAIN_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(sc)
    e1:SetOperation(cod.faop)
    Duel.RegisterEffect(e1,tp)
end
function cod.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep) then
        Duel.Activate(te)
    end
    e:Reset()
end