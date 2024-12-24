--Blood Metamorphosis
local cod,id=GetID()
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--gain lp
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(cod.lpcon)
	e2:SetTarget(cod.lptg)
	e2:SetOperation(cod.lpop)
	c:RegisterEffect(e2)
	--gain atk
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3b:SetCode(EVENT_CHAINING)
	e3b:SetRange(LOCATION_SZONE)
	e3b:SetOperation(aux.chainreg)
	c:RegisterEffect(e3b)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(cod.atkcon)
	e3:SetOperation(cod.atkop)
	c:RegisterEffect(e3)
	--fusion summon
    local e4=Fusion.CreateSummonEff({
    	handler=c,
    	fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_BLOOD_OMEN),
    	matfilter=cod.matfil,
    	extrafil=cod.extrafilter,
    	extraop=cod.extraop})
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(cod.fuscost)
	e4:SetCondition(cod.fuscon)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SEND_REPLACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(cod.shtg)
	e5:SetValue(cod.repval)
	c:RegisterEffect(e5)
end


--gain lp
function cod.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()~=nil
end
function cod.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
function cod.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end

--atk drain
function cod.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(1)~=0
		and (re:GetActiveType()&TYPE_BLOOD_SPELL)==TYPE_BLOOD_SPELL
end
function cod.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK)),tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--fusion summon
function cod.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end

function cod.fusfilter(c,e,tp)
	return c:IsMonster() and c:GetFlagEffect(id)>0 and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_DECK) and c:IsAbleToRemove()
end
function cod.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cod.fusfilter,1,nil,e,tp) 
end

--Check for My GY and Fusion Monster
-- function cod.checkmat(tp,sg,fc)
--     return fc:IsType(TYPE_FUSION) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
-- end
function cod.fcheck(tp,sg,fc)
    return sg:FilterCount(function(c)
        return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE) and c:GetFlagEffect(id)>0 end, nil)<=1
end

function cod.opfilter(c,tp)
	return c:GetFlagEffect(id)>0 and c:IsMonster()
end
function cod.cfilter(c,tp)
    return (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)) or 
           (c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsCanBeFusionMaterial())
end

function cod.matfil(c,e,tp,chk)
    return (c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial()) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
end

function cod.extrafilter(e,tp,mg)
    local eg1=Duel.GetMatchingGroup(cod.opfilter,tp,0,LOCATION_GRAVE,nil,tp)
    local eg2=Duel.GetMatchingGroup(cod.cfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil,tp)
    eg1=eg1+eg2
    if eg1 and #eg1>0 then
        return eg1,cod.fcheck
    end
    return Group.CreateGroup(), cod.fcheck -- Return an empty group if no valid cards were found
end

--Remove Materials
function cod.extraop(e,tc,tp,sg)
    local rg1=sg:Filter(function(c) return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) end, nil)
    local rg2=sg:Filter(function(c) return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE) and c:GetFlagEffect(id)>0 end, nil)
    rg2:GetFirst()
    -- Merge the two groups into one
    rg1:Merge(rg2)
    if #rg1>0 then
        Duel.Remove(rg1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        sg:Sub(rg1)
    end
end


--Check for Sent Monster
function cod.shfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:GetDestination()==LOCATION_GRAVE and c:IsAbleToRemove() and c:IsMonster()
end

--"Replace" monster: Apply Flag
function cod.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #eg==1 and eg:IsExists(cod.shfilter,1,nil,tp) end
	if e:GetHandler():IsFaceup() and e:GetHandler():IsLocation(LOCATION_SZONE) then
		local tc=eg:GetFirst()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
		e:SetLabelObject(Group.FromCards(tc))
		return true
	else 
		return false
	end
end

function cod.repval(e,c)
    return false
end