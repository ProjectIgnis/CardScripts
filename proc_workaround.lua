--Utilities to be added to the core

--[[
	If a monster in the Monster Zone is flipped face-down and back up again it shouldn't be treated as a monster that was Summoned that turn
--]]
do
	local function summon_status_filter(c)
		return c:IsFacedown() and c:IsPreviousPosition(POS_FACEUP) and c:IsLocation(LOCATION_MZONE) and c:IsStatus(STATUS_SUMMON_TURN|STATUS_FLIP_SUMMON_TURN|STATUS_SPSUMMON_TURN)
	end

	--Manually set the summon turn statuses to 'false' when a monster is flipped face-down
	local sum_status_eff=Effect.GlobalEffect()
	sum_status_eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	sum_status_eff:SetCode(EVENT_CHANGE_POS)
	sum_status_eff:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				local g=eg:Filter(summon_status_filter,nil)
				for c in g:Iter() do
					c:SetStatus(STATUS_SUMMON_TURN,false)
					c:SetStatus(STATUS_FLIP_SUMMON_TURN,false)
					c:SetStatus(STATUS_SPSUMMON_TURN,false)
					--need to set it to 'true' otherwise it can change its position or be Flip Summoned even though it was Summoned that same turn
					--(probably cuz it's tied to the summon turn statuses)
					c:SetStatus(STATUS_FORM_CHANGED,true)
				end
			end)
	Duel.RegisterEffect(sum_status_eff,0)
end

--[[
	Phase and step functions
	If the optional 'player' parameter is provided it will also check that it's that player's turn
--]]
local function make_base_phase_function(phase)
	return function(player)
		return Duel.GetCurrentPhase()==phase and (player==nil or Duel.IsTurnPlayer(player))
	end
end

Duel.IsDrawPhase=make_base_phase_function(PHASE_DRAW)

Duel.IsStandbyPhase=make_base_phase_function(PHASE_STANDBY)

Duel.IsMainPhase1=make_base_phase_function(PHASE_MAIN1)

Duel.IsStartOfBattlePhase=make_base_phase_function(PHASE_BATTLE_START)
Duel.IsStartStep=Duel.IsStartOfBattlePhase

Duel.IsBattleStep=make_base_phase_function(PHASE_BATTLE_STEP)

Duel.IsDamageCalculation=make_base_phase_function(PHASE_DAMAGE_CAL)

Duel.IsEndOfBattlePhase=make_base_phase_function(PHASE_BATTLE)
Duel.IsEndStep=Duel.IsEndOfBattlePhase

Duel.IsMainPhase2=make_base_phase_function(PHASE_MAIN2)

Duel.IsEndPhase=make_base_phase_function(PHASE_END)

function Duel.IsMainPhase(player)
	local current_phase=Duel.GetCurrentPhase()
	return (current_phase==PHASE_MAIN1 or current_phase==PHASE_MAIN2) and (player==nil or Duel.IsTurnPlayer(player))
end

function Duel.IsBattlePhase(player)
	local current_phase=Duel.GetCurrentPhase()
	return current_phase>=PHASE_BATTLE_START and current_phase<=PHASE_BATTLE and (player==nil or Duel.IsTurnPlayer(player))
end

function Duel.IsDamageStep(player)
	local current_phase=Duel.GetCurrentPhase()
	return (current_phase==PHASE_DAMAGE or current_phase==PHASE_DAMAGE_CAL) and (player==nil or Duel.IsTurnPlayer(player))
end

--[[
	Automatically shuffle a player's hand when the effect of a card that they activated in the hand begins resolving, but only if that same card is still in the hand on resolution
	Fixes cases such as the "Enneacraft" monsters where the opponent shouldn't know if the player Special Summoned the monster whose effect was activated or not
--]]
do
	local function check_opinfo(ev,category,rc)
		local ex,tg=Duel.GetOperationInfo(ev,category)
		local possible_ex,possible_tg=Duel.GetPossibleOperationInfo(ev,category)
		return (ex and tg and tg:IsContains(rc)) or (possible_ex and possible_tg and possible_tg:IsContains(rc))
	end

	--to keep track of a player whose hand has already been shuffled earlier during the current Chain
	local player_table={}
	player_table[0]=false
	player_table[1]=false

	--shuffle the player's hand at the beginning of an effect's resolution if all the checks are passed
	local shuffle_eff=Effect.GlobalEffect()
	shuffle_eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	shuffle_eff:SetCode(EVENT_CHAIN_SOLVING)
	shuffle_eff:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
					if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)~=LOCATION_HAND then return end
					local rc=re:GetHandler()
					local player=rc:GetControler()
					--if this player's hand was already shuffled earlier in this Chain then don't shuffle it again
					if player_table[player] then return end
					--if it's not the same card in the hand anymore then don't shuffle
					if not (rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_HAND)) then return end
					--if there's opinfo that would (even potentially) move rc then don't shuffle, e.g. the "Subterror Behemoth" monsters
					if check_opinfo(ev,CATEGORY_SPECIAL_SUMMON,rc) then return end
					if check_opinfo(ev,CATEGORY_SUMMON,rc) then return end
					if check_opinfo(ev,CATEGORY_TOGRAVE,rc) then return end
					if check_opinfo(ev,CATEGORY_DESTROY,rc) then return end
					if check_opinfo(ev,CATEGORY_REMOVE,rc) then return end
					if check_opinfo(ev,CATEGORY_TODECK,rc) then return end
					if check_opinfo(ev,CATEGORY_TOEXTRA,rc) then return end
					if check_opinfo(ev,CATEGORY_EQUIP,rc) then return end
					if check_opinfo(ev,CATEGORY_RELEASE,rc) then return end
					--otherwise, shuffle
					Duel.ShuffleHand(player)
					
					--if the activating card itself ends up moving then shuffle the hand after the current Chain Link finishes resolving
					--this will make it so it matches the behaviour of the core which automatically shuffles the hand if the activating card is still there at the end of the resolution
					local move_eff=Effect.CreateEffect(rc)
					move_eff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
					move_eff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					move_eff:SetCode(EVENT_MOVE)
					move_eff:SetOperation(function()
								local eff=Effect.CreateEffect(rc)
								eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
								eff:SetCode(EVENT_CHAIN_SOLVED)
								eff:SetOperation(function() Duel.ShuffleHand(player) eff:Reset() end)
								eff:SetReset(RESET_CHAIN)
								Duel.RegisterEffect(eff,player)
								--
								move_eff:Reset()
							end)
					move_eff:SetReset(RESET_CHAIN)
					rc:RegisterEffect(move_eff)
					
					player_table[player]=true
				end)
	Duel.RegisterEffect(shuffle_eff,0)

	--reset the player tracking at the end of each Chain
	local tracking_eff=Effect.GlobalEffect()
	tracking_eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	tracking_eff:SetCode(EVENT_CHAIN_END)
	tracking_eff:SetOperation(function()
					player_table[0]=false
					player_table[1]=false
				end)
	Duel.RegisterEffect(tracking_eff,0)
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
		- Card.IsSummonPhase: Returns 'true' or 'false' depending on the passed phase
		- Card.IsSummonPhaseMain: Returns 'true' if the card was summoned during the Main Phase (1 or 2)
		- Card.IsSummonPhaseBattle: Returns 'true' if the card was summoned during the Battle Phase
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
	return c:GetSummonPhase()==phase
end
function Card.IsSummonPhaseMain(c)
	local summon_phase=c:GetSummonPhase()
	return summon_phase==PHASE_MAIN1 or summon_phase==PHASE_MAIN2
end
function Card.IsSummonPhaseBattle(c)
	local summon_phase=c:GetSummonPhase()
	return summon_phase>=PHASE_BATTLE_START and summon_phase<=PHASE_BATTLE
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
