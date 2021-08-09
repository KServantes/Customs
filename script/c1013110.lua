--Rebellion of Futures yet to Come
--Keddy was here~
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],'c%d+%.lua')
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
--[[2+ Zombie Link Monsters

1. You can also Special Summon this card when 3 or more Zombie monsters you control leave the field. 
2. Any monster this card battles is not destroyed as a result of that battle. 
3. If this card battles an opponent's monster, inflict damage equal to this monster's ATK to your opponent before damage calculation, 
	and if you do, destroy the opposing monster, also, monsters in zones adjacent to that monster lose ATK equal to the destroyed monster's ATK.]]--
local id,cod=ID()
function cod.initial_effect(c)
	--Invocación Enlace
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.AND(aux.FilterBoolFunction(Card.IsType,TYPE_LINK),aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE)),2)
	--Invocación Especial
	--[[local e0_a=Effect.CreateEffect(c)
	e0_a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0_a:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0_a:SetCode(EVENT_LEAVE_FIELD)
	e0_a:SetRange(LOCATION_EXTRA)
	e0_a:SetCondition(cod.spcon_ex)
	e0_a:SetTarget(cod.sptg_ex)
	e0_a:SetOperation(cod.spop_ex)
	c:RegisterEffect(e0_a)]]--
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(function (e,c) return c==e:GetHandler():GetBattleTarget() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Inflict/Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8198620,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetTarget(cod.attg)
	e2:SetOperation(cod.atop)
	c:RegisterEffect(e2)
end
function cod.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
end
function cod.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		local atk=c:GetAttack()
		local matk=bc:GetAttack()
		if Duel.Damage(1-tp,atk,REASON_EFFECT) then
			Duel.Exile(bc,REASON_RULE)
			local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			if #g<=0 then return end
			for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-matk)
				e1:SetReset(RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end