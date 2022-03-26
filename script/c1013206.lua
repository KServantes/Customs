--Blood Omen - Lyria
local cod,id=GetID()
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
		cod.chain={}
		cod.chainct=0
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

--helper function
local function checkFilter(ct)
	local flag=false
	for i=1,ct do
		if flag==true then break end
		local cheff=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local rc=cheff:GetHandler()
		if rc and rc:IsType(TYPE_MONSTER) and Duel.IsChainNegatable(i) and not rc:IsSetCard(0xd3d) then
			flag=true
		end
	end
	return flag
end
--register chain cards and count
function cod.chreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not cod.chain[c] then
		cod.chain[c]=Group.CreateGroup()
		cod.chain[c]:KeepAlive()
	end
	local cg=cod.chain[c]
	local ct=cod.chainct
	cg:AddCard(re:GetHandler())
	ct=ct+1
	cod.chainct=ct
	if cg:IsExists(Card.IsSetCard,1,nil,0xd3d) and checkFilter(ct) then
		Duel.RaiseEvent(Group.FromCards(c),EVENT_CUSTOM+id,re,r,rp,ep,ev)
	end
end
function cod.resetop(e,tp,eg,ep,ev,re,r,rp)
	cod.chain[e:GetHandler()]=nil
	cod.chainct=0
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
	local ct=cod.chainct
	local cg=Group.CreateGroup()
	local opt={}
	local op=nil
	for i=1,ct do
		local cheff=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local rc=cheff:GetHandler()
		if rc and rc:IsType(TYPE_MONSTER) and not rc:IsSetCard(0xd3d) then
			if not opt[rc] then
				opt[rc]={i,cheff}
			elseif opt[rc] then
				table.insert(opt[rc],i)
				table.insert(opt[rc],cheff)
			end
			cg:AddCard(rc)
		end
	end
	if #cg<=0 then return end
	Duel.Hint(HINTMSG_SELECT,tp,HINTMSG_SPSUMMON)
	local ng=cg:Select(tp,1,1,nil)
	local nc=ng:GetFirst()
	if #opt[nc]>2 then
		local str={}
		for i=2,#opt[nc] do
			if i % 2 == 0 then
				table.insert(str,opt[nc][i]:GetDescription())
			end
		end
		op=Duel.SelectOption(tp,table.unpack(str))
		op=opt[nc][(op+1)+op]
	else
		op=opt[nc][1]
	end
	if not op then return end
	Duel.NegateEffect(op)
end

--activate
function cod.actfilter(c,e,tp)
	return c:IsSetCard(0xd3d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetActivateEffect():IsActivatable(tp,true,false)
end
function cod.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function cod.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.actfilter,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local se=sc:GetActivateEffect()
	local tg=se:GetTarget()
	local op=se:GetOperation()
	e:SetCategory(se:GetCategory())
	sc:CreateEffectRelation(se)
	if tg then tg(se,tp,eg,ep,ev,re,r,rp,1) end
	Duel.RaiseEvent(Group.FromCards(sc),EVENT_CHAINING,se,r,rp,ep,ev)
	sc:CancelToGrave(false)
	Duel.BreakEffect()
	sc:SetStatus(STATUS_ACTIVATED,true)
	if op and not sc:IsDisabled() then op(se,tp,eg,ep,ev,re,r,rp,1) end
	sc:ReleaseEffectRelation(se)
end
