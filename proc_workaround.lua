--Utilities to be added to the core

--[[
	If called while an effect isn't resolving (e.g. a regular Xyz Summon or through an effect like "Wonder Xyz") then proceed as usual with the attaching.
	If called while an effect is resolving treat it as attaching by card effect and handle the relevant rulings.
	Attaching by card effect is ruled to affect both the Xyz Monster and the cards that are to be attached.
	Return early if the Xyz Monster is unaffected by the currently resolving effect.
	Remove any cards that are unaffected by the currently resolving effect from the group of cards to be attached.
	If all the cards to be attached are unaffected by the currently resolving effect then return early.
	Proceed as usual with the attaching otherwise.
Duel.Overlay=(function()
	local oldfunc=Duel.Overlay
	return function(xyz_monster,xyz_mats,send_to_grave)
		if not Duel.IsChainSolving() then return oldfunc(xyz_monster,xyz_mats,send_to_grave) end
		local trig_eff=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT)
		if xyz_monster:IsImmuneToEffect(trig_eff) then return end
		if type(xyz_mats)=="Group" then
			xyz_mats:Match(aux.NOT(Card.IsImmuneToEffect),nil,trig_eff)
			if #xyz_mats==0 then return end
		elseif type(xyz_mats)=="Card" and xyz_mats:IsImmuneToEffect(trig_eff) then
			return
		end
		return oldfunc(xyz_monster,xyz_mats,send_to_grave)
	end
end)()
--]]

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
	local rg,rgex=Duel.GetReleaseGroup(tp,false):Match(aux.TRUE,ex):Split(fil,nil,table.unpack(params))
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
	local rg,rgex=Duel.GetReleaseGroup(tp,false):Match(aux.TRUE,ex):Split(fil,nil,...)
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
function Auxiliary.ReleaseCheckSingleUse(sg,tp,exg)
	local ct=#sg-#(sg-exg)
	return ct<=1,ct>1
end
function Auxiliary.ReleaseCheckMMZ(sg,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		or sg:IsExists(aux.FilterBoolFunction(Card.IsInMainMZone,tp),1,nil)
end
function Auxiliary.ReleaseCheckTarget(sg,tp,exg,dg)
	return dg:IsExists(aux.TRUE,1,sg)
end
function Auxiliary.RelCheckRecursive(c,tp,sg,mg,exg,mustg,ct,minc,maxc,specialchk)
	sg:AddCard(c)
	ct=ct+1
	local res,stop=Auxiliary.RelCheckGoal(tp,sg,exg,mustg,ct,minc,maxc,specialchk)
	if not res and not stop then
		res=(ct<maxc and mg:IsExists(Auxiliary.RelCheckRecursive,1,sg,tp,sg,mg,exg,mustg,ct,minc,maxc,specialchk))
	end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.RelCheckGoal(tp,sg,exg,mustg,ct,minc,maxc,specialchk)
	if ct<minc or ct>maxc then return false,ct>maxc end
	local res,stop=specialchk(sg)
	return (res and sg:Includes(mustg)),stop
end
function Auxiliary.ReleaseCostFilter(c,tp)
	local eff=c:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM)
	return not (c:IsControler(1-tp) and eff and eff:CheckCountLimit(tp)) and not c:IsHasEffect(EFFECT_EXTRA_RELEASE)
end
function Auxiliary.MakeSpecialCheck(check,tp,exg,...)
	local params={...}
	if not check then return
		function(sg)
			return Auxiliary.ReleaseCheckSingleUse(sg,tp,exg)
		end
	end
	return function(sg)
		local res,stop=check(sg,tp,exg,table.unpack(params))
		local res2,stop2=Auxiliary.ReleaseCheckSingleUse(sg,tp,exg)
		return res and res2,stop or stop2
	end
end
function Duel.CheckReleaseGroupCost(tp,f,minc,maxc,use_hand,check,ex,...)
	local params={...}
	if type(maxc)~="number" then
		table.insert(params,1,ex)
		maxc,use_hand,check,ex=minc,maxc,use_hand,check
	end
	if not ex then ex=Group.CreateGroup() end
	local mg=Duel.GetReleaseGroup(tp,use_hand):Match(f or aux.TRUE,ex,table.unpack(params))
	local g,exg=mg:Split(Auxiliary.ReleaseCostFilter,nil,tp)
	local specialchk=Auxiliary.MakeSpecialCheck(check,tp,exg,table.unpack(params))
	local mustg=g:Match(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local sg=Group.CreateGroup()
	return mg:Includes(mustg) and mg:IsExists(Auxiliary.RelCheckRecursive,1,nil,tp,sg,mg,exg,mustg,0,minc,maxc,specialchk)
end
function Duel.SelectReleaseGroupCost(tp,f,minc,maxc,use_hand,check,ex,...)
	if not ex then ex=Group.CreateGroup() end
	local mg=Duel.GetReleaseGroup(tp,use_hand):Match(f or aux.TRUE,ex,...)
	local g,exg=mg:Split(Auxiliary.ReleaseCostFilter,nil,tp)
	local specialchk=Auxiliary.MakeSpecialCheck(check,tp,exg,...)
	local mustg=g:Match(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local sg=Group.CreateGroup()
	local cancel=false
	sg:Merge(mustg)
	while #sg<maxc do
		local cg=mg:Filter(Auxiliary.RelCheckRecursive,sg,tp,sg,mg,exg,mustg,#sg,minc,maxc,specialchk)
		if #cg==0 then break end
		cancel=Auxiliary.RelCheckGoal(tp,sg,exg,mustg,#sg,minc,maxc,specialchk)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
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
	if  #(sg&exg)>0 then
		local eff=(sg&exg):GetFirst():IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM)
		if eff then
			eff:UseCountLimit(tp,1)
			Duel.Hint(HINT_CARD,0,eff:GetHandler():GetCode())
		end
	end
	return sg
end
