--constants
-- TYPE_MAXIMUM=0x8000
-- SUMMON_TYPE_MAXIMUM = 0x4e000000 --to check if it is correct
FLAG_MAXIMUM_CENTER=170000000 --flag for center card maximum mode
FLAG_MAXIMUM_SIDE=170000001 --flag for Left/right maximum card
if not aux.MaximumProcedure then
	aux.MaximumProcedure = {}
	Maximum = aux.MaximumProcedure
end
if not Maximum then
	Maximum = aux.MaximumProcedure
end
--Maximum Summon
Maximum.AddProcedure = aux.FunctionWithNamedArgs(
function(c,desc,...)
	c:GetMetatable().MaximumSet={...}
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
	e1:SetCondition(Maximum.Condition())
	e1:SetOperation(Maximum.Operation())
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
	
end,"handler","desc","filter1","filter2","filter3","filter4")
--that function check if you can maximum summon the monster and its other part(s)
function Maximum.Condition()
	return  function(e,c,og)
		if c==nil then return true end
		local filters=c.MaximumSet
		local ct=#filters
		local tp=c:GetControler()
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,LOCATION_HAND)
		else
			g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		end
		return aux.SelectUnselectGroup(g,e,tp,ct,ct,Maximum.spcheck(table.unpack(filters)),0)
	end
end
function Maximum.spcheck(...)
	local filters={...}
	return function(sg,e,tp,mg)
		local ct=#filters
		for i=1,ct do
			if not sg:IsExists(filters[i],1,nil) then return false end
		end
		return #sg==ct
	end
end
--operation that do the maximum summon
function Maximum.Operation(...)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
		
		if c==nil then return true end
		local filters=c.MaximumSet
		local ct=#filters
		local tp=c:GetControler()
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,LOCATION_HAND)
		else
			g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		end
		local tg=aux.SelectUnselectGroup(g,e,tp,ct,ct,Maximum.spcheck(table.unpack(filters)),1,tp,HINTMSG_SPSUMMON)+c
		--adding the "maximum mode" flag
		e:GetHandler():RegisterFlagEffect(FLAG_MAXIMUM_CENTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		local tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		end
		sg:Merge(tg)
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
	return c:IsLocation(LOCATION_MZONE) and c:GetFlagEffect(FLAG_MAXIMUM_CENTER)>0
end
function Card.IsMaximumModeSide(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetFlagEffect(FLAG_MAXIMUM_SIDE)>0
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
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(1)
	e1:SetCondition(Maximum.sideCon)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(Maximum.maxCenterVal)
	c:RegisterEffect(e1)
	
	--change level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabel(2)
	e2:SetCondition(Maximum.sideCon)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(Maximum.maxCenterVal)
	c:RegisterEffect(e2)
	--change name
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(3)
	e3:SetCondition(Maximum.sideCon)
	e3:SetValue(Maximum.maxCenterVal)
	c:RegisterEffect(e3)
	--change Race
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabel(4)
	e4:SetCondition(Maximum.sideCon)
	e4:SetValue(Maximum.maxCenterVal)
	c:RegisterEffect(e4)
	--change attribute
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetLabel(5)
	e5:SetCondition(Maximum.sideCon)
	e5:SetValue(Maximum.maxCenterVal)
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
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetCondition(Maximum.sideCon)
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	
	--cannot be changed to def
	local e8=Effect.CreateEffect(c)
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e8:SetCondition(Maximum.sideCon)
	c:RegisterEffect(e8)
	local e8=Effect.CreateEffect(c)
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	e8:SetCondition(Maximum.sideCon)
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
end
function Maximum.GetMaximumCenter(tp)
	local tc=Duel.GetMatchingGroup(Card.IsMaximumModeCenter,tp,LOCATION_MZONE,0,nil):GetFirst()
	return tc
end
function Maximum.maxCenterVal(e,c)
	local tc=Duel.GetMatchingGroup(Card.IsMaximumModeCenter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetFirst()
	if e:GetLabel()==1 then return tc:GetMaximumAttack()
	elseif e:GetLabel()==2 then return tc:GetLevel()
	elseif e:GetLabel()==3 then return tc:GetCode()
	elseif e:GetLabel()==4 then return tc:GetRace()
	elseif e:GetLabel()==5 then return tc:GetAttribute()
	end	
end
function Maximum.eftgMax(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsMaximumMode() and c~=e:GetHandler()
end
function Maximum.sideCon(e)
	local tc=Duel.GetMatchingGroup(Card.IsMaximumModeCenter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetFirst()
	return e:GetHandler():IsMaximumModeSide() and tc~=nil
end
function Maximum.sideConGrant(e)
	local tc=Duel.GetMatchingGroup(Card.IsMaximumModeCenter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetFirst()
	return e:GetHandler():IsMaximumModeSide() and tc~=nil
end
--function that return if the max monster used an effect 
function Card.HasUsedIgnition(c,effID)
	return c:GetFlagEffect(effID)>0
end 
--function that return false if the monster don't have defense stats
--wait for ruling
function Card.HasDefense(c)
	return not (c:IsType(TYPE_LINK) or (c:IsType(TYPE_MAXIMUM) and c:IsMaximumMode()))
end
-- function that add the flag to says "I used that effect once this turn"
function Duel.RegisterMaxIgnition(tp,effid)
	local g=Duel.GetMatchingGroup(Card.IsMaximumMode,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(effid,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

--functions to handle counting monsters but without the side Maximum monsters (the L/R max monsters are subtracted from the count)
function Duel.GetMatchingGroupCountRush(f,tp,LOCP1,LOCP2,exclude)
	local maxi=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunction(f),tp,LOCP1,LOCP2,exclude)
	return Duel.GetMatchingGroupCount(f,tp,LOCP1,LOCP2,exclude)-maxi
end
--function that return only the side monsters
function Auxiliary.FilterMaximumSideFunction(f,...)
	local params={...}
	return 	function(target)
				return target:IsMaximumModeSide() and f(target,table.unpack(params))
			end
end
--function that exclude L/R Maximum Mode
function Auxiliary.FilterMaximumSideFunctionEx(f,...)
	local params={...}
	return 	function(target)
				return f(target,table.unpack(params)) and target:IsMaximumModeCenter()
			end
end
-- function that return the count of a location P1 et P2 minus the Maximum Side
function Duel.GetFieldGroupCountRush(player, p1, p2)
	local maxi=Duel.GetMatchingGroupCount(Card.IsMaximumModeSide,player,p1,p2,nil)
	return Duel.GetFieldGroupCount(player,p1,p2)-maxi
end
--function that add every parts of the Maximum Mode monster to the group
function Group.AddMaximumCheck(group)
	local g=group:Clone()
	local tc=g:GetFirst()
	for tc in aux.Next(group) do
		if tc:IsMaximumMode() then
			local g2=Duel.GetMatchingGroup(Card.IsMaximumMode,c:GetControler(),LOCATION_MZONE,0,tc)
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
local function initial_effect()
    local e1=Effect.GlobalEffect()
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,1)
    e1:SetTarget(function(e,c) return c:IsSummonType(SUMMON_TYPE_MAXIMUM) end)
    e1:SetValue(POS_FACEUP_ATTACK)
    Duel.RegisterEffect(e1,0)
end
initial_effect()



-- handling for tribute summon
function Maximum.cfilter(c,tp)
    return c:IsReason(REASON_SUMMON) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function Maximum.tribcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Maximum.cfilter,1,nil,tp)
end
function Maximum.tribop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMaximumMode,tp,LOCATION_MZONE,0,nil)
	Duel.Sendto(g,eg:GetFirst():GetDestination(),nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:SetReason(eg:GetFirst():GetReason())
	end
end
--handling for battle destruction
function Maximum.battlecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
end
function Maximum.battleop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMaximumMode,tp,LOCATION_MZONE,0,nil)
	Duel.Sendto(g,eg:GetFirst():GetDestination(),nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:SetReason(eg:GetFirst():GetReason())
	end
end