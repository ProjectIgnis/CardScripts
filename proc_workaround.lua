--Utilities to be added to the core

--[[
	Automatically shuffle a player's hand when the effect of a card that they activated in the hand begins resolving, but only if that same card is still in the hand on resolution
	Fixes cases such as the "Enneacraft" monsters where the opponent shouldn't know if the player Special Summoned the monster whose effect was activated or not
--]]
do
	local shuffle_eff=Effect.GlobalEffect()
	shuffle_eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	shuffle_eff:SetCode(EVENT_CHAIN_SOLVING)
	shuffle_eff:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
					if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)~=LOCATION_HAND then return end
					local rc=re:GetHandler()
					if rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_HAND) then
						Duel.ShuffleHand(rc:GetControler())
					end
				end)
	Duel.RegisterEffect(shuffle_eff,0)
end

--[[
	Have all the effects that grant an additional Tribute Summon share "Card Advance" as the flag effect's ID
	If "Duel.RegisterEffect" detects such an effect is being registered then it'll automatically register said flag effect as well
--]]
function Duel.IsPlayerCanAdditionalTributeSummon(player)
	return not Duel.HasFlagEffect(player,CARD_CARD_ADVANCE)
end
Duel.RegisterEffect=(function()
	local oldfunc=Duel.RegisterEffect
	return function(effect,player,...)
		if effect:GetCode()==EFFECT_EXTRA_SUMMON_COUNT and effect:GetValue()==0x1 then
			local reset,reset_count=effect:GetReset()
			Duel.RegisterFlagEffect(player,CARD_CARD_ADVANCE,reset,0,reset_count)
		end
		oldfunc(effect,player,...)
	end
end)()

--[[
	Registers a flag effect on each monster that is Normal or Special Summoned, with the current phase being the flag effect's label
	The flag will reset if the monster stops being face-up in the Monster Zone
	Intended to be used with Rush cards like "Wicked Dragon of Darkness" [160214042] that require having been Normal/Special Summoned during a specific phase
	If the monster is Summoned again (e.g. a Gemini Monster) the previous value will be overwritten (could be improved by adding such handling but it's not needed for Rush anyways)
	
	Also added basic "get" and "is" functions:
		- Card.GetSummonPhase: Returns the flag effect's label, or 0 if the flag effect doesn't exist
		- Card.IsSummonPhase: Returns 'true' or 'false' depending on the passed phase, use 'PHASE_MAIN' to check for the Main Phase and 'PHASE_BATTLE' to check for the Battle Phase (any other phase has no special handling and is checked as is)
--]]
do
	--Store each monster's summon phase
	local ns_eff=Effect.GlobalEffect()
	ns_eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ns_eff:SetCode(EVENT_SUMMON_SUCCESS)
	ns_eff:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				for sc in eg:Iter() do
					--"Wicked Dragon of Darkness"
					sc:RegisterFlagEffect(160214042,RESET_EVENT|RESETS_STANDARD,0,1,Duel.GetCurrentPhase())
				end
			end)
	Duel.RegisterEffect(ns_eff,0)
	local sp_eff=ns_eff:Clone()
	sp_eff:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(sp_eff,0)
end
function Card.GetSummonPhase(c)
	--same ID as above
	return c:HasFlagEffect(160214042) and c:GetFlagEffectLabel(160214042) or 0
end
function Card.IsSummonPhase(c,phase)
	if phase==PHASE_MAIN then
		return c:GetSummonPhase()==PHASE_MAIN1 or c:GetSummonPhase()==PHASE_MAIN2
	elseif phase==PHASE_BATTLE then
		return c:GetSummonPhase()>=PHASE_BATTLE_START and c:GetSummonPhase()<=PHASE_BATTLE
	else
		return c:GetSummonPhase()==phase
	end
end

--[[
	Raise "EVENT_MOVE" when a card(s) is attached as Xyz Material
	Fixes "Guiding Quem, the Virtuous" [45883110] and "Despian Luluwalilith" [53971455] not triggering if a card is attached directly from the Extra Deck
--]]
Duel.Overlay=(function()
	local oldfunc=Duel.Overlay
	return function(xyz_monster,xyz_mats,send_to_grave)
		local eg=xyz_mats
		local re=nil
		local r=REASON_RULE
		local rp=PLAYER_NONE
		local core_reason_effect=Duel.GetReasonEffect()
		if Duel.IsChainSolving() or (core_reason_effect and not core_reason_effect:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE)) then
			re=Duel.GetReasonEffect()
			r=REASON_EFFECT
			rp=Duel.GetReasonPlayer()
		end
		if not send_to_grave then
			if type(xyz_mats)=="Card" then
				eg=eg+xyz_mats:GetOverlayGroup()
			elseif type(xyz_mats)=="Group" then
				for c in xyz_mats:Iter() do
					eg=eg+c:GetOverlayGroup()
				end
			end
		end
		local res=oldfunc(xyz_monster,xyz_mats,send_to_grave)
		Duel.RaiseEvent(eg,EVENT_MOVE,re,r,rp,0,0)
		return res
	end
end)()

--[[
	Return false by default if the card to attach and the Xyz Monster to attach the card to are the same card
--]]
Card.IsCanBeXyzMaterial=(function()
	local oldfunc=Card.IsCanBeXyzMaterial
	return function(card,xyz_monster,player,reason)
		if xyz_monster and card==xyz_monster then
			return false
		end
		player=player or Duel.GetReasonPlayer()
		reason=reason or REASON_XYZ|REASON_MATERIAL
		return oldfunc(card,xyz_monster,player,reason)
	end
end)()

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
	return Duel.GetMZoneCount(tp,sg)>0
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
