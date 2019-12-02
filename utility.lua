Auxiliary={}
aux=Auxiliary
function GetID()
    return self_table,self_code
end
function Duel.LoadCardScript(code)
	local card=string.sub(code,0,string.len(code)-4)
    if not _G[card] then
		local oldtable,oldcode=GetID()
        _G[card] = {}
		self_table=_G[card]
		self_code=tonumber(string.sub(card,2))
        Duel.LoadScript(code)
		self_table=oldtable
		self_code=oldcode
    end
end
function Card.GetMetatable(c)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	return mt
end
bit={}
function bit.band(a,b)
    return a&b
end
function bit.bor(a,b)
    return a|b
end
function bit.bxor(a,b)
    return a~b
end
function bit.lshift(a,b)
    return a<<b
end
function bit.rshift(a,b)
    return a>>b
end
function bit.bnot(a)
    return ~a
end
local function fieldargs(f,width)
    w=width or 1
    assert(f>=0,"field cannot be negative")
    assert(w>0,"width must be positive")
    assert(f+w<=32,"trying to access non-existent bits")
    return f,~(-1<<w)
end
function bit.extract(r,field,width)
    local f,m=fieldargs(field,width)
    return (r>>f)&m
end
function bit.replace(r,v,field,width)
    local f,m=fieldargs(field,width)
    return (r&~(m<<f))|((v&m)<< f)
end

Group.__band = function (o1,o2)
	if userdatatype(o1)~="Group" then o1,o2=o2,o1 end
	o1=o1:Clone()
	o1=o1-(o1-o2)
	return o1
end

Group.__add = function (o1,o2)
	if userdatatype(o1)~="Group" then o1,o2=o2,o1 end
	o1=o1:Clone()
	if userdatatype(o2)=="Card" then
		o1:AddCard(o2)
	else
		o1:Merge(o2)
	end
	return o1
end

Group.__sub = function (o1,o2)
	o1=o1:Clone()
	if userdatatype(o2)=="Card" then
		o1:RemoveCard(o2)
	else
		o1:Sub(o2)
	end
	return o1
end

Group.__len = function (g)
	return g:GetCount()
end

Group.__eq = function (g1,g2)
	return #g1==#g2
end

Group.__lt = function (g1,g2)
	return #g1<#g2
end

Group.__le = function (g1,g2)
	return #g1<=#g2
end
--Returns 2 groups, the 1st group is the one with cards that match the function, the second is the one with cards that don't
Group.Split = function (g,fun,ex,...)
	local ng=g:Filter(fun,ex,...)
	return ng,g-ng
end

function userdatatype(o)
	if type(o)~="userdata" then return "not userdata"
	elseif o.GetOriginalCode then return "Card"
	elseif o.KeepAlive then return "Group"
	elseif o.SetLabelObject then return "Effect"
	end
end
function Card.CheckAdjacent(c)
	local p=c:GetControler()
	local seq=c:GetSequence()
	if seq>4 then return false end
	return (seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1))
end
function Card.MoveAdjacent(c)
	local tp=c:GetControler()
	local seq=c:GetSequence()
	if seq>4 then return end
	local flag=0
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(0x1<<seq-1) end
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(0x1<<seq+1) end
	if flag==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(c,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag),2))
end
function Group.ForEach(g,f,...)
	local tc=g:GetFirst()
	while tc do
		f(tc,...)
		tc=g:GetNext()
	end
end
function Auxiliary.ParamsFromTable(tab,key,...)
	if key then
		if ... then
			return tab[key],Auxiliary.ParamsFromTable(tab,...)
		else
			return tab[key]
		end
	end
end
function aux.FunctionWithNamedArgs(f,...)
	local args={...}
	return function(tab,...)
		if type(tab)=="table" then
			return f(Auxiliary.ParamsFromTable(tab,table.unpack(args)))
		else
			return f(tab,...)
		end
	end
end
function Auxiliary.GetExtraMaterials(tp,mustg,sc,summon_type)
	local tg=Group.CreateGroup()
	mustg = mustg or Group.CreateGroup()
	local eff={Duel.GetPlayerEffect(tp,EFFECT_EXTRA_MATERIAL)}
	local t={}
	for _,te in ipairs(eff) do
		if te:GetCode()==EFFECT_EXTRA_MATERIAL then
			local eg=te:GetValue()(0,summon_type,te,tp,sc)-mustg
			eg:KeepAlive()
			tg=tg+eg
			local efun=te:GetOperation() and te:GetOperation() or aux.TRUE
			table.insert(t,{eg,efun,te})
		end
	end
	return t,tg
end
function Auxiliary.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
	local res=false
	filt=filt or {}
	for _,ex in ipairs(emt) do
		if ex[1]:IsContains(c) and ex[2](c,ex[3],tp,sg,mg,lc,ex[1],0) then
			res=true
			table.insert(filt,ex)
		end
	end
	return res
end
function Auxiliary.DeleteExtraMaterialGroups(emt)
	for _,ex in ipairs(emt) do
		if ex[3]:GetValue() then
			ex[3]:GetValue()(2,nil,ex[3],ex[1])
		end
		ex[1]:DeleteGroup()
	end
end
function Auxiliary.GetMustBeMaterialGroup(tp,eg,sump,sc,g,r)
	--- eg all default materials, g - valid materials
	local eff={Duel.GetPlayerEffect(tp,EFFECT_MUST_BE_MATERIAL)}
	local sg=Group.CreateGroup()
	for _,te in ipairs(eff) do
		if te:GetCode()==EFFECT_MUST_BE_MATERIAL then
			local val=type(te:GetValue())=='function' and te:GetValue()(te,eg,sump,sc,g) or te:GetValue()
			if val&r>0 then
				sg:AddCard(te:GetHandler())
			end
		end
	end
	return sg
end
function Group.Includes(g1,g2)
	return #(g1-g2)+#g2==#g1
end
--for additional registers
local regeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	if c:IsStatus(STATUS_INITIALIZING) and not e then Debug.Message("missing (Effect e) in c"..c:GetOriginalCode()..".lua") return end
	--1 == 511002571 - access to effects that activate that detach an Xyz Material as cost
	--2 == 511001692 - access to Cardian Summoning conditions/effects
	--4 ==  12081875 - access to Thunder Dragon effects that activate by discarding
	--8 == 511310036 - access to Allure Queen effects that activate by sending themselves to GY
	local reg_e = regeff(c,e,forced)
	if not reg_e then
		return nil
	end
	local reg={...}
	local resetflag,resetcount=e:GetReset()
	for _,val in ipairs(reg) do
		local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
		if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
		if val==1 then
			e2:SetCode(511002571)
		elseif val==2 then
			e2:SetCode(511001692)
		elseif val==4 then
			e2:SetCode(12081875)
		elseif val==8 then
			e2:SetCode(511310036)
		end
		e2:SetLabelObject(e)
		e2:SetLabel(c:GetOriginalCode())
		if resetflag and resetcount then
			e2:SetReset(resetflag,resetcount)
		elseif resetflag then
			e2:SetReset(resetflag)
		end
		c:RegisterEffect(e2)
	end
	return reg_e
end
function Card.IsColumn(c,seq,tp,loc)
	if not c:IsOnField() then return false end
	local cseq=c:GetSequence()
	local seq=seq
	local loc=loc and loc or c:GetLocation()
	local tp=tp and tp or c:GetControler()
	if c:IsLocation(LOCATION_MZONE) then
		if cseq==5 then cseq=1 end
		if cseq==6 then cseq=3 end
	else
		if cseq==6 then cseq=5 end
	end
	if loc==LOCATION_MZONE then
		if seq==5 then seq=1 end
		if seq==6 then seq=3 end
	else
		if cseq==6 then cseq=5 end
	end
	if c:IsControler(tp) then
		return cseq==seq
	else
		return cseq==4-seq
	end
end

function Card.UpdateAttack(c,amt,reset,rc)
	rc=rc and rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset and reset or RESET_EVENT+r
    local atk=c:GetAttack()
    if atk>=-amt then --If amt is positive, it would become negative and always be lower than or equal to atk, if amt is negative, it would become postive and if it is too much it would be higher than atk
    	local e1=Effect.CreateEffect(rc)
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_UPDATE_ATTACK)
    	if c==rc then
    		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
    	end
    	e1:SetValue(amt)
    	e1:SetReset(reset)
    	c:RegisterEffect(e1)
    	return c:GetAttack()-atk
    end
    return 0
end

function Card.UpdateDefense(c,amt,reset,rc)
	rc=rc and rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset and reset or RESET_EVENT+r
    local def=c:GetDefense()
    if def and def>=-amt then --See Card.UpdateAttack
    	local e1=Effect.CreateEffect(rc)
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_UPDATE_DEFENSE)
    	if c==rc then
    		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
    	end
    	e1:SetValue(amt)
    	e1:SetReset(reset)
    	c:RegisterEffect(e1)
    	return c:GetDefense()-def
    end
    return 0
end

function Card.UpdateLevel(c,amt,reset,rc)
	rc=rc and rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset and reset or RESET_EVENT+r
    local lv=c:GetLevel()
    if c:IsLevelBelow(2147483647) then
    	if lv+amt<=0 then amt=-(lv-1) end --Unlike ATK, if amt is too much should reduce as much as possible
    	local e1=Effect.CreateEffect(rc)
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_UPDATE_LEVEL)
    	e1:SetValue(amt)
    	e1:SetReset(reset)
    	c:RegisterEffect(e1)
    	return c:GetLevel()-lv
    end
    return 0
end

function Card.UpdateRank(c,amt,reset,rc)
	rc=rc and rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset and reset or RESET_EVENT+r
    local rk=c:GetRank()
    if c:IsRankBelow(2147483647) then
    	if rk+amt<=0 then amt=-(rk-1) end --See Card.UpdateLevel
    	local e1=Effect.CreateEffect(rc)
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_UPDATE_RANK)
    	e1:SetValue(amt)
    	e1:SetReset(reset)
    	c:RegisterEffect(e1)
    	return c:GetRank()-rk
    end
    return 0
end

function Card.UpdateLink(c,amt,reset,rc)
	rc=rc and rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset and reset or RESET_EVENT+r
    local lk=c:GetLink()
    if c:IsLinkBelow(2147483647) then
    	if lk+amt<=0 then amt=-(lk-1) end --See Card.UpdateLevel
    	local e1=Effect.CreateEffect(rc)
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_UPDATE_LINK)
    	e1:SetValue(amt)
    	e1:SetReset(reset)
    	c:RegisterEffect(e1)
    	return c:GetLink()-lk
    end
    return 0
end

function Card.UpdateScale(c,amt,reset,rc)
	rc=rc and rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset and reset or RESET_EVENT+r
	local scl=c:GetLeftScale()
	if scl then
		if scl+amt<=0 then amt = -(scl-1) end --See Card.UpdateLevel
		local e1=Effect.CreateEffect(rc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(amt)
		e1:SetReset(reset)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		c:RegisterEffect(e2)
		return c:GetLeftScale()-scl
	end
	return 0
end

function Auxiliary.Stringid(code,id)
	return id|code<<32
end
function Auxiliary.Next(g)
	local first=true
	return	function()
				if first then first=false return g:GetFirst()
				else return g:GetNext() end
			end
end
function Auxiliary.NULL()
end
function Auxiliary.TRUE()
	return true
end
function Auxiliary.FALSE()
	return false
end
function Auxiliary.AND(...)
	local funs={...}
	return	function(...)
				for _,f in ipairs(funs) do
					if not f(...) then return false end
				end
				return true
			end
end
function Auxiliary.OR(...)
	local funs={...}
	return	function(...)
				for _,f in ipairs(funs) do
					if f(...) then return true end
				end
				return false
			end
end
function Auxiliary.tableAND(...)
	local funs={...}
	return	function(...)
				local ret={}
				for _,f in ipairs(funs) do
					local res={f(...)}
					for _,val in pairs(res) do
						ret[_]=val and (ret[_]==nil or ret[_])
					end
				end
				return ret
			end
end
function Auxiliary.tableOR(...)
	local funs={...}
	return	function(...)
				local ret={}
				for _,f in ipairs(funs) do
					local res={f(...)}
					for _,val in pairs(res) do
						ret[_]=val or not (ret[_]==nil or not ret[_])
					end
				end
				return ret
			end
end
function Auxiliary.NOT(f)
	return	function(...)
				return not f(...)
			end
end
function Auxiliary.BeginPuzzle(effect)
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TURN_END)
	e1:SetCountLimit(1)
	e1:SetOperation(Auxiliary.PuzzleOp)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_SKIP_DP)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,0)
	local e3=Effect.GlobalEffect()
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_SKIP_SP)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,0)
end
function Auxiliary.PuzzleOp(e,tp)
	Duel.SetLP(0,0)
end
function Auxiliary.IsGeminiState(effect)
	local c=effect:GetHandler()
	return not c:IsDisabled() and c:IsGeminiState()
end
function Auxiliary.IsNotGeminiState(effect)
	local c=effect:GetHandler()
	return c:IsDisabled() or not c:IsGeminiState()
end
function Auxiliary.GeminiNormalCondition(effect)
	local c=effect:GetHandler()
	return c:IsFaceup() and not c:IsGeminiState()
end
function Auxiliary.EnableGeminiAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_GEMINI_SUMMONABLE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCondition(aux.GeminiNormalCondition)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)
end
--register effect of return to hand for Spirit monsters
function Auxiliary.EnableSpiritReturn(c,event1,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(event1)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(Auxiliary.SpiritReturnReg)
	c:RegisterEffect(e1)
	for i,event in ipairs{...} do
		local e2=e1:Clone()
		e2:SetCode(event)
		c:RegisterEffect(e2)
	end
end
function Auxiliary.SpiritReturnReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	if e:GetCode() == EVENT_FLIP_SUMMON_SUCCESS or e:GetCode() == EVENT_FLIP then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TEMP_REMOVE-RESET_LEAVE+RESET_PHASE+PHASE_END)
	end
	e1:SetCondition(Auxiliary.SpiritReturnCondition)
	e1:SetTarget(Auxiliary.SpiritReturnTarget)
	e1:SetOperation(Auxiliary.SpiritReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	c:RegisterEffect(e2)
end
function Auxiliary.SpiritReturnCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) then return false end
	if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
		return not c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
	else return c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN) end
end
function Auxiliary.SpiritReturnTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function Auxiliary.SpiritReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
function Auxiliary.TargetEqualFunction(f,value,...)
	local params={...}
	return	function(effect,target)
				return f(target,table.unpack(params))==value
			end
end
function Auxiliary.TargetBoolFunction(f,...)
	local params={...}
	return	function(effect,target)
				return f(target,table.unpack(params))
			end
end
function Auxiliary.FilterEqualFunction(f,value,...)
	local params={...}
	return	function(target)
				return f(target,table.unpack(params))==value
			end
end
--used for Material Types Filter Bool (works for IsRace, IsAttribute, IsType)
function Auxiliary.FilterSummonCode(...)
	local params={...}
	return	function(c,scard,sumtype,tp)
				return c:IsSummonCode(scard,sumtype,tp,table.unpack(params))
			end
end
function Auxiliary.FilterBoolFunctionEx(f,value)
	return	function(target,scard,sumtype,tp)
				return f(target,value,scard,sumtype,tp)
			end
end
function Auxiliary.FilterBoolFunctionEx2(f,...)
	local params={...}
	return	function(target,scard,sumtype,tp)
				return f(target,scard,sumtype,tp,table.unpack(params))
			end
end
function Auxiliary.FilterBoolFunction(f,...)
	local params={...}
	return	function(target)
				return f(target,table.unpack(params))
			end
end
Auxiliary.ProcCancellable=false
function Auxiliary.IsMaterialListCode(c,...)
	if not c.material then return false end
	local codes={...}
	for _,code in ipairs(codes) do
		for _,mcode in ipairs(c.material) do
			if code==mcode then return true end
		end
	end
	return false
end
function Auxiliary.IsMaterialListSetCard(c,...)
	if not c.material_setcode then return false end
	local setcodes={...}
	for _,setcode in ipairs(setcodes) do
		if type(c.material_setcode)=='table' then
			for _,v in ipairs(c.material_setcode) do
				if v==setcode then return true end
			end
		else
			if c.material_setcode==setcode then return true end
		end
	end
	return false
end
function Auxiliary.IsCodeListed(c,...)
	if not c.listed_names then return false end
	local codes={...}
	for _,code in ipairs(codes) do
		for _,ccode in ipairs(c.listed_names) do
			if code==ccode then return true end
		end
	end
	return false
end
--card effect disable filter(target)
function Auxiliary.disfilter1(c)
	return c:IsFaceup() and not c:IsDisabled() and (not c:IsNonEffectMonster() or c:GetType()&TYPE_EFFECT~=0)
end
--condition of EVENT_BATTLE_DESTROYING
function Auxiliary.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle()
end
--condition of EVENT_BATTLE_DESTROYING + opponent monster
function Auxiliary.bdocon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
--condition of EVENT_BATTLE_DESTROYING + to_grave
function Auxiliary.bdgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
--condition of EVENT_BATTLE_DESTROYING + opponent monster + to_grave
function Auxiliary.bdogcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
--condition of EVENT_TO_GRAVE + destroyed_by_opponent_from_field
function Auxiliary.dogcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and rp~=tp
end
--condition of "except the turn this card was sent to the Graveyard"
function Auxiliary.exccon(e)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN)
end
--flag effect for spell counter
function Auxiliary.chainreg(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(1)==0 then
		e:GetHandler():RegisterFlagEffect(1,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
--default filter for EFFECT_CANNOT_BE_BATTLE_TARGET
function Auxiliary.imval1(e,c)
	return not c:IsImmuneToEffect(e)
end
--default filter for EFFECT_CANNOT_BE_BATTLE_TARGET + opponent
function Auxiliary.imval2(e,c)
	return Auxiliary.imval1(e,c) and c:GetControler()~=e:GetHandlerPlayer()
end
--filter for EFFECT_CANNOT_BE_EFFECT_TARGET + opponent 
function Auxiliary.tgoval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
--filter for EFFECT_INDESTRUCTABLE_EFFECT + self
function Auxiliary.indsval(e,re,rp)
    return rp==e:GetHandlerPlayer()
end
--filter for EFFECT_INDESTRUCTABLE_EFFECT + opponent
function Auxiliary.indoval(e,re,rp)
    return rp==1-e:GetHandlerPlayer()
end
--filter for non-zero ATK 
function Auxiliary.nzatk(c)
	return c:IsFaceup() and c:GetAttack()>0
end
--filter for non-zero DEF
function Auxiliary.nzdef(c)
	return c:IsFaceup() and c:GetDefense()>0
end
--flag effect for summon/sp_summon turn
function Auxiliary.sumreg(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	for tc in aux.Next(eg) do
		if tc:GetOriginalCode()==code then 
			tc:RegisterFlagEffect(code,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1) 
		end
	end
end
--sp_summon condition for fusion monster
function Auxiliary.fuslimit(e,se,sp,st)
	return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
--sp_summon condition for ritual monster
function Auxiliary.ritlimit(e,se,sp,st)
	return st&SUMMON_TYPE_RITUAL==SUMMON_TYPE_RITUAL
end
--sp_summon condition for synchro monster
function Auxiliary.synlimit(e,se,sp,st)
	return st&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO
end
--sp_summon condition for xyz monster
function Auxiliary.xyzlimit(e,se,sp,st)
	return st&SUMMON_TYPE_XYZ==SUMMON_TYPE_XYZ
end
--sp_summon condition for pendulum monster
function Auxiliary.penlimit(e,se,sp,st)
	return st&SUMMON_TYPE_PENDULUM==SUMMON_TYPE_PENDULUM
end
--sp_summon condition for link monster
function Auxiliary.lnklimit(e,se,sp,st)
	return st&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
--effects inflicting damage to tp
function Auxiliary.damcon1(e,tp,eg,ep,ev,re,r,rp)
	local e1=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_DAMAGE)
	local e2=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER)
	local rd=e1 and not e2
	local rr=not e1 and e2
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex and (cp==tp or cp==PLAYER_ALL) and not rd and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) then 
		return true 
	end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	return ex and (cp==tp or cp==PLAYER_ALL) and rr and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE)
end
--filter for the immune effect of qli monsters
function Auxiliary.qlifilter(e,te)
	if te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local lv=e:GetHandler():GetLevel()
		local ec=te:GetOwner()
		if ec:IsType(TYPE_LINK) then
			return false
		elseif ec:IsType(TYPE_XYZ) then
			return ec:GetOriginalRank()<lv
		else
			return ec:GetOriginalLevel()<lv
		end
	else
		return false
	end
end
--filter for necro_valley test
function Auxiliary.nvfilter(c)
	return not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function Auxiliary.NecroValleyFilter(f)
	return	function(target,...)
				return f(target,...) and not (target:IsHasEffect(EFFECT_NECRO_VALLEY) and Duel.IsChainDisablable(0))
			end
end

--Cost for effect "You can banish this card from your Graveyard"
function Auxiliary.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) or not c:IsType(TYPE_MONSTER)
		or not c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

--sp_summon condition for gladiator beast monsters
function Auxiliary.gbspcon(e,tp,eg,ep,ev,re,r,rp)
	local st=e:GetHandler():GetSummonType()
	return st>=(SUMMON_TYPE_SPECIAL+100) and st<(SUMMON_TYPE_SPECIAL+150)
end

--sp_summon condition for evolsaur monsters
function Auxiliary.evospcon(e,tp,eg,ep,ev,re,r,rp)
	local st=e:GetHandler():GetSummonType()
	return st>=(SUMMON_TYPE_SPECIAL+150) and st<(SUMMON_TYPE_SPECIAL+180)
end

--check for Spirit Elimination
function Auxiliary.SpElimFilter(c,mustbefaceup,includemzone)
	--includemzone - contains MZONE in original requirement
	--NOTE: Should only check LOCATION_MZONE+LOCATION_GRAVE
	if c:IsType(TYPE_MONSTER) then
		if mustbefaceup and c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return false end
		if includemzone then return c:IsLocation(LOCATION_MZONE) or not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) end
		if Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) then
			return c:IsLocation(LOCATION_MZONE)
		else
			return c:IsLocation(LOCATION_GRAVE)
		end
	else
		return includemzone or c:IsLocation(LOCATION_GRAVE)
	end
end

--check for Eyes Restrict equip limit
function Auxiliary.AddEREquipLimit(c,con,equipval,equipop,linkedeff,prop,resetflag,resetcount)
	local finalprop=EFFECT_FLAG_CANNOT_DISABLE
	if prop~=nil then
		finalprop=finalprop|prop
	end
	local e1=Effect.CreateEffect(c)
	if con then
		e1:SetCondition(con)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(finalprop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e1:SetCode(89785779)
	e1:SetLabelObject(linkedeff)
	if resetflag and resetcount then
		e1:SetReset(resetflag,resetcount)
	elseif resetflag then
		e1:SetReset(resetflag)
	end
	e1:SetValue(function(ec,c,tp) return equipval(ec,c,tp) end)
	e1:SetOperation(function(c,e,tp,tc) equipop(c,e,tp,tc) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(finalprop&~EFFECT_FLAG_CANNOT_DISABLE,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e2:SetCode(89785779+EFFECT_EQUIP_LIMIT)
	if resetflag and resetcount then
		e2:SetReset(resetflag,resetcount)
	elseif resetflag then
		e2:SetReset(resetflag)
	end
	c:RegisterEffect(e2)
	linkedeff:SetLabelObject(e2)
end

function Auxiliary.EquipByEffectLimit(e,c)
	if e:GetOwner()~=c then return false end
	local eff={c:GetCardEffect(89785779+EFFECT_EQUIP_LIMIT)}
	for _,te in ipairs(eff) do
		if te==e:GetLabelObject() then return true end
	end
	return false
end
--register for "Equip to this card by its effect"
function Auxiliary.EquipByEffectAndLimitRegister(c,e,tp,tc,code,mustbefaceup)
	local up=false or mustbefaceup
	if not Duel.Equip(tp,tc,c,up) then return false end
	--Add Equip limit
	if code then
		tc:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	local te=e:GetLabelObject()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(Auxiliary.EquipByEffectLimit)
	e1:SetLabelObject(te)
	tc:RegisterEffect(e1)
	return true
end

--add a anounce digit by digit
function Auxiliary.ComposeNumberDigitByDigit(tp,min,max)
	if min>max then min,max=max,min end
	local mindc=#tostring(min)
	local maxdc=#tostring(max)
	local dbdmin={}
	local dbdmax={}
	local mi=maxdc-1
	local aux=min
	for i=1,maxdc do
		dbdmin[i]=math.floor(aux/(10^mi))
		aux=aux%(10^mi)
		mi=mi-1
	end
	aux=max
	mi=maxdc-1
	for i=1,maxdc do
		dbdmax[i]=math.floor(aux/(10^mi))
		aux=aux%(10^mi)
		mi=mi-1
	end
	local chku=true
	local chkl=true
	local dbd={}
	mi=maxdc-1
	for i=1,maxdc do
		local maxval=9
		local minval=0
		if chku and i>1 and dbd[i-1]<dbdmax[i-1] then
			chku=false
		end
		if chkl and i>1 and dbd[i-1]>dbdmin[i-1] then
			chkl=false
		end
		if chku then
			maxval=dbdmax[i]
		end
		if chkl then
			minval=dbdmin[i]
		end
		local r={}
		local j=1
		for k=minval,maxval do
			r[j]=k
			j=j+1
		end
		dbd[i]=Duel.AnnounceNumber(tp,table.unpack(r))
		mi=mi-1
	end
	local number=0
	mi=maxdc-1
	for i=1,maxdc do
		number=number+dbd[i]*10^mi
		mi=mi-1
	end
	return number
end
function Card.GetToBeLinkedZone(tc,c,tp,clink,emz)
	local zone=0
	local seq=tc:GetSequence()
	if tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp) then
		if c:IsLinkMarker(LINK_MARKER_LEFT) and seq < 4 and (not clink or tc:IsLinkMarker(LINK_MARKER_RIGHT)) then zone=zone|(1<<seq+1) end
		if c:IsLinkMarker(LINK_MARKER_RIGHT) and seq > 0 and seq <= 4 and (not clink or tc:IsLinkMarker(LINK_MARKER_LEFT)) then zone=zone|(1<<seq-1) end
		if c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) and (seq == 5 or seq == 6) and (not clink or tc:IsLinkMarker(LINK_MARKER_BOTTOM_LEFT)) then zone=zone|(1<<2*(seq-5)) end
		if c:IsLinkMarker(LINK_MARKER_TOP) and (seq == 5 or seq == 6) and (not clink or tc:IsLinkMarker(LINK_MARKER_BOTTOM)) then zone=zone|(1<<2*(seq-5)+1) end
		if c:IsLinkMarker(LINK_MARKER_TOP_LEFT) and (seq == 5 or seq == 6) and (not clink or tc:IsLinkMarker(LINK_MARKER_BOTTOM_RIGHT)) then zone=zone|(1<<2*(seq-5)+2) end
		if emz and c:IsLinkMarker(LINK_MARKER_BOTTOM_LEFT) and (seq == 0 or seq == 2) and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP_RIGHT)) then zone=zone|(1<<5+seq/2) end
		if emz and c:IsLinkMarker(LINK_MARKER_BOTTOM) and (seq == 1 or seq == 3) and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP)) then zone=zone|(1<<5+(seq-1)/2) end
		if emz and c:IsLinkMarker(LINK_MARKER_BOTTOM_RIGHT) and (seq == 2 or seq == 4) and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP_LEFT)) then zone=zone|(1<<5+(seq-2)/2) end
	elseif tc:IsLocation(LOCATION_MZONE) then
		if c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) and (seq == 5 or seq == 6 or (emz and (seq == 0 or seq == 2))) and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP_RIGHT)) then
			if seq == 5 or seq == 6 then
				zone=zone|(1<<-2*(seq-5)+2)
			else
				zone=zone|(1<<-seq/2+6)
			end
		end
		if c:IsLinkMarker(LINK_MARKER_TOP) and (seq == 5 or seq == 6 or (emz and (seq == 1 or seq == 3))) and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP)) then
			if seq == 5 or seq == 6 then
				zone=zone|(1<<-2*(seq-5)+3)
			else
				zone=zone|(1<<-(seq-1)/2+6)
			end
		end
		if c:IsLinkMarker(LINK_MARKER_TOP_LEFT) and (seq == 2 or seq == 4 or (emz and (seq == 2 or seq == 4))) and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP_LEFT)) then
			if seq == 5 or seq == 6 then
				zone=zone|(1<<-2*(seq-5)+4)
			else
				zone=zone|(1<<-(seq-2)/2+6)
			end
		end
	end
	return zone
end
function Group.GetToBeLinkedZone(g,c,tp,clink,emz)
	local zone=0
	for tc in aux.Next(g) do
		zone=zone|tc:GetToBeLinkedZone(c,tp,clink,emz)
	end
	return zone
end
function Auxiliary.ResetEffects(g,eff)
	for c in aux.Next(g) do
		local effs={c:GetCardEffect(eff)}
		for _,v in ipairs(effs) do
			v:Reset()
		end
	end
end
function Auxiliary.CallToken(code)
	Debug.Message(code.." called Auxiliary.CallToken, use Duel.LoadCardScript or Duel.LoadScript instead!!!")
end
--utility entry for SelectUnselect loops
--returns bool if chk==0, returns Group if chk==1
function Auxiliary.SelectUnselectLoop(c,sg,mg,e,tp,minc,maxc,rescon)
	local res
	if #sg>=maxc then return false end
	sg:AddCard(c)
	if #sg<minc then
		res=mg:IsExists(Auxiliary.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	elseif #sg<maxc then
		res=(not rescon or rescon(sg,e,tp,mg)) or mg:IsExists(Auxiliary.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	else
		res=(not rescon or rescon(sg,e,tp,mg))
	end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,cancelcon,breakcon)
	local minc=minc or 1
	local maxc=maxc or #g
	if chk==0 then return g:IsExists(Auxiliary.SelectUnselectLoop,1,nil,Group.CreateGroup(),g,e,tp,minc,maxc,rescon) end
	local hintmsg=hintmsg and hintmsg or 0
	local sg=Group.CreateGroup()
	while true do
		local cancelable = (not cancelcon or cancelcon(sg,e,tp,g))
		local mg=g:Filter(Auxiliary.SelectUnselectLoop,sg,sg,g,e,tp,minc,maxc,rescon)
		if (breakcon and breakcon(sg,e,tp,mg)) or #mg<=0 or #sg>=maxc then break end
		Duel.Hint(HINT_SELECTMSG,seltp,hintmsg)
		local tc=mg:SelectUnselect(sg,seltp,cancelable and #sg>=minc,cancelable and #sg==0,minc,maxc)
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
	end
	return sg
end
--check for free Zone for monsters to be Special Summoned except from Extra Deck
function Auxiliary.MZFilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and c:IsControler(tp)
end
--check for Free Monster Zones
function Auxiliary.ChkfMMZ(sumcount)
	return	function(sg,e,tp,mg)
				return sg:FilterCount(Auxiliary.MZFilter,nil,tp)+Duel.GetLocationCount(tp,LOCATION_MZONE)>=sumcount
			end
end
--check for cards that can stay on the field, but not always
function Auxiliary.RemainFieldCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(Auxiliary.RemainFieldDisabled)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)
end
function Auxiliary.RemainFieldDisabled(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsLocation(LOCATION_ONFIELD) then
		e:GetOwner():CancelToGrave(false)
	end
end
--autocheck for Summoning a Group containing Extra Deck/non-Extra Deck monsters to avoid zone issues
function Auxiliary.MainAndExtraSpSummonLoop(func,sumtype,sump,targetp,nocheck,nolimit,pos,mmz,emz)
	return	function(e,tp,eg,ep,ev,re,r,rp,sg)
				local pos=pos or POS_FACEUP
				local summonp=math.abs(sump-tp)
				local targettp=math.abs(targetp-tp)
				if Duel.GetMasterRule()>=4 then
					local cardtable={}
					local cc=sg:GetFirst()
					while cc do
						table.insert(cardtable,cc)
						cc=sg:GetNext()
					end
					local cardtableclone={table.unpack(cardtable)}
					local mmz=mmz
					if not mmz then
						mmz=0
						for i=0,4 do
							if Duel.GetLocationCount(targettp,LOCATION_MZONE,targettp,LOCATION_REASON_TOFIELD,0x1<<i)>0 then
								mmz=mmz|(0x1<<i)
							end
						end
					end
					if mmz<=0 then return false end
					local emz=emz
					if not emz then
						emz=Duel.GetLinkedZone(tp)
						if Duel.CheckLocation(targettp,LOCATION_MZONE,5) then
							emz=emz|0x20
						end
						if Duel.CheckLocation(targettp,LOCATION_MZONE,6) then
							emz=emz|0x40
						end
					end
					for _,tc in ipairs(cardtableclone) do
						table.remove(cardtable,1)
						local zone=Auxiliary.MainAndExtraGetSummonZones(tc,mmz,emz,e,sumtype,summonp,targettp,nocheck,nolimit,pos,table.unpack(cardtable))
						if zone==0 then return false end
						if not Duel.SpecialSummonStep(tc,sumtype,summonp,targettp,nocheck,nolimit,pos,zone) then return false end
						emz=emz&~(0x1<<tc:GetSequence())
						mmz=mmz&~(0x1<<tc:GetSequence())
						if func then
							func(e,tp,eg,ep,ev,re,r,rp,tc)
						end
					end
					Duel.SpecialSummonComplete()
					return true,sg
				else
					local mmz=mmz
					if not mmz then
						mmz=0x1f
					end
					local emz=emz
					if not emz then
						emz=0x1f
					end
					local tc=sg:GetFirst()
					while tc do
						local zone=tc:IsLocation(LOCATION_EXTRA) and emz or mmz
						if not Duel.SpecialSummonStep(tc,sumtype,summonp,targettp,nocheck,nolimit,pos,zone) then return false end
						if func then
							func(e,tp,eg,ep,ev,re,r,rp,tc)
						end
						tc=sg:GetNext()
					end
					Duel.SpecialSummonComplete()
					return true,sg
				end
			end
end
function Auxiliary.MainAndExtraGetSummonZones(c,mmz,emz,e,sumtype,sump,targetp,nocheck,nolimit,pos,nc,...)
	local zones=0
	if c:IsLocation(LOCATION_EXTRA) then
		for i=0,6 do
			local zone=0x1<<i
			if emz&zone==zone and c:IsCanBeSpecialSummoned(e,sumtype,sump,nocheck,nolimit,pos,targetp,zone) 
				and Auxiliary.MainAndExtraZoneCheckBool(nc,mmz&~zone,emz&~zone,e,sumtype,sump,targetp,nocheck,nolimit,pos,...) then
				zones=zones|zone
			end
		end
	else
		for i=0,4 do
			local zone=0x1<<i
			if mmz&zone==zone and c:IsCanBeSpecialSummoned(e,sumtype,sump,nocheck,nolimit,pos,targetp,zone) 
				and Auxiliary.MainAndExtraZoneCheckBool(nc,mmz&~zone,emz&~zone,e,sumtype,sump,targetp,nocheck,nolimit,pos,...) then
				zones=zones|zone
			end
		end
	end
	return zones
end
function Auxiliary.MainAndExtraZoneCheckBool(c,mmz,emz,e,sumtype,sump,targetp,nocheck,nolimit,pos,nc,...)
	if not c then return true end
	if c:IsLocation(LOCATION_EXTRA) then
		for i=0,6 do
			local zone=0x1<<i
			if emz&zone==zone and c:IsCanBeSpecialSummoned(e,sumtype,sump,nocheck,nolimit,pos,targetp,zone) 
				and Auxiliary.MainAndExtraZoneCheckBool(nc,mmz&~zone,emz&~zone,e,sumtype,sump,targetp,nocheck,nolimit,pos,...) then
				return true
			end
		end
	else
		for i=0,4 do
			local zone=0x1<<i
			if mmz&zone==zone and c:IsCanBeSpecialSummoned(e,sumtype,sump,nocheck,nolimit,pos,targetp,zone) 
				and Auxiliary.MainAndExtraZoneCheckBool(nc,mmz&~zone,emz&~zone,e,sumtype,sump,targetp,nocheck,nolimit,pos,...) then
				return true
			end
		end
	end
	return false
end
--condition for effects that make the monster change its current sequence
function Auxiliary.seqmovcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckAdjacent()
end
--operation for effects that make the monster change its current sequence
function Auxiliary.seqmovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	c:MoveAdjacent()
end

--Parameters:
-- c: the card that will receive the effect
-- extracat: optional, eventual extra categories for the effect. Adding CATEGORY_TODECK is not necessary
-- extrainfo: optional, eventual OperationInfo to be set in the target (see Nebula Neos)
-- extraop: optional, eventual operation to be performed if the card is returned to the ED (see Nebula Neos, NOT Magma Neos)
function Auxiliary.EnableNeosReturn(c,extracat,extrainfo,extraop)
	if not extracat then extracat=0 end
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK | extracat)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Auxiliary.NeosReturnCondition1)
	e1:SetTarget(Auxiliary.NeosReturnTarget(c,extrainfo))
	e1:SetOperation(Auxiliary.NeosReturnOperation(c,extraop))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(0)
	e2:SetCondition(Auxiliary.NeosReturnCondition2)
	c:RegisterEffect(e2)
end
function Auxiliary.NeosReturnCondition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnCondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Auxiliary.NeosReturnSubstituteFilter(c)
	return c:IsCode(14088859) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.NeosReturnOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local sc=Duel.GetFirstMatchingCard(Auxiliary.NecroValleyFilter(Auxiliary.NeosReturnSubstituteFilter),tp,LOCATION_GRAVE,0,nil)
		if sc and Duel.SelectYesNo(tp,aux.Stringid(14088859,0)) then
			Duel.Remove(sc,POS_FACEUP,REASON_COST)
		else
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
		if c:IsLocation(LOCATION_EXTRA) then
			local id=c:GetCode()
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,0,0,0)
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end

--Returns the zones, on the specified player's field, pointed by the specified number of Link markers. Includes Extra Monster Zones.
function Duel.GetZoneWithLinkedCount(count,tp)
	local g = Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)
	local zones = {}
	local z = {0x1,0x2,0x4,0x8,0x10,0x20,0x40}
	for _,zone in ipairs(z) do
		local ct = 0
		for tc in aux.Next(g) do
			if (zone&tc:GetLinkedZone(tp))~= 0 then
				ct = ct + 1
			end
		end
		zones[zone] = ct
	end
	local rzone = 0
	for i,ct in pairs(zones) do
		if ct >= count then
			rzone = rzone | i
		end
	end
	return rzone
end

--Checks whether a card has an effect that can add a certain type of counter
function aux.IsCounterAdded(c,counter)
	if not c.counter_add_list then return false end
	for _,ccounter in ipairs(c.counter_add_list) do
		if counter==ccounter then return true end
	end
	return false
end

--Help functions for the Salamangreats' effects
function Card.IsReincarnationSummoned(c)
	return c:GetFlagEffect(CARD_SALAMANGREAT_SANCTUARY)~=0
end
function Auxiliary.EnableCheckReincarnation(c)
	local m=_G["c"..CARD_SALAMANGREAT_SANCTUARY]
	if not m then
		m=_G["c"..c:GetCode()]
	end
	if m and not m.global_check then
		m.global_check=true
        local e1=Effect.GlobalEffect()
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_MATERIAL_CHECK)
        e1:SetValue(Auxiliary.ReincarnationCheckValue)
        local ge1=Effect.GlobalEffect()
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        ge1:SetLabelObject(e1)
        ge1:SetTargetRange(0xff,0xff)
        ge1:SetTarget(Auxiliary.ReincarnationCheckTarget)
        Duel.RegisterEffect(ge1,0)
	end
end
function Auxiliary.ReincarnationCheckTarget(e,c)
	return c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function Auxiliary.ReincarnationRitualFilter(c,rc,id,tp)
	return c:IsSummonCode(rc,SUMMON_TYPE_RITUAL,tp,id) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function Auxiliary.ReincarnationCheckValue(e,c)
	local g=c:GetMaterial()
	local id=c:GetCode()
	local tp=c:GetSummonPlayer()
	local rc=false
	if c:IsLinkMonster() then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,id)
	elseif c:IsType(TYPE_FUSION) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_FUSION,tp,id)
	elseif c:IsType(TYPE_RITUAL) then
		rc=g:IsExists(aux.ReincarnationRitualFilter,1,nil,c,id,tp)
	elseif c:IsType(TYPE_SYNCHRO) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_SYNCHRO,tp,id)
	elseif c:IsType(TYPE_XYZ) then
		rc=g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_XYZ,tp,id)
	end
	if rc then
		c:RegisterFlagEffect(CARD_SALAMANGREAT_SANCTUARY,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TEMP_REMOVE,0,1)
	end
end

--Checks for cards with different names (to be used with Aux.SelectUnselectGroup)
function Auxiliary.dncheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end

--Shortcut for functions that also check whether a card is face-up
function Auxiliary.FilterFaceupFunction(f,...)
	local params={...}
	return 	function(target)
				return target:IsFaceup() and f(target,table.unpack(params))
			end
end
--Filter for unique on field Malefic monsters
function Auxiliary.MaleficUniqueFilter(cc)
	local mt=cc:GetMetatable()
	local t= mt.has_malefic_unique or {}
	t[cc]=true
	mt.has_malefic_unique=t
	return 	function(c)
				return not Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) and c:IsSetCard(0x23)
			end
end
--Procedure for Malefic monsters' Special Summon (includes handling of Malefic Paradox Gear)
function Auxiliary.AddMaleficSummonProcedure(c,code,loc)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Auxiliary.MaleficSummonCondition(code,loc))
	e1:SetOperation(Auxiliary.MaleficSummonOperation(code,loc))
	c:RegisterEffect(e1)
end
function Auxiliary.MaleficSummonFilter(c,cd)
	return c:IsCode(cd) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MaleficSummonSubstitute(c,cd,tp)
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MaleficSummonCondition(cd,loc)
	return 	function(e,c)
				if c==nil then return true end
				return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
					and (Duel.IsExistingMatchingCard(Auxiliary.MaleficSummonFilter,c:GetControler(),loc,0,1,nil,cd)
					or Duel.IsExistingMatchingCard(Auxiliary.MaleficSummonSubstitute,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,cd,c:GetControler()))
			end
end
function Auxiliary.MaleficSummonOperation(cd,loc)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				local g=Duel.GetMatchingGroup(Auxiliary.MaleficSummonFilter,tp,loc,0,nil,cd)
				g:Merge(Duel.GetMatchingGroup(Auxiliary.MaleficSummonSubstitute,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,c:GetControler()))
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local tc=g:Select(tp,1,1,nil):GetFirst()
				if tc:IsHasEffect(48829461,tp) then tc:IsHasEffect(48829461,tp):UseCountLimit(tp) end
				Duel.Remove(tc,POS_FACEUP,REASON_COST)
			end
end
--Filter for "If a [filter] monster is Special Summoned to a zone this card points to"
--Includes non-trivial handling of self-destructing Burning Abyss monsters
function Auxiliary.zptfilter(filter)
    return function(c,ec,tp)
        if filter and not filter(c,tp) then return false end
        if c:IsLocation(LOCATION_MZONE) then
            return ec:GetLinkedGroup():IsContains(c)
        else
            return (ec:GetLinkedZone(c:GetPreviousControler())&(1<<c:GetPreviousSequence()))~=0
        end
    end
end
--Condition for "If a [filter] monster is Special Summoned to a zone this card points to"
--Includes non-trivial handling of self-destructing Burning Abyss monsters
--Passes tp so you can check control
function Auxiliary.zptcon(filter)
    return function(e,tp,eg,ep,ev,re,r,rp)
        return eg:IsExists(Auxiliary.zptfilter(filter),1,nil,e:GetHandler(),tp)
    end
end
--Discard cost for Witchcraft monsters, supports the replacements from the Continuous Spells
function Auxiliary.WitchcraftDiscardFilter(c,tp)
	return c:IsHasEffect(EFFECT_WITCHCRAFT_REPLACE,tp) and c:IsAbleToGraveAsCost()
end
function Auxiliary.WitchcraftDiscardGroup(minc)
	return	function(sg,e,tp,mg)
				if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_WITCHCRAFT_REPLACE,tp) then
					return #sg==1
				else
					return #sg>=minc
				end
			end
end
function Auxiliary.WitchcraftDiscardCost(f,minc,maxc)
	if f then f=aux.AND(f,Card.IsDiscardable) else f=Card.IsDiscardable end
	if not minc then minc=1 end
	if not maxc then maxc=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_HAND,0,minc,nil) or Duel.IsExistingMatchingCard(Auxiliary.WitchcraftDiscardFilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
				local g=Duel.GetMatchingGroup(f,tp,LOCATION_HAND,0,nil)
				g:Merge(Duel.GetMatchingGroup(Auxiliary.WitchcraftDiscardFilter,tp,LOCATION_ONFIELD,0,nil,tp))
				local sg=Auxiliary.SelectUnselectGroup(g,e,tp,1,maxc,Auxiliary.WitchcraftDiscardGroup(minc),1,tp,aux.Stringid(EFFECT_WITCHCRAFT_REPLACE,2))
				if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_WITCHCRAFT_REPLACE,tp) then
					local te=sg:GetFirst():IsHasEffect(EFFECT_WITCHCRAFT_REPLACE,tp)
					te:UseCountLimit(tp)
					Duel.SendtoGrave(sg,REASON_COST)
				else
					Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
				end
			end
end
--function to check if a card are same atribute.
function Group.CheckSameProperty(g,f,...)
	local prop
	local arg = {...}
	for tc in aux.Next(g) do
		if not prop then
			prop = f(tc,table.unpack(arg))
		else
			prop = prop & f(tc,table.unpack(arg))
		end
	end
	return prop ~= 0, prop
end
--Special Summon limit for the Evil HEROes
function Auxiliary.EvilHeroLimit(e,se,sp,st)
	local chk=SUMMON_TYPE_FUSION+0x10
	if Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_SUPREME_CASTLE) then
		chk=SUMMON_TYPE_FUSION
	end
	return st&chk==chk
end
--Functions to automate consistent start-of-duel activations for Duel Modes like Speed Duel, Sealed Duel
--According to AlphaKretin, these two functions can be improved in Edopro
function Auxiliary.EnableExtraRules(c,card,init,...)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCountLimit(1)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_NO_TURN_RESET)
    e1:SetRange(0xff)
    e1:SetOperation(Auxiliary.EnableExtraRulesOperation(card,init,...))
    c:RegisterEffect(e1)
end
function Auxiliary.EnableExtraRulesOperation(card,init,...)
    local arg = {...}
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c = e:GetHandler()
        local p = c:GetControler()
        Duel.DisableShuffleCheck()
        Duel.SendtoDeck(c, nil, -2, REASON_RULE)
        local ct = Duel.GetMatchingGroupCount(nil, p, LOCATION_HAND + LOCATION_DECK, 0, c)
        if (Duel.IsDuelType(SPEED_DUEL) and ct < 20 or ct < 40)
            and Duel.SelectYesNo(1 - p, aux.Stringid(4014, 5)) then
            Duel.Win(1 - p, 0x55)
        end
        if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(p, 1, REASON_RULE) end
        if not card.global_active_check then
            Duel.ConfirmCards(1-p, c)
            if Duel.SelectYesNo(p,aux.Stringid(4014,6)) and Duel.SelectYesNo(1-p,aux.Stringid(4014,6)) then
            	init(c,table.unpack(arg))
            end
            card.global_active_check = true
        end
    end
end
--[[Function to perform "Either add it to the hand or do X"
Required:
card: affected card to be moved; -player: player performing the operation
Optional:
check: condition for the secondary action, if not provided the default action is "Send it to the GY"; oper: secondary action; str: stirng to be used in the secondary option
]]
function Auxiliary.ToHandOrElse(card,player,check,oper,str,...)
	if card then
		if not check then check=Card.IsAbleToGrave end
		if not oper then oper=aux.thoeSend end
		if not str then str=574 end
		local b1=card:IsAbleToHand()
		local b2=check(card,...)
		local opt
		if b1 and b2 then
			opt=Duel.SelectOption(player,573,str)
		elseif b1 then
			opt=Duel.SelectOption(player,573)
		else
			opt=Duel.SelectOption(player,str)+1
		end
		if opt==0 then
			Duel.SendtoHand(card,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-player,card)
		else
			oper(card,...)
		end
	end
end
function Auxiliary.thoeSend(card)
    Duel.SendtoGrave(card,REASON_EFFECT)
end
--to simply registering EFFECT_FLAG_CLIENT_HINT to players
function Auxiliary.RegisterClientHint(card,property,tp,player1,player2,str,reset)
--card: card that creates the hintmsg
--property: additional properties like EFFECT_FLAG_OATH
--tp: the player registering the effect
--player1,player2: the players to whom the hint is registered
--str: the string called
--reset: additional resets, other than RESET_PHASE+PHASE_END
	if card then
		local eff=Effect.CreateEffect(card)
		if property then
			eff:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+property)
		else
			eff:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		end
		eff:SetTargetRange(player1,player2)
		if str then
			eff:SetDescription(str)
		else
			eff:SetDescription(aux.Stringid(card:GetOriginalCode(),1))
		end
		if reset then
			eff:SetReset(RESET_PHASE+reset)
		else
			eff:SetReset(RESET_PHASE+PHASE_END)
		end
		Duel.RegisterEffect(eff,tp)
	end
end
--for zone checking (zone is the zone, tp is referencial player)
function Auxiliary.IsZone(c,zone,tp)
	local rzone = c:IsControler(tp) and (1 <<c:GetSequence()) or (1 << (16+c:GetSequence()))
	return (rzone & zone) > 0
end
function Auxiliary.AddLavaProcedure(c,required,position,filter,value,description)
	if not required or required < 1 then
		required = 1
	end
	filter = filter or aux.TRUE
	value = value or 0
	local e1=Effect.CreateEffect(c)
	if description then
		e1:SetDescription(description)
	end
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(position,1)
	e1:SetValue(value)
	e1:SetCondition(Auxiliary.LavaCondition(required,filter))
	e1:SetTarget(Auxiliary.LavaTarget(required,filter))
	e1:SetOperation(Auxiliary.LavaOperation(required,filter))
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.LavaCheck(sg,e,tp,mg)
	return #sg==0 or Duel.GetMZoneCount(1-tp,sg,tp)>0
end
function Auxiliary.LavaCondition(required,filter)
	return function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		local mg=Duel.GetMatchingGroup(aux.AND(Card.IsReleasable,filter),tp,0,LOCATION_MZONE,nil)
		return aux.SelectUnselectGroup(mg,e,tp,required,required,Auxiliary.LavaCheck,0)
	end
end
function Auxiliary.LavaTarget(required,filter)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
		local mg=Duel.GetMatchingGroup(aux.AND(Card.IsReleasable,filter),tp,0,LOCATION_MZONE,nil)
		local g=aux.SelectUnselectGroup(mg,e,tp,required,required,Auxiliary.LavaCheck,1,tp,HINTMSG_RELEASE,Auxiliary.LavaCheck)
		if #g > 0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		else
			return false
		end
	end
end
function Auxiliary.LavaOperation(required,filter)
	return function(e,tp,eg,ep,ev,re,r,rp,c)
		local g=e:GetLabelObject()
		Duel.Release(g,REASON_COST)
		g:DeleteGroup()
	end
end
function Auxiliary.AddKaijuProcedure(c)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	local e1 = aux.AddLavaProcedure(c,1,POS_FACEUP_ATTACK)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(Auxiliary.KaijuCondition)
	c:RegisterEffect(e2)
	return e1,e2
end
function Auxiliary.KaijuCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(function(c)
											return c:IsFaceup() and c:IsSetCard(0xd3)
										end,tp,0,LOCATION_MZONE,1,nil)
end
function Auxiliary.AddValuesReset(resetfunc)
	if not Auxiliary.ToResetFuncTable then
		Auxiliary.ToResetFuncTable = {resetfunc}
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_TURN_END)
		ge:SetCountLimit(1)
		ge:SetCondition(Auxiliary.ValuesReset)
		Duel.RegisterEffect(ge,0)
	else
		table.insert(Auxiliary.ToResetFuncTable,resetfunc)
	end
end
function Auxiliary.ValuesReset()
	for _,v in pairs(Auxiliary.ToResetFuncTable) do
		v()
	end
	return false
end
function Auxiliary.GlobalCheck(s,func)
	if not s.global_check then
		s.global_check=true
		func()
	end
end
function Auxiliary.HarmonizingMagFilter(c,e,f)
	return f and not f(e,c)
end
function Auxiliary.PlayFieldSpell(c,e,tp,eg,ep,ev,re,r,rp)
	if c then
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if Duel.IsDuelType(DUEL_1_FIELD) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			of=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
			if of and Duel.Destroy(of,REASON_RULE)==0 then
				Duel.SendtoGrave(c,REASON_RULE)
				return false
			else 
				Duel.BreakEffect()
			end
		else
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then
				Duel.SendtoGrave(c,REASON_RULE)
				return false
			else 
				Duel.BreakEffect()
			end
		end
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local te=c:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=c:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(c,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		return true
	end
	return false
end

Duel.LoadScript("proc_fusion.lua")
Duel.LoadScript("proc_ritual.lua")
Duel.LoadScript("proc_synchro.lua")
Duel.LoadScript("proc_union.lua")
Duel.LoadScript("proc_xyz.lua")
Duel.LoadScript("proc_pendulum.lua")
Duel.LoadScript("proc_link.lua")
Duel.LoadScript("proc_equip.lua")
Duel.LoadScript("proc_persistent.lua")
Duel.LoadScript("proc_workaround.lua")
Duel.LoadScript("proc_damage_fix.lua")
Duel.LoadScript("proc_normal.lua")
pcall(dofile,"init.lua")
