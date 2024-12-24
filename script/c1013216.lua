--Blood Omen - Permilla
local cod,id=GetID()
Duel.LoadScript("kd.lua")
function cod.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xd3d),1,1,Synchro.NonTuner(Card.IsRace,RACE_ZOMBIE),1,99)
	c:EnableReviveLimit()
	--Add Names
	Qued.RegisterExtraCodes(c,id)
	--gain atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function (e,c) return #{c:GetCode()}*750 end)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cod.thcon)
	e2:SetTarget(cod.thtg)
	e2:SetOperation(cod.thop)
	c:RegisterEffect(e2)
	--remove
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_EQUIP)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(cod.remcon)
	e3:SetTarget(cod.remtg)
	e3:SetOperation(cod.remop)
	c:RegisterEffect(e3)
end

--search
function cod.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()
end

function cod.bfilter(c,sc)
	return c:IsSetCard(0xd3d) or c:IsSetCard(0xd3e) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(cod.bfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(cod.bfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,nil,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND|CATEGORY_SEARCH,g,1,tp,LOCATION_DECK|LOCATION_REMOVED)
end

function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetHandler()
	local g=Duel.GetMatchingGroup(cod.bfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,nil,sc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoHand(sg,tp,REASON_EFFECT,tp)
	Duel.ConfirmCards(1-tp,sg)
end


--remove
function cod.rfilter(c)
	Debug.Message('type? ' .. string.format("%x",c:GetType()))
	if c.flag and c.flag==1 then return true end
	return c:IsSetCard(0xd3d) and c:IsType(TYPE_MONSTER)
end
function cod.remcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cod.rfilter,1,nil)
end

function cod.refilter(c,sc,tp)
	local codes=sc:GetCode()
	return (c:IsCode(codes) or c:ListsCode(codes) or c:IsSetCardExtra(codes)) and c:IsAbleToRemove(1-tp)
end
function cod.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(cod.refilter,tp,0,LOCATION_EXTRA,1,nil,c,tp) end
	local announce_filter={}
	for _,code in pairs({c:GetCode()}) do
		if #announce_filter==0 then
			table.insert(announce_filter,code)
			table.insert(announce_filter,OPCODE_ISCODE)
		else
			table.insert(announce_filter,code)
			table.insert(announce_filter,OPCODE_ISCODE)
			table.insert(announce_filter,OPCODE_OR)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	local g=Duel.GetMatchingGroup(cod.reefilter,tp,0,LOCATION_EXTRA,nil,ac,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,#g,1-tp,LOCATION_EXTRA)
end

function cod.reefilter(c,code,tp)
	return (c:IsCode(code) or c:ListsCode(code) or c:IsSetCardExtra(code)) and c:IsAbleToRemove(1-tp)
end
function cod.remop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local exg=Duel.GetMatchingGroup(cod.reefilter,tp,0,LOCATION_EXTRA,nil,ac,tp)
	if #exg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local sg=exg:Select(1-tp,1,1,nil,ac,tp)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT,1-tp,1-tp)
end