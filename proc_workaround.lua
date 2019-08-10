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
function Card.IsOriginalCode(c,cd)
	return c:GetOriginalCode()==cd
end
function Card.IsOriginalCodeRule(c,cd)
    local c1,c2=c:GetOriginalCodeRule()
    return c1==cd or c2==cd
end
function Card.IsSummonPlayer(c,tp)
	return c:GetSummonPlayer()==tp
end
function Card.IsPreviousControler(c,tp)
	return c:GetPreviousControler()==tp
end
function Card.IsHasLevel(c)
	return c:GetLevel()>0
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
	return (rzone & zone) > 0
end
--Workaround for the Link Summon using opponent's monsters effect of the Hakai monsters
function Auxiliary.HakaiLinkFilter(c,e,tp,f,of)
	if not of(c) then return false end
	return Duel.IsExistingMatchingCard(Auxiliary.HakaiLinkSummonFilter(f),tp,LOCATION_EXTRA,0,1,nil,e:GetHandler(),c,tp)
end
function Auxiliary.HakaiLinkSummonFilter(f)
	return	function(c,mc,tc,tp)
				if not (c:IsType(TYPE_LINK) and c:IsLinkAbove(2)) then return false end
				if Duel.GetLocationCountFromEx(tp,tp,mc,c)<1 then return false end
				if f and not f(c) then return false end
				return mc:IsCanBeLinkMaterial(c,tp) and tc:IsCanBeLinkMaterial(c,tp) and c:IsSpecialSummonable(SUMMON_TYPE_LINK)
			end
end
function Auxiliary.HakaiLinkExtra(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if not summon_type==SUMMON_TYPE_LINK then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	end
end
function Auxiliary.HakaiLinkTarget(f,of)
	if not of then of=Card.IsFaceup else of=aux.FilterFaceupFunction(of) end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local c=e:GetHandler()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetTarget(function(e,c) return c~=e:GetHandler() end)
				e1:SetValue(1)
				Duel.RegisterEffect(e1,tp)
				local og=Duel.GetMatchingGroup(of,tp,0,LOCATION_MZONE,nil)
				local oeff={}
				for oc in aux.Next(og) do
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_FIELD)
					e2:SetRange(LOCATION_MZONE)
					e2:SetCode(EFFECT_EXTRA_MATERIAL)
					e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e2:SetTargetRange(1,0)
					e2:SetValue(Auxiliary.HakaiLinkExtra)
					oc:RegisterEffect(e2)
					local reg = oc:RegisterEffect(e2,true)
					table.insert(oeff,e2)
				end
				if chkc then
					local b=chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and Auxiliary.HakaiLinkFilter(chkc,e,tp,f,of)
					e1:Reset()
					for _,oe in ipairs(oeff) do
						if reg then
							oe:Reset()
						end
					end
					return b
				end
				if chk==0 then
					local b=Duel.IsExistingTarget(Auxiliary.HakaiLinkFilter,tp,0,LOCATION_MZONE,1,nil,e,tp,f,of)
					e1:Reset()
					for _,oe in ipairs(oeff) do
						oe:Reset()
					end
					return b
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
				Duel.SelectTarget(tp,Auxiliary.HakaiLinkFilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp,f,of)
				e1:Reset()
				for _,oe in ipairs(oeff) do
					oe:Reset()
				end
			end
end
function Auxiliary.HakaiLinkOperation(f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local tc=Duel.GetFirstTarget()
				if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)) then return end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetTarget(function(e,c) return c~=e:GetHandler() end)
				e1:SetValue(1)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetRange(LOCATION_MZONE)
				e2:SetCode(EFFECT_EXTRA_MATERIAL)
				e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e2:SetTargetRange(1,0)
				e2:SetValue(Auxiliary.HakaiLinkExtra)
				local reg = tc:RegisterEffect(e2,true)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,Auxiliary.HakaiLinkSummonFilter(f),tp,LOCATION_EXTRA,0,1,1,nil,c,tc,tp)
				if #g>0 then
					Duel.SpecialSummonRule(tp,g:GetFirst(),SUMMON_TYPE_LINK)
				end
				e1:Reset()
				if reg then
					e2:Reset()
				end
			end
end
function Effect.AddHakaiLinkEffect(e,f,of)
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e:SetTarget(Auxiliary.HakaiLinkTarget(f,of))
	e:SetOperation(Auxiliary.HakaiLinkOperation(f))
end

--Helpers to print hints for attribute-related cards such as Cynet Codec
function Auxiliary.BitSplit(v)
	local res={}
	local i=0
	while math.pow(2,i)<=v do
		local p=math.pow(2,i)
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
		[ATTRIBUTE_DEVINE] = 1016
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
		[RACE_WINDBEAST] = 1029,
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
		[RACE_PSYCHO] = 1040,
		[RACE_DEVINE] = 1041,
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
