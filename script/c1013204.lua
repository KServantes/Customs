--Blood Omen - Ililia
local cod,id=GetID()
function cod.initial_effect(c)
	--Linku
	c:EnableReviveLimit()
	--Unsummonable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(cod.splimit)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(1)
	e2:SetCondition(cod.sprcon)
	e2:SetOperation(cod.sprop)
	c:RegisterEffect(e2)
	--Gain LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cod.gcon)
	e3:SetTarget(cod.gtg)
	e3:SetOperation(cod.gop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,cod.chainfilter)
end

--no link summon
function cod.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK
end

--
function cod.chainfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xd3d))
end


--special summon
function cod.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local spct=Duel.GetFlagEffectLabel(tp,id)
	local acct=Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)
	return acct>1 and (not spct or acct-spct>=2) and Duel.GetLocationCountFromEx(tp)>0
end
function cod.sprop(e,tp,eg,ep,ev,re,r,rp)
	--flag label for acc count
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,0,2)
end

--gain lp
function cod.gcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function cod.gtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lg=e:GetHandler():GetLinkedGroup()
	local rec=0
	if #lg>0 then
		for tc in aux.Next(lg) do
			local atk=tc:GetAttack()
			rec=rec+atk
		end
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,rec)
end
function cod.gop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end