--constants
-- TYPE_MAXIMUM=0x8000
-- SUMMON_TYPE_MAXIMUM = 0x4e000000 --to check if it is correct
FLAG_MAXIMUM_CENTER=170000000 --flag for center card maximum mode
FLAG_MAXIMUM_SIDE=170000001 --flag for Left/right maximum card
FLAG_MAXIMUM_CENTER_PREONFIELD=170000002 --those two flag are used to check is the card was a maximum monster while on the field (handling to improve later)
FLAG_MAXIMUM_SIDE_PREONFIELD=170000004
FLAG_MAXIMUM_SIDE_RELATION=180000000 --flag to check the related side pieces of a maximum monster
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
	e1:SetCode(EFFECT_SPSUMMON_PROC)
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
	e5:SetCondition(Maximum.centerCon)
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
		local tg=aux.SelectUnselectGroup(g,e,tp,ct,ct,Maximum.spcheck(mats),1,tp,HINTMSG_SPSUMMON,nil,nil,false)
		if #tg==0 then return end
		--adding the "maximum mode" flag
		--center
		c:RegisterFlagEffect(FLAG_MAXIMUM_CENTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		c:RegisterFlagEffect(FLAG_MAXIMUM_CENTER_PREONFIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)

		--side
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
			tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)
			tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE_RELATION+c:GetCardID(),RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_LEAVE,0,1)
		end
		g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.SendtoGrave(g,REASON_RULE)
		Duel.MoveToField(c,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
		for tc in aux.Next(tg) do
			Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
		end
	end
end
function Maximum.centerCon(e)
	return e:GetHandler():IsMaximumModeCenter()
end
--function that return if the card is in Maximum Mode or not
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
function Card.WasMaximumModeCenter(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_CENTER_PREONFIELD)
end
function Card.WasMaximumModeSide(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD)
end
function Card.WasMaximumMode(c)
	return c:HasFlagEffect(FLAG_MAXIMUM_SIDE_PREONFIELD) or c:HasFlagEffect(FLAG_MAXIMUM_CENTER_PREONFIELD)
end
--that function add the effect that change the Original atk of the Maximum monster
function Card.AddMaximumAtkHandler(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsMaximumMode() end)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaximumAttack())
	c:RegisterEffect(e1)
end
--function that return the value of the "maximum atk" of the monster
function Card.GetMaximumAttack(c)
	local m=c:GetMetatable(false)
	if not m then return 0 end
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
--function to add everything related to Left/Right Maximum Monster behaviour
--c=card to register
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
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
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
	e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e11:SetCondition(Maximum.sideCon)
	c:RegisterEffect(e11)

	--cannot activate effect if side piece
	local e12=baseeff:Clone()
	e12:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e12)

	--cannot be used as material
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE)
	e13:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e13:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e13:SetCondition(Maximum.sideCon)
	e13:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e13)

	--self destroy
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_SINGLE)
	e14:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e14:SetRange(LOCATION_MZONE)
	e14:SetCode(EFFECT_SELF_DESTROY)
	e14:SetCondition(Maximum.SelfDestructCondition)
	c:RegisterEffect(e14)

	--makes so it virtually cannot have any DEF
	local e16=Effect.CreateEffect(c)
	e16:SetType(EFFECT_TYPE_SINGLE)
	e16:SetCode(EFFECT_UPDATE_DEFENSE)
	e16:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e16:SetCondition(Maximum.sideCon)
	e16:SetValue(-1000000)
	c:RegisterEffect(e16)

	baseeff:Reset()
end
function Maximum.SelfDestructCondition(e)
	return e:GetHandler():IsMaximumModeSide() and not Duel.IsExistingMatchingCard(Card.IsMaximumModeCenter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
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
-- function that return the count of a location P1 et P2 minus the Maximum Side
function Duel.GetFieldGroupCountRush(player, p1, p2)
	return Duel.GetMatchingGroupCount(Card.IsNotMaximumModeSide,player,p1,p2,nil)
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
-- summon only in attack
local function summon_pos_target(e,c)
	return c:IsMaximumMode()
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

--handling for tribute summon (when a Maximum monster is Tributed, its side pieces go at the same place as the center piece for the same reason)
function Maximum.cfilter(c,tp)
	return c:IsReason(REASON_SUMMON) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:WasMaximumMode()
end
function Maximum.tribcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Maximum.cfilter,1,nil,tp)
end
function Maximum.tribop(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:Filter(Card.WasMaximumMode,nil):GetFirst()
	local g=Duel.GetMatchingGroup(Card.IsMaximumMode,c:GetControler(),LOCATION_MZONE,0,nil)
	Duel.Sendto(g,c:GetDestination(),0)
	for tc in aux.Next(g) do
		tc:SetReason(c:GetReason())
	end
end
--handling for battle destruction (same as above but for battle destruction)
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