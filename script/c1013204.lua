--Blood Omen - Ililia
local cod,id=GetID()
function cod.initial_effect(c)
	--Linku
	c:EnableReviveLimit()
	Qued.AddLinkProc(c,id,2)
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