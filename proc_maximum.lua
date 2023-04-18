--constants
-- TYPE_MAXIMUM=0x8000
-- SUMMON_TYPE_MAXIMUM = 0x4e000000 --to check if it is correct
FLAG_MAXIMUM_CENTER=170000000 --flag for center card maximum mode
FLAG_MAXIMUM_SIDE=170000001 --flag for Left/right maximum card
FLAG_MAXIMUM_CENTER_PREONFIELD=170000002 --those two flag are used to check is the card was a maximum monster while on the field (handling to improve later)
FLAG_MAXIMUM_SIDE_PREONFIELD=170000004 
if not aux.MaximumProcedure then
	aux.MaximumProcedure = {}
	Maximum = aux.MaximumProcedure
end
if not Maximum then
	Maximum = aux.MaximumProcedure
end
function Debug.AddMaximumCard(player,center,left,right)
	local c=Debug.AddCard(center,player,player,LOCATION_MZONE,2,POS_FACEUP_ATTACK,true)
	c:RegisterFlagEffect(FLAG_MAXIMUM_CENTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	c:RegisterFlagEffect(FLAG_MAXIMUM_CENTER_PREONFIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)

	local l=Debug.AddCard(left,player,player,LOCATION_MZONE,1,POS_FACEUP_ATTACK,true)
	local r=Debug.AddCard(right,player,player,LOCATION_MZONE,3,POS_FACEUP_ATTACK,true)
	--side
	for _,tc in ipairs({l,r}) do
		tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)
	end
end
--Maximum Summon
function Maximum.AddProcedure(c,desc,...)
	local mats={...}
	c:GetMetatable().MaximumSet=mats
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1079) --to update, it is the pendulum value. 179 seem free?
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Maximum.Condition(mats))
	e1:SetOperation(Maximum.Operation(mats))
	e1:SetValue(SUMMON_TYPE_MAXIMUM)
	c:RegisterEffect(e1)
	--cannot be changed to def
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetCondition(Maximum.centerCon)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	e2:SetCondition(Maximum.centerCon)
	c:RegisterEffect(e2)
	--tribute handler
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(0xff)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetCondition(Maximum.tribcon)
	e3:SetOperation(Maximum.tribop)
	c:RegisterEffect(e3)
	--leave
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(0xff)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1)
	e4:SetCondition(Maximum.battlecon)
	e4:SetOperation(Maximum.battleop)
	c:RegisterEffect(e4)
	--makes so it virtually cannot have any DEF
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	e5:SetValue(-1000000)
	c:RegisterEffect(e5)
end
--that function check if you can maximum summon the monster and its other part(s)
function Maximum.Condition(mats)
	local ct=#mats
	return function(e,c,og)
		if c==nil then return true end
		local tp=c:GetControler()
		if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_MAXIMUM,tp,false,false,POS_FACEUP_ATTACK) then return false end
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,LOCATION_HAND)
		else
			g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		end
		return Duel.GetMZoneCount(tp,Duel.GetFieldGroup(tp,LOCATION_MZONE,0))>=3 and aux.SelectUnselectGroup(g,e,tp,ct,ct,Maximum.spcheck(mats),0)
	end
end
function Maximum.spcheck(filters)
	return function(sg,e,tp,mg)
		for _,filter in ipairs(filters) do
			if not sg:IsExists(filter,1,nil) then return false end
		end
		return true
	end
end
--operation that do the maximum summon
function Maximum.Operation(mats)
	local ct=#mats
	return function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
		if c==nil then return true end
		local tp=c:GetControler()
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,LOCATION_HAND)
		else
			g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		end
		--select side monsters
		local tg=aux.SelectUnselectGroup(g,e,tp,ct,ct,Maximum.spcheck(mats),1,tp,HINTMSG_SPSUMMON,nil,nil,true)
		if #tg==0 then return end
		--adding the "maximum mode" flag
		--center
		c:RegisterFlagEffect(FLAG_MAXIMUM_CENTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		c:RegisterFlagEffect(FLAG_MAXIMUM_CENTER_PREONFIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)
		
		--side
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
			tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)
		end
		sg:Merge((tg+c))
		g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
function Maximum.centerCon(e)
	return e:GetHandler():IsMaximumModeCenter()
end


--function that return if the card is in Maximum Mode or not, atm it just return true as we are lacking info on how Maximum mode work
function Card.IsMaximumMode(c)
	return c:IsMaximumModeCenter() or c:IsMaximumModeSide()
end
function Card.IsMaximumModeCenter(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_CENTER)
end
function Card.IsMaximumModeLeft(c)
	local m=c:GetMetatable(true)
	if not m then return false end
	return m.MaximumSide=="Left"
end
function Card.IsMaximumModeRight(c)
	local m=c:GetMetatable(true)
	if not m then return false end
	return m.MaximumSide=="Right"
end
function Card.IsMaximumModeSide(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_SIDE)
end
function Card.IsNotMaximumModeSide(c)
	return not c:HasFlagEffect(FLAG_MAXIMUM_SIDE)
end
function Card.WasMaximumModeSide(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD)
end
function Card.WasMaximumMode(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD) or c:HasFlagEffect(FLAG_MAXIMUM_CENTER_PREONFIELD)
end
--I used Gemini as a reference for that function, while waiting for more information
function Auxiliary.IsMaximumMode(effect)
	local c=effect:GetHandler()
	return not c:IsDisabled() and c:IsMaximumMode()
end
--that function add the effect that change the Original atk of the Maximum monster
function Card.AddMaximumAtkHandler(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(aux.IsMaximumMode)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaximumAttack())
	c:RegisterEffect(e1)
end
--function that return the value of the "maximum atk" of the monster
function Card.GetMaximumAttack(c)
	local m=c:GetMetatable(true)
	if not m then return false end
	return m.MaximumAttack
end
--function that provide effects of the center piece to the side (mainly used for protection effects)
function Card.AddCenterToSideEffectHandler(c,eff)
	--grant effect to center
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(Maximum.centerCon)
	e1:SetTarget(Maximum.eftg)
	e1:SetLabelObject(eff)
	c:RegisterEffect(e1)
end
function Maximum.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsMaximumModeSide()
end
function Maximum.centerCon(e)
	return e:GetHandler():IsMaximumModeCenter()
end
--function to add everything related to Left/Right Maximum Monster behaviour
--c=card to register
--tc=center maximum card
function Card.AddSideMaximumHandler(c,eff)
	--change atk
	local baseeff=Effect.CreateEffect(c)
	baseeff:SetType(EFFECT_TYPE_SINGLE)
	baseeff:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	baseeff:SetRange(LOCATION_MZONE)
	baseeff:SetCondition(Maximum.sideCon)
	
	local e1=baseeff:Clone()
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(Maximum.maxCenterVal(Card.GetMaximumAttack))
	c:RegisterEffect(e1)

	local e0=baseeff:Clone()
	e0:SetCode(EFFECT_SET_ATTACK_FINAL)
	e0:SetValue(Maximum.maxCenterVal(Card.GetAttack))
	c:RegisterEffect(e0)
	
	--change level
	local e2=baseeff:Clone()
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(Maximum.maxCenterVal(Card.GetLevel))
	c:RegisterEffect(e2)
	--change name
	local e3=baseeff:Clone()
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetValue(Maximum.maxCenterVal(Card.GetCode))
	c:RegisterEffect(e3)
	--change Race
	local e4=baseeff:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(Maximum.maxCenterVal(Card.GetRace))
	c:RegisterEffect(e4)
	--change attribute
	local e5=baseeff:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(Maximum.maxCenterVal(Card.GetAttribute))
	c:RegisterEffect(e5)
	--grant effect to center
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetCondition(Maximum.sideCon)
	e6:SetTarget(Maximum.eftgMax)
	e6:SetLabelObject(eff)
	c:RegisterEffect(e6)
	
	--cannot be battle target
	local e7=baseeff:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	
	--cannot be changed to def
	local e8=baseeff:Clone()
	e8:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e8)
	local e8=baseeff:Clone()
	e8:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	c:RegisterEffect(e8)
	
	--cannot be tributed for a tribute summon
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetCode(EFFECT_UNRELEASABLE_SUM)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e10:SetCondition(Maximum.sideCon)
	e10:SetValue(1)
	c:RegisterEffect(e10)
	--cannot declare attack
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_CANNOT_ATTACK)
	e11:SetCondition(Maximum.sideCon)
	c:RegisterEffect(e11)

	--cannot activate effect if side piece
	local e12=baseeff:Clone()
	e12:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e12)

	baseeff:Reset()
end
function Maximum.GetMaximumCenter(tp)
	return Duel.GetMatchingGroup(Card.IsMaximumModeCenter,tp,LOCATION_MZONE,0,nil):GetFirst()
end
function Maximum.maxCenterVal(f)
	return function(e,c)
		local tc=Maximum.GetMaximumCenter(e:GetHandlerPlayer())
		return tc and f(tc)
	end
end
function Maximum.eftgMax(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsMaximumMode() and c~=e:GetHandler()
end
function Maximum.sideCon(e)
	local tc=Maximum.GetMaximumCenter(e:GetHandlerPlayer())
	return tc and e:GetHandler():IsMaximumModeSide()
end
function Maximum.sideConGrant(e)
	local tc=Maximum.GetMaximumCenter(e:GetHandlerPlayer())
	return tc and e:GetHandler():IsMaximumModeSide()
end
--function that return false if the monster don't have defense stats
--wait for ruling
function Card.HasDefense(c)
	return not (c:IsType(TYPE_LINK) or (c:IsType(TYPE_MAXIMUM) and c:IsMaximumMode()))
end

--functions to handle counting monsters but without the side Maximum monsters (the L/R max monsters are subtracted from the count)
function Duel.GetMatchingGroupCountRush(f,tp,LOCP1,LOCP2,exclude,...)
	local maxi=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunction(f,...),tp,LOCP1,LOCP2,exclude)
	return Duel.GetMatchingGroupCount(f,tp,LOCP1,LOCP2,exclude,...)-maxi
end
--function that return only the side monsters
function Auxiliary.FilterMaximumSideFunction(f,...)
	local params={...}
	return function(target)
				return target:IsMaximumModeSide() and f(target,table.unpack(params))
			end
end
--function that exclude L/R Maximum Mode
function Auxiliary.FilterMaximumSideFunctionEx(f,...)
	local params={...}
	return function(target)
				return
				((not target:IsMaximumMode()) or (not (target:IsMaximumMode() and not target:IsMaximumModeCenter())))
				and f(target,table.unpack(params))
			end
end
--function used only in Duel.GetFieldGroupCountRush because the old implementation did not want to work
function Maximum.GroupCountFunction(c)
	return ((not c:IsMaximumMode()) or (not (c:IsMaximumMode() and not c:IsMaximumModeCenter()))) 
end
-- function that return the count of a location P1 et P2 minus the Maximum Side
function Duel.GetFieldGroupCountRush(player, p1, p2)
	return Duel.GetMatchingGroupCount(Maximum.GroupCountFunction,player,p1,p2,nil)
end
--Function that returns the same as GetMatchingGroup, but removes L/R Maximum mode monsters from the group
function Duel.GetMatchingGroupRush(f,player,loc1,loc2,exc,...)
	return Duel.GetMatchingGroup(Auxiliary.FilterMaximumSideFunctionEx(f,...),player,loc1,loc2,exc)
end
--function that add every parts of the Maximum Mode monster to the group
function Group.AddMaximumCheck(group)
	local g=group:Clone()
	for tc in aux.Next(group) do
		if tc:IsMaximumMode() then
			local g2=Duel.GetMatchingGroup(Card.IsMaximumMode,tc:GetControler(),LOCATION_MZONE,0,tc)
			g:Merge(g2)
		end
	end
	return g
end
--function used to register an effect on all part of a Maximum monster instead of just a part (for ex, if you want to update the atk, you use that effect to register the EFFECT_UPDATE_ATTACK to the 3 part of the monster)
function Card.RegisterEffectRush(c,eff)
	if c:IsMaximumMode() then
		local g=Duel.GetMatchingGroup(Card.IsMaximumMode,c:GetControler(),LOCATION_MZONE,0,nil)
		for tc in aux.Next(g) do
			local eff2=eff:Clone()
			tc:RegisterEffect(eff2)
		end
	else
		c:RegisterEffect(eff)
	end
end
-- summon only in attack
local function summon_pos_target(e,c)
	return c:IsSummonType(SUMMON_TYPE_MAXIMUM) and c:IsLocation(LOCATION_HAND)
end
local function initial_effect()
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(summon_pos_target)
	e1:SetValue(POS_FACEUP_ATTACK)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FORCE_MZONE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetTarget(summon_pos_target)
	e2:SetValue(function(e,c)
					if c:IsMaximumModeCenter() then
						return 0x4
					elseif c:IsMaximumModeLeft() then
						return 0x2
					else return 0x8
					end
				end)
	Duel.RegisterEffect(e2,0)
end
initial_effect()



-- handling for tribute summon
function Maximum.cfilter(c,tp)
	return c:IsReason(REASON_SUMMON) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:WasMaximumMode()
end
function Maximum.tribcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Maximum.cfilter,1,nil,tp)
end
function Maximum.tribop(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	local g=Duel.GetMatchingGroup(Card.IsMaximumMode,c:GetControler(),LOCATION_MZONE,0,nil)
	Duel.Sendto(g,c:GetDestination(),0)
	for tc in aux.Next(g) do
		tc:SetReason(c:GetReason())
	end
end
--handling for battle destruction
function Maximum.battlecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) and eg:IsExists(Card.IsControler,1,nil,tp)
end
function Maximum.battleop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMaximumMode,e:GetHandler():GetPreviousControler(),LOCATION_MZONE,0,nil)
	Duel.Sendto(g,e:GetHandler():GetDestination(),0)
	for tc in aux.Next(g) do
		tc:SetReason(eg:GetFirst():GetReason())
	end
end
if Duel.IsDuelType(DUEL_INVERTED_QUICK_PRIORITY) then
	--Traps cannot be chained to each other
	local traprush1=Effect.GlobalEffect()
	traprush1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	traprush1:SetCode(EVENT_CHAINING)
	traprush1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
							local rc=re:GetHandler()
							if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) then
								Duel.SetChainLimit(aux.FALSE)
							end
						end)
	Duel.RegisterEffect(traprush1,0)
	--Traps cannot miss timing and can be activated in the Damage Step
	local traprush2=Effect.GlobalEffect()
	traprush2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	traprush2:SetCode(EVENT_STARTUP)
	traprush2:SetOperation(function()
							local g=Duel.GetMatchingGroup(Card.IsTrap,0,0xffffff,0xffffff,nil)
							for tc in g:Iter() do
								local effs={tc:GetActivateEffect()}
								for _,eff in ipairs(effs) do
									local prop1,prop2=eff:GetProperty()
									eff:SetProperty(prop1|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP,prop2)
								end
							end
						end)
	Duel.RegisterEffect(traprush2,0)
end
function Card.IsCanChangePositionRush(c)
	return c:IsCanChangePosition() and not c:IsMaximumMode()
end

--Add function to simplify some effect

--c: the card gaining effect
--reset: when the effect should disappear 
--rc: the card giving effect
--condition: condition for the effect to be "active"
--properties: properties beside EFFECT_FLAG_CLIENT_HINT
function Card.AddPiercing(c,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3208)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function Card.AddDirectAttack(c,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3205)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
--attack each monster once each
function Card.AddAdditionalAttackOnMonsterAll(c,reset,rc,value,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	--Attack all
	e1:SetDescription(3215)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	if value then e1:SetValue(value) end
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function Card.AddAdditionalAttack(c,atknum,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	if atknum==1 then e1:SetDescription(3201) end
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(atknum)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function Card.AddAdditionalAttackOnMonster(c,atknum,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	if atknum==1 then e1:SetDescription(3202) end
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(atknum)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
--ctype: card type that cannot destroy
function Card.AddCannotBeDestroyedEffect(c,ctype,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	if ctype==TYPE_MONSTER then e1:SetDescription(3068)
	elseif ctype==TYPE_SPELL then e1:SetDescription(3069)
	elseif ctype==TYPE_TRAP then e1:SetDescription(3070)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetValue(aux.indesfilter)
	e1:SetLabel(ctype)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function aux.indesfilter(e,te)
	local ctype=e:GetLabel()
	return te:IsActiveType(ctype) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function Card.AddCannotBeDestroyedBattle(c,reset,value,rc,condition,properties)
	--Cannot be destroyed battle
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3000)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	if value then e1:SetValue(value) else e1:SetValue(1) end
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffect(e1)
end

--Rush cost utilities
-- p: player that mill
-- num: number of card send from the top to the gy
-- reason: reason of the mill (REASON_EFFECT or REASON_COST)
function aux.DeckMill(p,num,reason)
	if Duel.DiscardDeck(p,num,reason)<num then return false else return true end 
end



--Double tribute handler
FLAG_TRIPLE_TRIBUTE=160012000
FLAG_NO_TRIBUTE=160001029
FLAG_DOUBLE_TRIB=160009052 --Executie up
FLAG_DOUBLE_TRIB_DRAGON=160402002 --righteous dragon
FLAG_DOUBLE_TRIB_FIRE=160007025 --dododo second
FLAG_DOUBLE_TRIB_WINGEDBEAST=160005033 --blasting bird
FLAG_DOUBLE_TRIB_LIGHT=160414001 --ultimate flag beast surge bicorn
FLAG_DOUBLE_TRIB_MACHINE=160414002
FLAG_DOUBLE_TRIB_DARK=160317015 --Voidvelgr Globule
FLAG_DOUBLE_TRIB_GALAXY=160317115
FLAG_DOUBLE_TRIB_WIND=160011022 -- Bluegrass Stealer
FLAG_DOUBLE_TRIB_PSYCHIC=160011122
FLAG_DOUBLE_TRIB_LEVEL7=160205051 -- Double Twin Dragon
FLAG_DOUBLE_TRIB_GREYSTORM=160414002 -- Cosmo Predictor
FLAG_DOUBLE_TRIB_200_DEF=160012015 -- Green-Eyes Star Cat
function Card.AddDoubleTribute(c,id,otfilter,eftg,reset,...)
	for i,flag in ipairs{...} do
		c:RegisterFlagEffect(flag,reset,0,1)
	end
	local e1=aux.summonproc(c,true,true,1,1,SUMMON_TYPE_TRIBUTE+100,aux.Stringid(id,0),otfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(eftg)
	e2:SetLabelObject(e1)
	if reset~=0 then e2:SetReset(reset) end
	c:RegisterEffect(e2)
	local e3=aux.summonproc3trib(c,aux.Stringid(id,1),otfilter)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetTarget(aux.ThreeTribGrantTarget(eftg))
	e4:SetLabelObject(e3)
	if reset~=0 then e4:SetReset(reset) end
	c:RegisterEffect(e4)
end
function aux.DoubleTributeCon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsPlayerAffectedByEffect(tp,FLAG_NO_TRIBUTE)
end
--function to check if the monster have the flag for double tribute (used in otfilter)
function Card.CanBeDoubleTribute(c,...)
	if c:GetFlagEffect(FLAG_DOUBLE_TRIB)~=0 then return false end
	local totalFlags=0
	for i,flag in ipairs{...} do
		totalFlags=totalFlags+flag
		if c:GetFlagEffect(flag)~=0 then return false end
	end
	if c:GetFlagEffect(totalFlags)~=0 then return false end
	return true
end
--function to check if the monster can get the corresponding double tribute flags
--explanation: you can use Executie up on a monster like Rightous dragon that used its own effect to become a double tribute for dragon, it then become usable as 2 tribute for any monsters not just dragon
--but the opposite scenario don't work, if you used executie up on a Righteous dragon making it a double tribute for any monster, you can't activate righteous dragon effect
function Card.IsDoubleTribute(c,...)
	--check for each individual flag
	for i,flag in ipairs{...} do
		if c:GetFlagEffect(flag)==0 then return false end
	end
	return true
end
function Card.AddNoTributeCheck(c,id,stringid,rangeP1,rangeP2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(FLAG_NO_TRIBUTE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetDescription(aux.Stringid(id,stringid))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	e1:SetTargetRange(rangeP1,rangeP2)
	c:RegisterEffect(e1)
end
function Duel.AddNoTributeCheck(c,tp,id,stringid,rangeP1,rangeP2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(FLAG_NO_TRIBUTE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,stringid))
	e1:SetTargetRange(rangeP1,rangeP2)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	Duel.RegisterEffect(e1,tp)
end
function aux.summonproc(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SUMMON_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSummonCondition1(min,max,f))
		e1:SetTarget(Auxiliary.NormalSummonTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSummonOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSummonCondition2())
	end
	e1:SetValue(val)
	return e1
end
function aux.ThreeTribGrantTarget(eftg)
	return function(e,c)
		return eftg(e,c) and c:GetFlagEffect(FLAG_TRIPLE_TRIBUTE)~=0
	end
end
function aux.summonproc3trib(c,desc,otfilter)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if desc then e1:SetDescription(desc) end
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(aux.ThreeTributeCondition(otfilter))
	e1:SetTarget(aux.ThreeTributeTarget(otfilter))
	e1:SetOperation(aux.ThreeTributeOperation())
	e1:SetValue(SUMMON_TYPE_TRIBUTE+1)
	c:RegisterEffect(e1)
	return e1
end
function aux.ThreeTributeCondition(otfilter)
	return function (e,c)
		if c==nil then return true end
		local tp=e:GetHandlerPlayer()
		local rg1=Duel.GetReleaseGroup(tp)
		local rg2=Duel.GetMatchingGroup(otfilter,tp,LOCATION_MZONE,0,nil,tp)
		return aux.SelectUnselectGroup(rg1,e,tp,2,2,aux.ChkfMMZ(1),0)
			and aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),0)
	end
end
function aux.ThreeTributeTarget(otfilter)
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		local rg1=Duel.GetMatchingGroup(otfilter,tp,LOCATION_MZONE,0,nil,tp)
		local mg1=aux.SelectUnselectGroup(rg1,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
		if #mg1>0 then
			local sg=mg1:GetFirst()
			local rg2=Duel.GetReleaseGroup(tp)
			rg2:RemoveCard(sg)
			local mg2=aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
			mg1:Merge(mg2)
		end
		if #mg1==2 then
			mg1:KeepAlive()
			e:SetLabelObject(mg1)
			return true
		end
		return false
	end
end
function aux.ThreeTributeOperation()
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		local g=e:GetLabelObject()
		if not g then return end
		Duel.Release(g,REASON_COST)
		g:DeleteGroup()
	end
end
--Returns true if a monster can get a piercing effect as per Rush rules
function Card.CanGetPiercingRush(c)
    return not (c:IsHasEffect(EFFECT_CANNOT_ATTACK) or c:IsHasEffect(EFFECT_PIERCE))
end
-- Checks if the monster would be a valid target for the equip card
-- Needed because Rush cards typically don't need this check after they are equipped
function Card.CheckEquipTargetRush(equip,monster)
	local effect=equip:GetActivateEffect()
	if nil~=effect then
		local filter=effect:GetTarget()
		if nil~=filter then
			return filter(effect,effect:GetHandlerPlayer(),nil,nil,nil,nil,nil,nil,nil,monster)
		end
	end
	return false
end
-- List of Legend cards, to be used with Card.IsLegend
local LEGEND_LIST={160001000,160205001,160418001,160002000,160421015,160404001,160421016,160432004,160003000,
160006000,160417001,160429001,160318004,160417002,160310002,160417003,160011000,160012000,160008000,160005000,
160009000,160007000,160004000,160010000,160318001,160432002,160310001,160318002,160318003,160201009,160202048,
160203018,160203023,160204048,160204049,160205069,160205070,160206025,160310003,160318006,160408003,160411003,
160417004,160417006,160421017,160428099,160428100,160432003,160202019,160318005,160417005,160418003,160434005,
160436005,160437001,160206019,160206002,160206008,160206022,160206028,160013020}
-- Returns if a card is a Legend. Can be updated if a GetOT function is added to the core
function Card.IsLegend(c)
	return c:IsOriginalCode(table.unpack(LEGEND_LIST))
end
function Card.GetMaterialCountRush(c)
	if c:GetSummonType()==SUMMON_TYPE_TRIBUTE+100 then return c:GetMaterialCount()+1 end
	return c:GetMaterialCount()
end
