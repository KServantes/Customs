--Pendulum Zombie Dragon
function c1013030.initial_effect(c)
	 --Pendulum Set
	Pendulum.AddProcedure(c,false)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(c1013030.activate)
	c:RegisterEffect(e1)
	--Pend Effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1013030,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	--for copy effect
	e3:SetLabel(1013058)
	e3:SetTarget(c1013030.postg)
	e3:SetOperation(c1013030.posop)
	c:RegisterEffect(e3)
	--alias
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetValue(66672569)
	c:RegisterEffect(e2)
end
function c1013030.cfilter(c)
	return c:IsLevelBelow(4) and c:IsType(TYPE_PENDULUM)
end
function c1013030.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c1013030.cfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1013030,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c1013030.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetAttackTarget()
	local ac=Duel.GetAttacker()
	if chk==0 then return bc and bc:GetAttack()>0 and bc:IsControler(1-tp) 
		and ac:GetAttack()<=2000 and ac:IsRace(RACE_ZOMBIE) end
end
function c1013030.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttackTarget()
	local ac=Duel.GetAttacker()
	if bc and bc:IsControler(1-tp) and ac:GetAttack()<=2000 and ac:IsRace(RACE_ZOMBIE) then
		if c:GetFlagEffect(1013030)~=0 then return end
		local ae=Effect.CreateEffect(c)
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ae:SetCode(EFFECT_SET_ATTACK_FINAL)
		ae:SetValue(0)
		ae:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(ae)
		local de=ae:Clone()
		de:SetCode(EFFECT_SET_DEFENSE_FINAL)
		bc:RegisterEffect(de)
		c:RegisterFlagEffect(1013030,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
