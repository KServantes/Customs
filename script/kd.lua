--An uneccesary file I made because I could
--Keddy war hier~
--Reborn Pepe & Blood Omen
if not aux.ExtrasDeKedy then
	aux.ExtrasDeKedy = {}
	Qued = aux.ExtraDeKedy
end

if not Qued then
	Qued = aux.ExtrasDeKedy
end

--Common used cards
CARD_PEND_FLAME_GHOST = 1013048
CARD_AZEGAHL = 1013058
CARD_ILILIA = 1013204
CARD_CHARITY = 1013212
-- CARD_LYRIA = 1013206

--Resets
RESETS_BLOOD_OMEN = RESET_TODECK|RESET_TOHAND|RESET_REMOVE

--CONSTANTS
HINTMSG_CHAINNO=4005

TYPE_BLOOD_SPELL=TYPE_QUICKPLAY+TYPE_SPELL
TYPE_BLOOD_TRAP=TYPE_COUNTER+TYPE_TRAP
TYPE_EFFECT_MON=TYPE_EFFECT+TYPE_MONSTER
TYPE_TUNER_MON=TYPE_EFFECT_MON+TYPE_TUNER


--[[ Rewrites and Custom Functions ]]---
local card_can_special, card_can_be_fusion_mat, duel_special_summon = 
	Card.IsCanBeSpecialSummoned, Card.IsCanBeFusionMaterial, Duel.SpecialSummon

--Min and Max levels between scales
local function getLvBetween(c)
	local min, max
	local lscale, rscale = c:GetLeftScale(), c:GetRightScale()
	if lscale == rscale then return 0, 0 end
	if lscale > rscale then
		max = lscale -1
		min = rscale +1
	else
		min = lscale +1
		max = rscale -1
	end
	return min, max
end
--card with self flag
local function selfCode(c)
	local id=c:GetCode()
	return c:GetFlagEffect(id)>0
end
--add monster attribute
local function addMonAtt(c)
	local card=c:GetMetatable(c)
	if not card.atts then 
		c:AddMonsterAttribute(TYPE_EFFECT)
	else
		local type=card.atts.ctpe
		c:AddMonsterAttribute(type&~TYPE_MONSTER)
	end
end
Card.IsCanBeSpecialSummoned=function(c,e,sumtype,sumplayer,nochk,nolim,...)
    local options={...}
    if c:IsType(TYPE_MONSTER) and c:IsSetCard(0xd3d) and selfCode(c) then
        return card_can_special(c,e,sumtype,sumplayer,true,nolim,table.unpack(options))
    end
    return card_can_special(c,e,sumtype,sumplayer,nochk,nolim,table.unpack(options))
end
Duel.SpecialSummon=function(cards,sumtype,sumplayer,tg_player,nochk,nolim,pos,...)
    local options={...}
    if type(cards)=='Card' then
        if Qued.bofilter(cards) then
            addMonAtt(cards)
            Duel.SpecialSummonStep(cards,sumtype,sumplayer,tg_player,true,nolim,pos,table.unpack(options))
            cards:AddMonsterAttributeComplete()
            return 1
        else
            return duel_special_summon(cards,sumtype,sumplayer,tg_player,nochk,nolim,pos,table.unpack(options))
        end
    else
        local sg=Group.CreateGroup()+cards
        local sumct=0
        sg=sg:Filter(Qued.bofilter,nil)
        for tc in sg:Iter() do
            addMonAtt(tc)
            Duel.SpecialSummonStep(tc,sumtype,sumplayer,tg_player,true,nolim,pos,table.unpack(options))
            tc:AddMonsterAttributeComplete()
            sumct=sumct+1
            cards:RemoveCard(tc)
        end
        Duel.SpecialSummonComplete()
        if #cards==0 then return sumct end
        return duel_special_summon(cards,sumtype,sumplayer,tg_player,nochk,nolim,pos,table.unpack(options)) + sumct
    end
end
Card.IsCanBeFusionMaterial=function(c,fuscard,ign_mon)
	if c:IsSetCard(0xd3d) and selfCode(c) then
		return true
	end
	return card_can_be_fusion_mat(c,fuscard,ign_mon)
end
function Qued.bofilter(c)
	return c:IsSetCard(0xd3d) and selfCode(c)
end

--[[ Reborn Pepe Functions ]]---

--Common on placed in pzone summon effect
function Qued.AddRPepeEffect(c,id)
	local card = Card.GetMetatable(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+CARD_PEND_FLAME_GHOST)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(Qued.SpecialTarget(c))
	e1:SetOperation(Qued.SpecialOperation(c,id))
	c:RegisterEffect(e1)
	Qued.PendPlaceCheck(card,c)
end
--"When this card is placed in your Pendulum Zone"
function Qued.PendPlaceCheck(card,c)
	if not card.global_check then
		card.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(Qued.checkop(c,CARD_PEND_FLAME_GHOST))
		Duel.RegisterEffect(ge1,0)
	end
end
function Qued.chkfilter(c,id)
	local seq=c:GetSequence()
	local prev=(not c:IsPreviousLocation(LOCATION_PZONE) or c:GetPreviousSequence()~=seq)
	return c:GetFlagEffect(id+seq+1)==0 and prev
end
function Qued.checkop(c,id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tot=Duel.IsDuelType(DUEL_SEPARATE_PZONE) and 13 or 4
		local g=Duel.GetMatchingGroup(Qued.chkfilter,tp,LOCATION_PZONE,0,nil,id)
		if #g>0 then
			for tc in aux.Next(g) do
				tc:ResetFlagEffect(id+tot-(tc:GetSequence()+1))
				Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,tp,tp,0)
				tc:RegisterFlagEffect(id+tc:GetSequence()+1,RESET_EVENT+RESETS_STANDARD,0,1)
			end
		end
	end
end
function Qued.SpecialFilter(c,e,tp,min,max)
	if min == max then return false end
	local lv = c:GetLevel()
	return lv>=min and lv<=max and c:IsType(TYPE_FUSION) 
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Qued.SpecialTarget(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local min, max = getLvBetween(c)
		if chk==0 then return Duel.IsExistingMatchingCard(Qued.SpecialFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,min,max) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function Qued.SpecialOperation(c,id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local min, max = getLvBetween(c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp, Qued.SpecialFilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, min, max)
		if #g<=0 or Duel.GetLocationCountFromEx(tp)==0 then return end
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCondition(Qued.descon(tc,id,fid))
			e1:SetOperation(Qued.desop(tc))
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function Qued.descon(tc,id,fid)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if tc:GetFlagEffectLabel(id)~=fid then
			e:Reset()
			return false
		else return true end
	end
end
function Qued.desop(tc)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--operation for azegahl
function Qued.Azegahl(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	for tc in aux.Next(g) do
		if tc:IsRace(RACE_ZOMBIE) and tc:IsSetCard(0xf2) then 
			if tc:GetFlagEffect(CARD_AZEGAHL)>0 then return end
			local effs={tc:GetCardEffect()}
			for _,eff in ipairs(effs) do
				if eff:GetLabel()==CARD_AZEGAHL then
					--apply cloned effect in mzone
					local ex=eff:Clone()
					ex:SetLabel(CARD_AZEGAHL*2)
					ex:SetRange(LOCATION_MZONE)
					ex:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(ex)
					tc:RegisterFlagEffect(CARD_AZEGAHL,RESET_EVENT+RESETS_STANDARD,0,1)
					tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(CARD_AZEGAHL,1))
				end
			end
		end
	end
	if c:GetFlagEffect(CARD_AZEGAHL)==0 then
		local le=Effect.CreateEffect(c)
		le:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		le:SetCode(EVENT_LEAVE_FIELD)
		le:SetOperation(Qued.resetop)
		le:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE)
		c:RegisterEffect(le,true)
		c:RegisterFlagEffect(CARD_AZEGAHL,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function Qued.resfilter(c)
	return c:GetFlagEffect(CARD_AZEGAHL)>0
end
function Qued.resetop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Qued.resfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if #g<=0 then return end
	for tc in aux.Next(g) do
		local effs={tc:GetCardEffect()}
		for _,eff in ipairs(effs) do
			--reset each apply effect
			if eff:GetLabel()==(CARD_AZEGAHL*2) then
				eff:Reset()
			end
		end
		--reset flag of card
		tc:ResetFlagEffect(CARD_AZEGAHL)
		--reset hint msg
		tc:ResetFlagEffect(0)
	end
end


--[[ Blood Omen Functions ]]--
--Add monster attributes to spell/trap cards at all times
function Qued.AddAttributes(c,spell)
	local card=c:GetMetatable()
	local atts={cset=0xd3d,ctpe=0x21,catk=1300,cdef=0,clvl=3,crac=RACE_ZOMBIE,catt=ATTRIBUTE_DARK}
	if card.atts then
		for att,_ in pairs(atts) do
			if card.atts[att] then
				atts[att]=card.atts[att]
			end
		end
	end
	if not card.flag then
		card.flag={}
		card.flag[0]=0
	end
	--become monster
	local me1=Effect.CreateEffect(c)
	me1:SetType(EFFECT_TYPE_SINGLE)
	me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	me1:SetCode(EFFECT_ADD_TYPE)
	me1:SetRange(LOCATION_GRAVE)
	me1:SetCondition(function (e) return card.flag[0]==1 end)
	me1:SetValue(atts.ctpe)
	c:RegisterEffect(me1)
	local me2=me1:Clone()
	me2:SetCode(EFFECT_REMOVE_TYPE)
	if spell then
		me2:SetValue(TYPE_BLOOD_SPELL)
	else
		me2:SetValue(TYPE_BLOOD_TRAP)
	end
	c:RegisterEffect(me2)
	local me3=me1:Clone()
	me3:SetCode(EFFECT_SET_ATTACK_FINAL)
	me3:SetValue(atts.catk)
	c:RegisterEffect(me3)
	local me4=me1:Clone()
	me4:SetCode(EFFECT_SET_DEFENSE_FINAL)
	me4:SetValue(atts.cdef)
	c:RegisterEffect(me4)
	local me5=me1:Clone()
	me5:SetCode(EFFECT_ADD_RACE)
	me5:SetValue(atts.crac)
	c:RegisterEffect(me5)
	local me6=me1:Clone()
	me6:SetCode(EFFECT_CHANGE_LEVEL)
	me6:SetValue(atts.clvl)
	c:RegisterEffect(me6)
	local me7=me1:Clone()
	me7:SetCode(EFFECT_ADD_ATTRIBUTE)
	me7:SetValue(atts.catt)
	c:RegisterEffect(me7)
	--reset flag
	local me8=Effect.CreateEffect(c)
	me8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	me8:SetCode(EVENT_LEAVE_FIELD)
	me8:SetRange(LOCATION_GRAVE)
	me8:SetOperation(Qued.resetflag)
	c:RegisterEffect(me8)
	local me9=me8:Clone()
	me9:SetCode(EVENT_LEAVE_FIELD)
	c:RegisterEffect(me9)
end
function Qued.resetflag(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local card=c:GetMetatable(c)
	if c:GetPreviousLocation()==LOCATION_GRAVE and not c:GetDestination()==LOCATION_MZONE then
		card.flag[0]=0
	end
	if c:GetPreviousLocation()==LOCATION_MZONE and not c:GetDestination()==LOCATION_GRAVE then
		card.flag[0]=0
	end
end

--custom pendulum from gy proc
function Qued.AddPendyProcedure(c,reg,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1074)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCost(Qued.PendyCost)
	e1:SetCondition(Qued.PendyCondition())
	e1:SetOperation(Qued.PendyOperation())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	--register by default
	-- if reg==nil or reg then
	-- 	local e2=Effect.CreateEffect(c)
	-- 	e2:SetDescription(1160)
	-- 	e2:SetType(EFFECT_TYPE_ACTIVATE)
	-- 	e2:SetCode(EVENT_FREE_CHAIN)
	-- 	e2:SetRange(LOCATION_HAND)
	-- 	c:RegisterEffect(e2)
	-- end
end
function Qued.PendyCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local id=e:GetHandler():GetCode()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(Qued.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function Qued.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xd3d)
end
function Qued.PendyFilter(c,e,tp,lscale,rscale,lvchk)
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return c:IsSetCard(0xd3d) and selfCode(c) 
		and (lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) 
			and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false) and not c:IsForbidden()
end
function Qued.PendyCondition()
	return function(e,c,og)
		if c==nil then return true end
		local tp=c:GetControler()
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,10000000)>0 then return false end
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return false end
		if og then
			return og:Filter(Card.IsLocation,nil,LOCATION_GRAVE):IsExists(Qued.PendyFilter,1,nil,e,tp,lscale,rscale)
		else
			return Duel.IsExistingMatchingCard(Qued.PendyFilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lscale,rscale)
		end
	end
end
function Qued.PendyOperation()
	return function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
		if og then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=og:Filter(Card.IsLocation,nil,LOCATION_GRAVE):FilterSelect(tp,Qued.PendyFilter,0,ft,nil,e,tp,lscale,rscale)
			if g then
				sg:Merge(g)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,Qued.PendyFilter,tp,LOCATION_GRAVE,0,0,ft,nil,e,tp,lscale,rscale)
			if g then
				sg:Merge(g)
			end
		end
		if #sg<=0 then return end
		local id=c:GetCode()
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		Duel.HintSelection(c,true)
		Duel.HintSelection(rpz,true)
		for tc in sg:Iter() do
	        if tc:IsSetCard(0xd3d) and selfCode(tc) then
	            addMonAtt(tc)
	            Duel.SpecialSummonStep(tc,SUMMON_TYPE_PENDULUM,tp,tp,true,false,POS_FACEUP)
	            tc:AddMonsterAttributeComplete()
	        end
        end
        Duel.SpecialSummonComplete()
	end
end

--The Common Spell Counter
function Qued.AddSpellCounter(c,id)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,Qued.spellfilter)
end
function Qued.spellfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xd3d))
end

--Custom Blood Omen Link Proc
--sp_ct - number of spells required for summon
function Qued.AddLinkProc(c,id,sp_ct)
	--spell count
	Qued.AddSpellCounter(c,id)
	--unsummonable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(function () return not aux.lnklimit(e,se,sp,st) end)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(1)
	e2:SetCondition(Qued.LinkCon(id,sp_ct))
	e2:SetOperation(Qued.LinkOp(sp_ct))
	c:RegisterEffect(e2)
end
function Qued.LinkCon(id,sp_ct)
	return function (e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		local spct=Duel.GetFlagEffectLabel(tp,CARD_ILILIA)
		local acct=Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)
		return acct>=sp_ct and (not spct or acct-spct>=sp_ct) and Duel.GetLocationCountFromEx(tp)>0
	end
end
function Qued.LinkOp(sp_ct)
	return function (e,tp,eg,ep,ev,re,r,rp)
		--flag label for acc count
		Duel.RegisterFlagEffect(tp,CARD_ILILIA,RESET_PHASE+PHASE_END,0,0,sp_ct)
	end
end

--Some Helper Functions for Blood Omen Lyria
function Qued.CheckChain(ct,tp)
	local i,flag=0,false
	while flag==false and i~=ct do
		local ce,cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local rc=ce:GetHandler()
		if rc and rc:IsType(TYPE_MONSTER) and Duel.IsChainNegatable(i) 
			and (not rc:IsSetCard(0xd3d) or cp~=tp) then flag=true end
		i=i+1
	end
	return flag
end
--returns chain table 'ch_t' with the chain link number before the chain's effect object
--returns chain group the cards from the chain
function Qued.chainfilter(c,cp,tp)
	return c:IsType(TYPE_MONSTER) and (not c:IsSetCard(0xd3d) or cp~=tp)
end
function Qued.GetChainLinkInfo(ct,tp)
	local cg=Group.CreateGroup()
	local ch_t={}
	for i=1,ct do
		local ce,cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local rc=ce:GetHandler()
		if rc and Qued.chainfilter(rc,cp,tp) then
			if not ch_t[rc] then
				ch_t[rc]={i,ce}
			elseif ch_t[rc] then
				table.insert(ch_t[rc],i)
				table.insert(ch_t[rc],ce)
			end
			cg:AddCard(rc)
		end
	end
	if #cg<=0 then return nil, nil end
	return ch_t,cg
end
strings_table={4000,4001,4002,4003,4004}
--returns the chain link no. selected...hopefully with message
function Qued.GetChainLinkid(ch_t,nc,tp)
	local op=nil
	local ChainTable=ch_t[nc]
	if not ch_t or not ChainTable then
		return op
	end
	if #ChainTable>2 then
		local str={}
		local i=2
		while i>1 do
			if ChainTable[i]:GetDescription()==0 then
				table.insert(str,strings_table[(i>>1)])
			else
				table.insert(str,ChainTable[i]:GetDescription())
			end
			if not ChainTable[i+2] then i=1 else i=i+2 end
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CHAINNO)
		op=Duel.SelectOption(tp,table.unpack(str))
		Duel.Hint(HINT_OPSELECTED,1-tp,strings_table[op+1])
		op=ChainTable[(op+1)+op]
	else
		op=ChainTable[1]
	end
	return op
end