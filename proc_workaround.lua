--Utilities to be added to the core
function Card.IsInMainMZone(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and (not tp or c:IsControler(tp))
end
function Card.IsInExtraMZone(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>4 and (not tp or c:IsControler(tp))
end
function Card.IsNonEffectMonster(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT)
end
function Card.IsMonster(c)
	return c:IsType(TYPE_MONSTER)
end
function Auxiliary.ReleaseNonSumCheck(c,tp,e)
	if c:IsControler(tp) then return false end
	local chk=false
	for _,eff in ipairs({c:GetCardEffect(EFFECT_EXTRA_RELEASE_NONSUM)}) do
		local val=eff:GetValue()
		if type(val)=="number" then chk=val~=0
		else chk=val(eff,e,REASON_COST,tp) end
		if chk then return true end
	end
	return chk
end
function Auxiliary.ZoneCheckFunc(c,tp,zone)
	if c:IsLocation(LOCATION_EXTRA) then
		return function(sg) return Duel.GetLocationCountFromEx(tp,tp,sg,c) end
	end
	return function(sg) return Duel.GetMZoneCount(tp,sg,zone) end
end
function Auxiliary.CheckZonesReleaseSummonCheck(must,oneof,checkfunc)
	return function(sg,e,tp,mg)
		local count=#(oneof&sg)
		return checkfunc(sg+must)>0 and count<2,count>=2
	end
end
function Duel.CheckReleaseGroupSummon(c,tp,e,fil,minc,maxc,last,...)
	local zone=0xff
	local params={...}
	local ex=last
	if type(last)=="number" then
		zone=last
		ex=params[1]
		table.remove(params,1)
	end
	local checkfunc=aux.ZoneCheckFunc(c,tp,zone)
	local rg,rgex=Duel.GetReleaseGroup(tp,false):Filter(aux.TRUE,ex):Split(fil,nil,table.unpack(params))
	if #rg<minc or rgex:IsExists(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local must,nonmust=rg:Split(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE)
	local mustc=#must
	if mustc>maxc then return false end
	if (mustc-minc>=0) and checkfunc(must)>0 then return true end
	local extraoneof,nonmust=nonmust:Split(aux.ReleaseNonSumCheck,nil,tp,e)
	local count=mustc+#nonmust+(#extraoneof>0 and 1 or 0)
	return count>=minc and aux.SelectUnselectGroup(nonmust,e,tp,minc-mustc,maxc-mustc,aux.CheckZonesReleaseSummonCheck(must,extraoneof,checkfunc),0)
end
function Auxiliary.CheckZonesReleaseSummonCheckSelection(must,oneof,checkfunc)
	return function(sg,e,tp,mg)
		local count=#(oneof&sg)
		return sg:Includes(must) and checkfunc(sg)>0 and count<2,count>=2
	end
end
function Duel.SelectReleaseGroupSummon(c,tp,e,fil,minc,maxc,last,...)
	local cancelable=false
	local zone=0xff
	local ex=last
	local params={...}
	if type(last)=="boolean" then
		cancelable=last
		zone=params[1]
		table.remove(params,1)
		ex=params[1]
		table.remove(params,1)
	end
	local checkfunc=aux.ZoneCheckFunc(c,tp,zone)
	local rg,rgex=Duel.GetReleaseGroup(tp,false):Filter(aux.TRUE,ex):Split(fil,nil,...)
	if #rg<minc or rgex:IsExists(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE) then return nil end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local must,nonmust=rg:Split(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE)
	local mustc=#must
	if mustc>maxc then return nil end
	if (mustc-maxc>=0) and checkfunc(must)>0 then return must:Select(tp,mustc,mustc,true) end
	local extraoneof,nonmust=nonmust:Split(aux.ReleaseNonSumCheck,nil,tp,e)
	local count=mustc+#nonmust+(#extraoneof>0 and 1 or 0)
	local res=count>=minc and aux.SelectUnselectGroup(rg,e,tp,minc,maxc,aux.CheckZonesReleaseSummonCheckSelection(must,extraoneof,checkfunc),1,tp,500,function(sg,e,tp,g) return sg:Includes(must) and Duel.GetMZoneCount(tp,sg,zone)>0 end,nil,cancelable)
	return #res>0 and res or nil
end
--Lair of Darkness
function Auxiliary.ReleaseCostFilter(c,f,...)
	return c:IsFaceup() and c:IsReleasable() and c:IsHasEffect(59160188) 
		and (not f or f(c,table.unpack({...})))
end
function Auxiliary.ReleaseCheckSingleUse(sg,tp,exg)
	return #sg-#(sg-exg)<=1
end
function Auxiliary.ReleaseCheckMMZ(sg,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		or sg:IsExists(aux.FilterBoolFunction(Card.IsInMainMZone,tp),1,nil)
end
function Auxiliary.ReleaseCheckTarget(sg,tp,exg,dg)
	return dg:IsExists(aux.TRUE,1,sg)
end
function Auxiliary.RelCheckRecursive(c,tp,sg,mg,exg,mustg,ct,minc,specialchk,...)
	sg:AddCard(c)
	ct=ct+1
	local res=Auxiliary.RelCheckGoal(tp,sg,exg,mustg,ct,minc,specialchk,table.unpack({...})) 
		or (ct<minc and mg:IsExists(Auxiliary.RelCheckRecursive,1,sg,tp,sg,mg,exg,mustg,ct,minc,specialchk,table.unpack({...})))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.RelCheckGoal(tp,sg,exg,mustg,ct,minc,specialchk,...)
	return ct>=minc and (not specialchk or specialchk(sg,tp,exg,table.unpack({...}))) and sg:Includes(mustg)
end
function Duel.CheckReleaseGroupCost(tp,f,ct,use_hand,specialchk,ex,...)
	local params={...}
	if not ex then ex=Group.CreateGroup() end
	if not specialchk then specialchk=Auxiliary.ReleaseCheckSingleUse else specialchk=Auxiliary.AND(specialchk,Auxiliary.ReleaseCheckSingleUse) end
	local g=Duel.GetReleaseGroup(tp,use_hand)
	if f then
		g=g:Filter(f,ex,table.unpack(params))
	else
		g=g-ex
	end
	local exg=Duel.GetMatchingGroup(Auxiliary.ReleaseCostFilter,tp,0,LOCATION_MZONE,g+ex,f,table.unpack(params))
	local mustg=g:Filter(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local mg=g+exg
	local sg=Group.CreateGroup()
	return mg:Includes(mustg) and mg:IsExists(Auxiliary.RelCheckRecursive,1,nil,tp,sg,mg,exg,mustg,0,ct,specialchk,table.unpack({...}))
end
function Duel.SelectReleaseGroupCost(tp,f,minc,maxc,use_hand,specialchk,ex,...)
	local params={...}
	if not ex then ex=Group.CreateGroup() end
	if not specialchk then specialchk=Auxiliary.ReleaseCheckSingleUse else specialchk=Auxiliary.AND(specialchk,Auxiliary.ReleaseCheckSingleUse) end
	local g=Duel.GetReleaseGroup(tp,use_hand)
	if f then
		g=g:Filter(f,ex,table.unpack(params))
	else
		g=g-ex
	end
	local exg=Duel.GetMatchingGroup(Auxiliary.ReleaseCostFilter,tp,0,LOCATION_MZONE,g+ex,f,table.unpack(params))
	local mg=g+exg
	local mustg=g:Filter(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local sg=Group.CreateGroup()
	local cancel=false
	sg:Merge(mustg)
	while #sg<maxc do
		local cg=mg:Filter(Auxiliary.RelCheckRecursive,sg,tp,sg,mg,exg,mustg,#sg,minc,specialchk,table.unpack({...}))
		if #cg==0 then break end
		cancel=#sg>=minc and #sg<=maxc and Auxiliary.RelCheckGoal(tp,sg,exg,mustg,#sg,minc,specialchk,table.unpack({...}))
		local tc=Group.SelectUnselect(cg,sg,tp,cancel,cancel,1,1)
		if not tc then break end
		if #mustg==0 or not mustg:IsContains(tc) then
			if not sg:IsContains(tc) then
				sg=sg+tc
			else
				sg=sg-tc
			end
		end
	end
	if #sg==0 then return sg end
	if #sg~=#(sg-exg) then
		--LoD is reset for the rest of the turn
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		Duel.Hint(HINT_CARD,0,fc:GetCode())
		fc:RegisterFlagEffect(59160188,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
	return sg
end
function Card.IsRitualMonster(c)
	local tp=TYPE_RITUAL+TYPE_MONSTER
	return c:GetType() & tp == tp
end
function Card.IsRitualSpell(c)
	local tp=TYPE_RITUAL+TYPE_SPELL
	return c:GetType() & tp == tp
end
function Card.IsLinkMonster(c)
	local tp=TYPE_LINK+TYPE_MONSTER
	return c:GetType() & tp == tp
end
function Card.IsLinkSpell(c)
	local tp=TYPE_LINK+TYPE_SPELL
	return c:GetType() & tp == tp
end
function Card.IsOriginalCode(c,cd)
	return c:GetOriginalCode()==cd
end
function Card.IsOriginalCodeRule(c,cd)
	local c1,c2=c:GetOriginalCodeRule()
	return c1==cd or c2==cd
end
function Card.IsOriginalType(c,val)
	return c:GetOriginalType() & val == val
end
function Card.IsOriginalAttribute(c,val)
	return c:GetOriginalAttribute() & val == val
end
function Card.IsOriginalRace(c,val)
	return c:GetOriginalRace() & val == val
end
function Card.IsSummonPlayer(c,tp)
	return c:GetSummonPlayer()==tp
end
function Card.IsPreviousControler(c,tp)
	return c:GetPreviousControler()==tp
end

--Checks wheter a card has a level or not
--For Links: false. For Xyzs: false, except if affected by  "EFFECT_RANK_LEVEL..." effects
--For Dark Synchros: true, because they have a negative level. For level 0: true, because 0 is a value
function Card.HasLevel(c)
	return c:GetType()&TYPE_LINK~=TYPE_LINK 
		and (c:GetType()&TYPE_XYZ~=TYPE_XYZ and not (c:IsHasEffect(EFFECT_RANK_LEVEL) or c:IsHasEffect(EFFECT_RANK_LEVEL_S)))
		and not c:IsStatus(STATUS_NO_LEVEL)
end
function Card.IsSummonLocation(c,loc)
	return c:GetSummonLocation()&loc~=0
end
function Duel.GetTargetCards(e)
	return Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
end
--Checks whether the card is located at any of the sequences passed as arguments.
function Card.IsSequence(c,...)
	local arg={...}
	local seq=c:GetSequence()
	for _,v in ipairs(arg) do
		if seq==v then return true end
	end
	return false
end
--for zone checking (zone is the zone, tp is referencial player)
function Auxiliary.IsZone(c,zone,tp)
	local rzone = c:IsControler(tp) and (1 <<c:GetSequence()) or (1 << (16+c:GetSequence()))
	if c:IsSequence(5,6) then
		rzone = rzone | (c:IsControler(tp) and (1 << (16 + 11 - c:GetSequence())) or (1 << (11 - c:GetSequence())))
	end
	return (rzone & zone) > 0
end
--Helpers to print hints for attribute-related cards such as Cynet Codec
function Auxiliary.BitSplit(v)
	local res={}
	local i=0
	while 2^i<=v do
		local p=2^i
		if v & p~=0 then 
			table.insert(res,p)
		end
		i=i+1
	end
	return pairs(res)
end
function Auxiliary.GetAttributeStrings(v)
	local t = {
		[ATTRIBUTE_EARTH] = 1010,
		[ATTRIBUTE_WATER] = 1011,
		[ATTRIBUTE_FIRE] = 1012,
		[ATTRIBUTE_WIND] = 1013,
		[ATTRIBUTE_LIGHT] = 1014,
		[ATTRIBUTE_DARK] = 1015,
		[ATTRIBUTE_DIVINE] = 1016
	}
	local res={}
	local ct=0
	for _,att in Auxiliary.BitSplit(v) do
		if t[att] then
			table.insert(res,t[att])
			ct=ct+1
		end
	end
	return pairs(res)
end
function Auxiliary.GetRaceStrings(v)
	local t = {
		[RACE_WARRIOR] = 1020,
		[RACE_SPELLCASTER] = 1021,
		[RACE_FAIRY] = 1022,
		[RACE_FIEND] = 1023,
		[RACE_ZOMBIE] = 1024,
		[RACE_MACHINE] = 1025,
		[RACE_AQUA] = 1026,
		[RACE_PYRO] = 1027,
		[RACE_ROCK] = 1028,
		[RACE_WINGEDBEAST] = 1029,
		[RACE_PLANT] = 1030,
		[RACE_INSECT] = 1031,
		[RACE_THUNDER] = 1032,
		[RACE_DRAGON] = 1033,
		[RACE_BEAST] = 1034,
		[RACE_BEASTWARRIOR] = 1035,
		[RACE_DINOSAUR] = 1036,
		[RACE_FISH] = 1037,
		[RACE_SEASERPENT] = 1038,
		[RACE_REPTILE] = 1039,
		[RACE_PSYCHIC] = 1040,
		[RACE_DIVINE] = 1041,
		[RACE_CREATORGOD] = 1042,
		[RACE_WYRM] = 1043,
		[RACE_CYBERSE] = 1044
	}
	local res={}
	local ct=0
	for _,att in Auxiliary.BitSplit(v) do
		if t[att] then
			table.insert(res,t[att])
			ct=ct+1
		end
	end
	return pairs(res)
end
