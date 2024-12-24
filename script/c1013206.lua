--Blood Omen - Lyra
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
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(cod.negcost)
	e1:SetTarget(cod.negtg)
	e1:SetOperation(cod.negop)
	c:RegisterEffect(e1)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),LOCATION_MZONE,0)==1 end)
	e2:SetTarget(cod.acttg)
	e2:SetOperation(cod.actop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(cod,function()
		local ft=Qued.funTable
		cod.st={ sc=ft(), oc=ft() }
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(function (e,tp,_,_,ev) return Qued.CheckChain(e:GetHandler(),tp,ev) end)
		ge1:SetOperation(cod.chreg)
		Duel.RegisterEffect(ge1,0)
	end)
end




--register chain cards and count
function cod.chreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.RaiseEvent(Group.FromCards(c),EVENT_CUSTOM+id,re,r,rp,ep,ev)
end

--negate
function cod.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cod.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0)
	if ev>2 then
		Duel.SetChainLimit(cod.chlimit)
	end
end
function cod.chlimit(e,ep,tp)
	return tp==ep
end

function cod.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cht,cg=Qued.GetChainTableAndGroup(ev,tp)
	Duel.Hint(HINTMSG_SELECT,tp,HINTMSG_SPSUMMON)
	local ng=cg:Select(tp,1,1,nil)
	local nc=ng:GetFirst()
	local op=Qued.GetChainToNegateFromTable(cht[nc],tp)
	Duel.NegateEffect(op)
end

--activate
function cod.actfilter(c,e,tp)
	if not c:IsType(TYPE_BLOOD_SPELL) then return end
	return c:IsSetCard(SET_BLOOD_OMEN) and c:GetActivateEffect():IsActivatable(tp,true,false)
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
    --
    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(_,c) return not c:IsSetCard(SET_BLOOD_OMEN) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
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