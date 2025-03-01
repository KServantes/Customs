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

SET_BLOOD_OMEN = 0xd3d
SET_BLOOD = 0xd3e

TYPE_BLOOD_SPELL=TYPE_QUICKPLAY|TYPE_SPELL
TYPE_BLOOD_TRAP=TYPE_COUNTER|TYPE_TRAP
TYPE_EFFECT_MON=TYPE_EFFECT|TYPE_MONSTER
TYPE_TUNER_MON=TYPE_EFFECT_MON|TYPE_TUNER


--[[ Rewrites and Custom Functions ]]---
local card_can_special, card_can_be_fusion_mat, duel_special_summon, card_get_code = 
	Card.IsCanBeSpecialSummoned, Card.IsCanBeFusionMaterial, Duel.SpecialSummon, Card.GetCode

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
local function printHex(decn)
	return string.format('%x',decn)
end
--card with self flag
local function metaFlag(c)
	return c.flag==1
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
    if c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_BLOOD_OMEN) and metaFlag(c) then
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
        local bg
        local sumct=0
        bg=sg:Filter(Qued.bofilter,nil)
        if #bg==0 then goto summon end
        for sc in bg:Iter() do
            addMonAtt(sc)
            Duel.SpecialSummonStep(sc,sumtype,sumplayer,tg_player,true,nolim,pos,table.unpack(options))
            sc:AddMonsterAttributeComplete()
            sumct=sumct+1
            sg:RemoveCard(sc)
        end
        Duel.SpecialSummonComplete()
        if #bg>0 and sg==0 then return sumct end
        ::summon::
        return duel_special_summon(sg,sumtype,sumplayer,tg_player,nochk,nolim,pos,table.unpack(options)) + sumct
    end
end
Card.IsCanBeFusionMaterial=function(c,fuscard,ign_mon)
	if c:IsSetCard(SET_BLOOD_OMEN) and metaFlag(c) then
		return true
	end
	return card_can_be_fusion_mat(c,fuscard,ign_mon)
end
Card.GetCode=function(c)
	if c.extra_codes then
		local ct={}
		for code,_ in pairs(c.extra_codes) do
			table.insert(ct,code)
		end
		return table.unpack(ct)
	end
	return card_get_code(c)
end
Card.IsSetCardExtra=function(c,codes)
	local ct={codes}
	local sets={}
	if #ct==1 then
		table.insert(sets,Duel.GetCardSetcodeFromCode(ct[1]))
	end
	if #ct>1 then
		for _,code in pairs(ct) do
			table.insert(sets,Duel.GetCardSetcodeFromCode(code))
		end
	end
	if #sets==0 then return false end
	return c:IsSetCard(sets)
end

function Qued.bofilter(c)
	return c:IsSetCard(SET_BLOOD_OMEN) and metaFlag(c)
end

--fun table
Qued.funTable=function(...)
    local t={...}
    t.count=function()
        local ct=0
        for _,v in pairs(t) do
            if type(v)~='function' then
                ct=ct+1
            end
        end
        return ct
    end
    t.clear=function()
        for k,v in pairs(t) do
            if type(v)~='function' then
                t[k]=nil
            end
        end
    end
    t.merge=function(self,ot)
        for k,v in pairs(ot) do
            self[k]=v
        end
    end
    return t
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
	return lv>=min and lv<=max and c:GetType()&(TYPE_FUSION|TYPE_NORMAL)==(TYPE_NORMAL|TYPE_FUSION)
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
		le:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		le:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		le:SetCode(EVENT_LEAVE_FIELD)
		le:SetOperation(Qued.resetop)
		-- le:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE)
		c:RegisterEffect(le,true)
		c:RegisterFlagEffect(CARD_AZEGAHL,RESET_EVENT+RESET_TOFIELD|RESET_LEAVE,0,1)
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

--Custom Ritual Target and Operation (Kansallor)
local function reg_forced_select(forcedselection)
	local prev_repl_function=nil
	for tmp_c in extra_eff_g:Iter() do
		local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
		for _,eff in ipairs(effs) do
			local repl_function=eff:GetLabelObject()
			if repl_function and prev_repl_function~=repl_function[1] then
				prev_repl_function=repl_function[1]
				if not forcedselection then
					forcedselection=repl_function[1]
				elseif forcedselection~=repl_function[1] then
					forcedselection=(function()
						local oldfunc=forcedselection
						return function(e,tp,sg,sc)
							local ret1,ret2=oldfunc(e,tp,sg,sc)
							local repl1,repl2=repl_function[1](e,tp,sg,sc)
							return ret1 and repl1,ret2 or repl2
						end
					end)()
				end
			end
		end
	end
	return forcedselection
end
local function WrapTableReturn(func)
	return function(...)
		return {func(...)}
	end
end
function Qued.RitualTargetK(filter,_type,lv,extrafil,matfilter,location,forcedselection)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			local mg=Duel.GetRitualMaterial(tp)
			local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
			--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
			--add that forcedselection to the one of the Ritual Spell, if any
			local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
			if #extra_eff_g>0 then forcedselection=reg_forced_select(forcedselection) end
			Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
			return Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,nil,filter,_type,e,tp,mg,mg2,forcedselection,nil,lv,nil,POS_FACEUP)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_PZONE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
end
function Qued.RitualOperationK(filter,_type,lv,extrafil,matfilter,location,forcedselection)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp)
		--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
		--add that forcedselection to the one of the Ritual Spell, if any
		local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
		if #extra_eff_g>0 then forcedselection=reg_forced_select(forcedselection) end
		Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local tc=e:GetHandler()
		local lv=(lv and (type(lv)=="function" and lv(tc)) or lv) or tc:GetLevel()
		lv=math.max(1,lv)
		Ritual.SummoningLevel=lv
		local mat=nil
		mg:Match(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2-tc)
		local func=forcedselection and WrapTableReturn(forcedselection) or nil
		if ft>0 and not func then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			if _type==RITPROC_EQUAL then
				mat=mg:SelectWithSumEqual(tp,requirementfunc or Card.GetRitualLevel,lv,1,#mg,tc)
			else
				mat=mg:SelectWithSumGreater(tp,requirementfunc or Card.GetRitualLevel,lv,tc)
			end
		else
			mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(tc,lv,func,_type,requirementfunc),1,tp,HINTMSG_RELEASE,Ritual.Finishcon(tc,lv,requirementfunc,_type))
		end
		--check if a card from an "once per turn" EFFECT_EXTRA_RITUAL_MATERIAL effect was selected
		local extra_eff_g=mat:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
		for tmp_c in extra_eff_g:Iter() do
			local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
			for _,eff in ipairs(effs) do
				--if eff is OPT and tmp_c is not returned
				--by the Ritual Spell's exrafil
				--then use the count limit and register
				--the flag to turn the extra eff OFF
				--requires the EFFECT_EXTRA_RITUAL_MATERIAL effect
				--to check the flag in its condition
				local _,max_count_limit=eff:GetCountLimit()
				if max_count_limit>0 and not mg2:IsContains(tmp_c) then
					eff:UseCountLimit(tp,1)
					Duel.RegisterFlagEffect(tp,eff:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1)
				end
			end
		end
		tc:SetMaterial(mat)
		Duel.SendtoGrave(mat:Clone(),REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
		Ritual.SummoningLevel=nil
	end
end

--[[ Blood Omen Functions ]]--
--Add monster attributes to spell/trap cards at all times
function Qued.AddAttributes(c,spell)
	local card=c:GetMetatable()
	local atts={cset=SET_BLOOD_OMEN,ctpe=0x21,catk=1300,cdef=0,clvl=3,crac=RACE_ZOMBIE,catt=ATTRIBUTE_DARK}

	-- reg permatypes
	if card.atts then
		if not card.flag then
			for att,_ in pairs(atts) do
				if card.atts[att] then
					atts[att]=card.atts[att]
					card.atts = atts
				end
			end
		end
	else
		card.atts = atts
	end

	--active flag
	if not card.flag then
		card.flag=0
	end
	--become monster
	local me1=Effect.CreateEffect(c)
	me1:SetType(EFFECT_TYPE_SINGLE)
	me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	me1:SetCode(EFFECT_CHANGE_TYPE)
	me1:SetRange(LOCATION_GRAVE|LOCATION_SZONE)
	me1:SetCondition(function (e) return e:GetHandler().flag==1 end)
	me1:SetValue(atts.ctpe)
	c:RegisterEffect(me1)
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
	me8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	me8:SetCode(EVENT_LEAVE_FIELD_P)
	me8:SetOperation(Qued.resetflag1)
	Duel.RegisterEffect(me8,0)
	local me9=me8:Clone()
	me9:SetCode(EVENT_LEAVE_GRAVE)
	me9:SetOperation(Qued.resetflag2)
	Duel.RegisterEffect(me9,0)
end
function Qued.resetflag1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if #eg>1 or eg:GetFirst()~=c then return end
	local card=c:GetMetatable(c)
	if c:GetLocation()&LOCATION_MZONE~=0 and c:GetDestination()&LOCATION_GRAVE==0 then
		card.flag=nil
		e:Reset()
	end
end
function Qued.resetflag2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if #eg>1 or eg:GetFirst()~=c then return end
	local card=c:GetMetatable(c)
	if c:GetPreviousLocation()&LOCATION_GRAVE~=0 and c:GetLocation()&LOCATION_MZONE==0 then
		card.flag=nil
		e:Reset()
	end
end

--The Common Spell Counter
function Qued.AddSpellCounter(c,id)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,Qued.spellfilter)
end
function Qued.spellfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(SET_BLOOD_OMEN))
end

--default spell/trap card activations
--special summon
function Qued.BloodOmenSpellActivate(c,id)
	local card=c:GetMetatable()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Qued.BloodTarget(id,card))
	e1:SetOperation(Qued.BloodOperation(id,card))
	c:RegisterEffect(e1)
end

function Qued.BloodTarget(id,card)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local att = card.atts
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,att.cset,att.ctpe,att.catk,att.cdef,att.clvl,att.crace,att.catt) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_BLOOD_OMEN,0,0)
		card.flag=1
	end
end
function Qued.BloodOperation(id,card)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local att = card.atts
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,att.cset,att.ctype,att.catk,att.cdef,att.clvl,att.crace,att.catt) then
			addMonAtt(c)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
			c:AddMonsterAttributeComplete()
		end
		Duel.SpecialSummonComplete()
	end
end

--Cannot be used for Summon, except xyz
function Qued.UseOnlyAsXyzMat(c,lv,filter)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(function (e,c)
		if not c then return false end
		return not filter
	end)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_XYZ_LEVEL)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(lv)
	c:RegisterEffect(e7)
end

--Shuffle after detach
function Qued.ShuffleAfterDetach(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
    e1:SetTarget(function (_,tc) return tc==c end)
    e1:SetValue(LOCATION_DECK)
    Duel.RegisterEffect(e1,0)
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
	return not c:IsSetCard(SET_BLOOD_OMEN)
end
function Qued.PendyFilter(c,e,tp,lscale,rscale,lvchk)
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return c:IsSetCard(SET_BLOOD_OMEN) and metaFlag(c) 
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
	        if tc:IsSetCard(SET_BLOOD_OMEN) and metaFlag(tc) then
	            addMonAtt(tc)
	            Duel.SpecialSummonStep(tc,SUMMON_TYPE_PENDULUM,tp,tp,true,false,POS_FACEUP)
	            tc:AddMonsterAttributeComplete()
	        end
        end
        Duel.SpecialSummonComplete()
	end
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
function Qued.CheckChain(c,tp,ev)
    local st=c:GetMetatable().st
    for i=1,ev do
        local ce,cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
        local rc=ce:GetHandler()
        if rc and Duel.IsChainNegatable(i) then
            --our cards
            if cp==tp and rc:IsSetCard(SET_BLOOD_OMEN) then
                if not st.sc[rc] then st.sc[rc]=true end
            end
            --opponent's cards
            if cp~=tp and rc:IsType(TYPE_MONSTER) then  
                if not st.oc[rc] then st.oc[rc]=true end
            end
        end
    end
    local res=st.sc.count()>=1 and st.oc.count()>0
    st.sc.clear()
    st.oc.clear()

    return res
end
--returns chain table 'ch_t' with the chain link number before the chain's effect object
--returns chain group the cards from the chain
function Qued.chainfilter(c,cp,tp)
	return c:IsType(TYPE_MONSTER) and (not c:IsSetCard(SET_BLOOD_OMEN) or cp~=tp)
end
function Qued.GetChainTableAndGroup(ct,tp)
	local cg=Group.CreateGroup()
	local ch_t={}
	for i=1,ct do
		local ce,cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local rc=ce:GetHandler()
		if rc and Qued.chainfilter(rc,cp,tp) then
			if not ch_t[rc] then
				ch_t[rc]=Qued.funTable(i,ce)
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
function Qued.GetChainToNegateFromTable(ch_t,tp)
	local op=nil
	local ChainTable=ch_t
	if ChainTable.count()>2 then
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

--"This card gains the names of its Synchro Materials used for its Synchro Summon."
--
function Qued.RegisterExtraCodes(c,id)
	local card=c:GetMetatable()
	if card.extra_codes==nil then card.extra_codes={} end
	if card.extra_codes[id]==nil then card.extra_codes[id]=true end
	--Gain names
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(function (e) return e:GetHandler():GetSummonType()&SUMMON_TYPE_SYNCHRO~=0 end)
	e0:SetOperation(Qued.CodeRegOp(card))
	c:RegisterEffect(e0)
	--if leaves field for any other reason
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0b:SetCode(EVENT_LEAVE_FIELD_P)
	e0b:SetOperation(Qued.CodeResetOp(card))
	c:RegisterEffect(e0b)
end

function Qued.CodeRegOp(card)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local g=c:GetMaterial()
		local extra_code_table=c.extra_codes
		if c:IsFacedown() or #g<=0 then return end
		for tc in g:Iter() do
			local codes={tc:GetCode()}
			if #codes>1 then
				--register multiple codes
				for i,codx in ipairs(codes) do
					extra_code_table[codx]=true
				end

				if tc.extra_codes then
					--reset passed down codes
					local tmt=tc:GetMetatable()
					tmt.extra_codes={[tc:GetOriginalCode()]=true}
				end
			else
				--register single code
				extra_code_table[tc:GetCode()]=true
			end
		end
	end
end

function Qued.CodeResetOp(card)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local rc=re:GetHandler()
		if r&(REASON_SYNCHRO+REASON_MATERIAL)~=0 
			and (rc:GetType()&TYPE_SYNCHRO)~=0 then return end
		--on leaving field for other reason reset
		card.extra_codes={[c:GetOriginalCode()]=true}
	end
end