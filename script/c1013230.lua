--Blood Omen - Zhiriehl
local cod,id=GetID()
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,false,false,aux.FilterBoolFunctionEx(Card.IsSetCard,0xd3d),cod.ffilter(c))
	--Add Names
	Qued.RegisterExtraCodes(c,id)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function (e) return e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION~=0 end)
	e1:SetTarget(cod.remtg)
	e1:SetOperation(cod.remop)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(cod.operation)
	c:RegisterEffect(e2)
end
cod.listed_series={SET_BLOOD_OMEN}
cod.material_setcode=SET_BLOOD_OMEN

--fusion specs
function cod.ffilter(c)
	return function (fc)
		local tp=c:GetOwner()
		return fc:GetOwner()~=tp and fc:IsType(TYPE_MONSTER)
	end
end

--banish 'name'
function cod.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function cod.filter(c,...)
	return c:IsCode(...) or c:ListsCode(...) or c:IsSetCardExtra(...)
end
function cod.remop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<3 then return end
	local g=Duel.GetDecktopGroup(1-tp,3)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(cod.filter,1,nil,e:GetHandler():GetCode()) then
		local sg=g:Filter(cod.filter,nil,e:GetHandler():GetCode())
		Duel.DisableShuffleCheck()
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		g:Sub(sg)
	end
	if #g<=0 then return end
	Duel.MoveToDeckBottom(g,1-tp)
end

--negate effects in gy
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and a==c and d:IsStatus(STATUS_BATTLE_DESTROYED) then tc=d
	elseif d:GetControler()==p and d==c and a:IsStatus(STATUS_BATTLE_DESTROYED) then tc=a end
	if not tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
	tc:RegisterEffect(e2)
end
