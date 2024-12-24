--Blood Omen - Ililia
local cod,id=GetID()
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--Link Summon
	Qued.AddLinkProc(c,id,2)
	--Cannot be used for Summon, except xyz
	Qued.UseOnlyAsXyzMat(c,3,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK))
	--Shuffle after detach
	Qued.ShuffleAfterDetach(c)
	--force mzone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(function (e,c,fp,rp,r)
		return e:GetHandler():GetLinkedZone(rp)|0x600060
	end)
	c:RegisterEffect(e1)
end