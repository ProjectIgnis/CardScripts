Auxiliary={}
aux=Auxiliary

function GetID()
	return self_table,self_code
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

--Multi purpose token
if not c946 then
	c946 = {}
	setmetatable(c946, Card)
	c946.__tostring=Debug.CardToStringWrapper
	rawset(c946,"__index",c946)
	c946.initial_effect=function()end
end

local function cost_replace_getvalideffs(replacecode,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	local t={}
	for _,eff in ipairs({Duel.GetPlayerEffect(tp,replacecode)}) do
		if eff:CheckCountLimit(tp) then
		local val=eff:GetValue()
			if type(val)=="number" then
				if val==1 then
					table.insert(t,eff)
				end
			elseif type(val)=="function" then
				if val(eff,e,tp,eg,ep,ev,re,r,rp,chk,extracon) then
					table.insert(t,eff)
				end
			end
		end
	end
	return t
end

function Auxiliary.CostWithReplace(base,replacecode,extracon,alwaysexecute)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if alwaysexecute and not alwaysexecute(e,tp,eg,ep,ev,re,r,rp,0) then return false end
		local cost_chk=base(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then
			if cost_chk then return true end
			for _,eff in ipairs({Duel.GetPlayerEffect(tp,replacecode)}) do
				if eff:CheckCountLimit(tp) then
					local val=eff:GetValue()
					if type(val)=="number" and val==1 then return true end
					if type(val)=="function" and val(eff,e,tp,eg,ep,ev,re,r,rp,chk,extracon) then return true end
				end
			end
			return false
		end
		local effs=cost_replace_getvalideffs(replacecode,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
		if alwaysexecute then alwaysexecute(e,tp,eg,ep,ev,re,r,rp,1) end
		if not cost_chk or #effs>0 then
			local eff=effs[1]
			if #effs>1 then
				local effsPerCard={}
				local effsHandlersGroup=Group.CreateGroup()
				for _,_eff in ipairs(effs) do
					local _effCard=_eff:GetHandler()
					effsHandlersGroup:AddCard(_effCard)
					if not effsPerCard[_effCard] then effsPerCard[_effCard]={} end
					table.insert(effsPerCard[_effCard],_eff)
				end
				local effCard=nil
				if #effsHandlersGroup==1 and (not cost_chk or Duel.SelectEffectYesNo(tp,effCard)) then
					effCard=effsHandlersGroup:GetFirst()
				elseif #effsHandlersGroup>1 then
					while effCard==nil and (not cost_chk or Duel.SelectYesNo(tp,98)) do
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVEEFFECT)
						effCard=effsHandlersGroup:Select(tp,1,1,cost_chk,nil)
					end
					if effCard then effCard=effCard:GetFirst() end
				end
				if not effCard then return base(e,tp,eg,ep,ev,re,r,rp,1) end
				local effsOfThatCard=effsPerCard[effCard]
				if #effsOfThatCard==1 then
					eff=effsOfThatCard[1]
				else
					local desctable={}
					for _,_eff in ipairs(effsOfThatCard) do
						table.insert(desctable,_eff:GetDescription())
					end
					eff=effsOfThatCard[Duel.SelectOption(tp,false,table.unpack(desctable)) + 1]
				end
			elseif cost_chk and not Duel.SelectEffectYesNo(tp,eff:GetHandler()) then
				return base(e,tp,eg,ep,ev,re,r,rp,1)
			end
			local res={eff:GetOperation()(eff,e,tp,eg,ep,ev,re,r,rp,chk,extracon)}
			eff:UseCountLimit(tp)
			return table.unpack(res)
		end
		return base(e,tp,eg,ep,ev,re,r,rp,1)
	end
end


Card.IsMonster=aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER)
Card.IsSpell=aux.FilterBoolFunction(Card.IsType,TYPE_SPELL)
Card.IsTrap=aux.FilterBoolFunction(Card.IsType,TYPE_TRAP)
Card.IsSpellTrap=aux.FilterBoolFunction(Card.IsType,TYPE_SPELL|TYPE_TRAP)

local function make_exact_type_check(type)
	return aux.FilterBoolFunction(Card.IsExactType,type)
end

Card.IsQuickPlaySpell=make_exact_type_check(TYPE_SPELL|TYPE_QUICKPLAY)
Card.IsContinuousSpell=make_exact_type_check(TYPE_SPELL|TYPE_CONTINUOUS)
Card.IsEquipSpell=make_exact_type_check(TYPE_SPELL|TYPE_EQUIP)
Card.IsFieldSpell=make_exact_type_check(TYPE_SPELL|TYPE_FIELD)
Card.IsRitualSpell=make_exact_type_check(TYPE_SPELL|TYPE_RITUAL)
Card.IsLinkSpell=make_exact_type_check(TYPE_SPELL|TYPE_LINK)

Card.IsContinuousTrap=make_exact_type_check(TYPE_TRAP|TYPE_CONTINUOUS)
Card.IsCounterTrap=make_exact_type_check(TYPE_TRAP|TYPE_COUNTER)

Card.IsRitualMonster=make_exact_type_check(TYPE_MONSTER|TYPE_RITUAL)
Card.IsLinkMonster=make_exact_type_check(TYPE_MONSTER|TYPE_LINK)

function Card.IsNormalSpell(c)
	return c:GetType()==TYPE_SPELL
end

function Card.IsNormalTrap(c)
	return c:GetType()==TYPE_TRAP
end

function Card.IsNormalSpellTrap(c)
	return c:IsNormalSpell() or c:IsNormalTrap()
end
function Card.IsContinuousSpellTrap(c)
	return c:IsContinuousSpell() or c:IsContinuousTrap()
end

Card.IsEquipCard=aux.FilterBoolFunction(Card.IsType,TYPE_EQUIP)

Card.IsMonsterCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_MONSTER)
Card.IsSpellCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_SPELL)
Card.IsTrapCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_TRAP)
Card.IsSpellTrapCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_SPELL|TYPE_TRAP)

function Card.IsTrapMonster(c)
	return c:IsTrapCard() and (c:GetOriginalLevel()>0 or c:GetOriginalAttribute()>0 or c:GetOriginalRace()>0)
end

function Card.GetMainCardType(c)
	return c:GetType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP)
end


function Card.IsNonEffectMonster(c)
	return c:IsMonster() and not c:IsType(TYPE_EFFECT)
end

function Card.IsBaseAttack(c,atk)
	return c:GetBaseAttack()==atk
end
function Card.IsTextAttack(c,atk)
	return c:GetTextAttack()==atk
end
function Card.IsPreviousAttackOnField(c,atk)
	return c:GetPreviousAttackOnField()==atk
end

function Card.IsBaseDefense(c,def)
	return c:HasDefense() and c:GetBaseDefense()==def
end
function Card.IsTextDefense(c,def)
	return c:HasDefense() and c:GetTextDefense()==def
end
function Card.IsPreviousDefenseOnField(c,def)
	return c:HasDefense() and c:GetPreviousDefenseOnField()==def
end

--Returns true if the Level of "c" is between the 2 provided Levels (inclusive)
function Card.IsLevelBetween(c,first_lv,second_lv)
	if first_lv>second_lv then first_lv,second_lv=second_lv,first_lv end
	return c:IsLevelAbove(first_lv) and c:IsLevelBelow(second_lv)
end

function Card.IsOriginalLevel(c,lvl)
	return c:HasLevel() and c:GetOriginalLevel()==lvl
end
function Card.IsPreviousLevelOnField(c,lvl)
	return c:HasLevel() and c:GetPreviousLevelOnField()==lvl
end

function Card.IsOriginalRank(c,rank)
	return c:HasRank() and c:GetOriginalRank()==rank
end
function Card.IsPreviousRankOnField(c,rank)
	return c:HasRank() and c:GetPreviousRankOnField()==rank
end

function Card.IsScale(c,scale)
	return c:GetScale()==scale
end

function Card.IsNormalSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL)
end
function Card.IsTributeSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function Card.IsFlipSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_FLIP)
end
function Card.IsGeminiSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_GEMINI)
end
function Card.IsSpecialSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function Card.IsRitualSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function Card.IsFusionSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
function Card.IsSynchroSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Card.IsXyzSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
function Card.IsPendulumSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Card.IsLinkSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_LINK)
end

function Card.IsPreviousAttributeOnField(c,attr)
	return c:GetPreviousAttributeOnField()&attr>0
end
function Card.IsPreviousRaceOnField(c,race)
	return c:GetPreviousRaceOnField()&race>0
end
function Card.IsPreviousTypeOnField(c,card_type)
	return c:GetPreviousTypeOnField()&card_type>0
end
function Card.IsPreviousCodeOnField(c,...)
	local code1,code2=c:GetPreviousCodeOnField()
	local codes={...}
	for _,code in ipairs(codes) do
		if code1==code or code2==code then
			return true
		end
	end
	return false
end
function Card.IsPreviousSequence(c,seq)
	return c:GetPreviousSequence()==seq
end

function Card.IsOwner(c,player)
	return c:GetOwner()==player
end

function Card.IsBattlePosition(c,pos)
	return c:GetBattlePosition()==pos
end

function Card.HasCounter(c,counter)
	return c:GetCounter(counter)>0
end
function Card.HasEquipCard(c)
	return c:GetEquipCount()>0
end

function Card.IsDestination(c,dest)
	return c:GetDestination()==dest
end
function Card.IsLeaveFieldDest(c,dest)
	return c:GetLeaveFieldDest()==dest
end

function Card.IsFieldID(c,fid)
	return c:GetFieldID()==fid
end
function Card.IsRealFieldID(c,fid)
	return c:GetRealFieldID()==fid
end

--Returns true if the reason card of "c" is "rc"
function Card.IsReasonCard(rc,c)
	return c:GetReasonCard()==rc
end
function Card.IsReasonEffect(c,eff)
	return c:GetReasonEffect()==eff
end
function Card.IsReasonPlayer(c,player)
	return c:GetReasonPlayer()==player
end

local function setcodecondition(e)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if label>0 and c:GetOriginalCodeRule()==label then
		return c:IsCode(c:GetOriginalCodeRule())
	else
		return true
	end
end

function Card.AddSetcodesRule(c,code,copyable,...)
	local prop=0
	if not copyable then prop=EFFECT_FLAG_UNCOPYABLE end
	local t={}
	for _,setcode in pairs({...}) do
		local e=Effect.CreateEffect(c)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+prop)
		e:SetCode(EFFECT_ADD_SETCODE)
		e:SetValue(setcode)
		e:SetLabel(code)
		e:SetCondition(setcodecondition)
		c:RegisterEffect(e)
		table.insert(t,e)
	end
	return t
end

function Card.CheckAdjacent(c)
	local p=c:GetControler()
	local seq=c:GetSequence()
	if seq>4 then return false end
	return (seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1))
end

function Card.SelectAdjacent(c,sel_player)
	local seq=c:GetSequence()
	if seq>4 then return end
	local flag=0
	local targ_player=c:GetControler()
	if seq>0 and Duel.CheckLocation(targ_player,LOCATION_MZONE,seq-1) then flag=flag|(0x1<<seq-1) end
	if seq<4 and Duel.CheckLocation(targ_player,LOCATION_MZONE,seq+1) then flag=flag|(0x1<<seq+1) end
	if flag==0 then return end
	local sel_player=sel_player==nil and targ_player or sel_player
	local loc1=targ_player==sel_player and LOCATION_MZONE or 0
	local loc2=loc1==0 and LOCATION_MZONE or 0
	local shift=loc2*4
	Duel.Hint(HINT_SELECTMSG,sel_player,HINTMSG_TOZONE)
	local zone=(Duel.SelectDisableField(sel_player,1,loc1,loc2,~(flag<<shift)))>>shift
	Duel.Hint(HINT_ZONE,targ_player,zone)
	return math.log(zone,2)
end

function Card.MoveAdjacent(c,sel_player)
	local seq=c:GetSequence()
	if seq>4 then return end
	local flag=0
	local targ_player=c:GetControler()
	if seq>0 and Duel.CheckLocation(targ_player,LOCATION_MZONE,seq-1) then flag=flag|(0x1<<seq-1) end
	if seq<4 and Duel.CheckLocation(targ_player,LOCATION_MZONE,seq+1) then flag=flag|(0x1<<seq+1) end
	if flag==0 then return end
	local sel_player=sel_player==nil and targ_player or sel_player
	local loc1=targ_player==sel_player and LOCATION_MZONE or 0
	local loc2=loc1==0 and LOCATION_MZONE or 0
	local shift=loc2*4
	Duel.Hint(HINT_SELECTMSG,sel_player,HINTMSG_TOZONE)
	local zone=Duel.SelectDisableField(sel_player,1,loc1,loc2,~(flag<<shift))
	Duel.MoveSequence(c,math.log(zone>>shift,2))
end

function Card.IsColumn(c,seq,tp,loc)
	if not c:IsOnField() then return false end
	local cseq=c:GetSequence()
	local seq=seq
	local loc=loc or c:GetLocation()
	local tp=tp or c:GetControler()
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
		if seq==6 then seq=5 end
	end
	if c:IsControler(tp) then
		return cseq==seq
	else
		return cseq==4-seq
	end
end

function Card.UpdateAttack(c,amt,reset,rc)
	rc=rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset or RESET_EVENT+r
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
	rc=rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset or RESET_EVENT+r
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
	rc=rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset or RESET_EVENT+r
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
	rc=rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset or RESET_EVENT+r
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
	rc=rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset or RESET_EVENT+r
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
	rc=rc or c
	local r=(c==rc) and RESETS_STANDARD_DISABLE or RESETS_STANDARD
	reset=reset or RESET_EVENT+r
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
	elseif tc:IsLocation(LOCATION_SZONE) and tc:IsControler(tp) then
		if c:IsLinkMarker(LINK_MARKER_BOTTOM_LEFT) and seq < 4 and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP_RIGHT)) then zone=zone|(1<<(seq+1)) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM) and seq <= 4 and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP)) then zone=zone|(1<<seq) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM_RIGHT) and seq > 0 and seq <= 4 and (not clink or tc:IsLinkMarker(LINK_MARKER_TOP_LEFT)) then zone=zone(1<<(seq-1)) end
	end
	return zone
end

function Card.GetScale(c)
	if not c:IsType(TYPE_PENDULUM) then return 0 end
	local sc=0
	if c:IsLocation(LOCATION_PZONE) then
		local seq=c:GetSequence()
		if seq==0 --mr4+ pzones
		or seq==1 --three columns field pzones
		or seq==6 --mr3 pzones
		then sc=c:GetLeftScale() else sc=c:GetRightScale() end
	else
		sc=c:GetLeftScale()
	end
	return sc
end

function Card.IsOddScale(c)
	if not c:IsType(TYPE_PENDULUM) then return false end
	return c:GetScale() % 2 ~= 0
end

function Card.IsEvenScale(c)
	if not c:IsType(TYPE_PENDULUM) then return false end
	return c:GetScale() % 2 == 0
end

function Card.CanSummonOrSet(...)
	return Card.IsSummonable(...) or Card.IsMSetable(...)
end

function Card.IsBattleDestroyed(c)
	return c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsReason(REASON_BATTLE)
end

function Card.IsInMainMZone(c,tp)
	return c:IsLocation(LOCATION_MMZONE) and (not tp or c:IsControler(tp))
end

function Card.IsInExtraMZone(c,tp)
	return c:IsLocation(LOCATION_EMZONE) and (not tp or c:IsControler(tp))
end

function Card.AnnounceAnotherAttribute(c,tp)
	local att=c:GetAttribute()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	return Duel.AnnounceAttribute(tp,1,att&(att-1)==0 and (~att&ATTRIBUTE_ALL) or ATTRIBUTE_ALL)
end

--Returns true if "c" has any Attribute except "att"
function Card.IsAttributeExcept(c,att,scard,sumtype,playerid)
	sumtype=sumtype==nil and 0 or sumtype
	playerid=playerid==nil and PLAYER_NONE or playerid
	local _att=c:GetAttribute(scard,sumtype,playerid)
	return (_att&att)~=_att
end

function Card.AnnounceAnotherRace(c,tp)
	local race=c:GetRace()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	return Duel.AnnounceRace(tp,1,race&(race-1)==0 and (~race&RACE_ALL) or RACE_ALL)
end

function Card.IsDifferentRace(c,race)
	local _race=c:GetRace()
	return (_race&race)~=_race
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

--Checks wheter a card has a level or not
--For Links: false. For Xyzs: false, except if affected by  "EFFECT_RANK_LEVEL..." effects
--For Dark Synchros: true, because they have a negative level. For level 0: true, because 0 is a value
function Card.HasLevel(c)
	if c:IsMonster() then
		return c:GetType()&TYPE_LINK~=TYPE_LINK
			and (c:GetType()&TYPE_XYZ~=TYPE_XYZ and not (c:IsHasEffect(EFFECT_RANK_LEVEL) or c:IsHasEffect(EFFECT_RANK_LEVEL_S)))
			and not c:IsStatus(STATUS_NO_LEVEL)
	elseif c:IsOriginalType(TYPE_MONSTER) then
		return not (c:IsOriginalType(TYPE_XYZ+TYPE_LINK) or c:IsStatus(STATUS_NO_LEVEL))
	end
	return false
end
--Returns true if the card "c" has a Rank
function Card.HasRank(c)
	if c:IsMonster() then
		return c:IsType(TYPE_XYZ) or (c:HasLevel() and (c:IsHasEffect(EFFECT_LEVEL_RANK) or c:IsHasEffect(EFFECT_LEVEL_RANK_S)))
	elseif c:IsOriginalType(TYPE_MONSTER) then
		return c:IsOriginalType(TYPE_XYZ)
	end
	return false
end
--Returns true if the card "c" has DEF
function Card.HasDefense(c)
	if c:IsMonster() then
		return not (c:IsType(TYPE_LINK) or c:IsMaximumMode())
	elseif c:IsOriginalType(TYPE_MONSTER) then
		return not c:IsOriginalType(TYPE_LINK)
	end
	return false
end

--Returns true if the Card "c" has the flag effect with code "id"
function Card.HasFlagEffect(c,id,ct)
	return c:GetFlagEffect(id)>=(ct or 1)
end
--Returns true if the player "tp" has the flag effect with code "id"
function Duel.HasFlagEffect(tp,id,ct)
	return Duel.GetFlagEffect(tp,id)>=(ct or 1)
end

--Negates the effect of the selected card.
--Useful to reduce clutter with effects like "but its effects are negated".
function Card.NegateEffects(tc,c,reset,negates_cards,ct)
	if not reset then reset=RESET_EVENT|RESETS_STANDARD end
	reset=reset|(RESET_EVENT|RESETS_STANDARD)
	local trap_monster_chk=negates_cards and tc:IsType(TYPE_TRAPMONSTER)
	if trap_monster_chk then reset=reset&~(RESET_TOFIELD|RESET_LEAVE|RESET_TURN_SET) end
	if not ct then ct=1 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	--Negate its effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(reset,ct)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	if trap_monster_chk then
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		tc:RegisterEffect(e3)
	end
end

function Card.GetMetatable(c,currentCode)
	if currentCode then return _G["c" .. c:GetCode()] end
	return c.__index
end

function Duel.GetMetatable(code)
	return _G["c" .. code]
end

-- Load the target's card metatable in the duel, and makes so that
-- the current loaded one gets replaced by it.
-- This will basically make the script that called this function behave
-- like script loading for alt arts work
function Duel.LoadCardScriptAlias(code)
	for key in pairs(self_table) do
		if key~="__index" and key~="__tostring" then
			error("Duel.LoadCardScriptAlias must be called in an empty script context",2)
		end
	end
	local newtable=Duel.LoadCardScript(code)
	rawset(self_table,"__index",newtable)
	_G["c"..self_code] = newtable
end

function Duel.LoadCardScript(code)
	if type(code)=="number" then
		code="c"..code..".lua"
	elseif type(code)~="string" then
		error("Parameter 1 should be \"number\" or \"string\"",2)
	end
	local card=string.sub(code,0,string.len(code)-4)
	if not _G[card] then
		local oldtable,oldcode=GetID()
		_G[card] = {}
		self_table=_G[card]
		setmetatable(self_table, Card)
		rawset(self_table,"__index",self_table)
		self_table.__tostring=Debug.CardToStringWrapper
		self_code=tonumber(string.sub(card,2))
		Duel.LoadScript(code)
		self_table=oldtable
		self_code=oldcode
	end
	return _G[card]
end


function Effect.IsMonsterEffect(e)
	return e:IsActiveType(TYPE_MONSTER)
end

function Effect.IsSpellEffect(e)
	return e:IsActiveType(TYPE_SPELL)
end

function Effect.IsTrapEffect(e)
	return e:IsActiveType(TYPE_TRAP)
end

function Effect.IsSpellTrapEffect(e)
	return e:IsActiveType(TYPE_SPELL|TYPE_TRAP)
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
	assert(f+w<=64,"trying to access non-existent bits")
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

function Auxiliary.Stringid(code,id)
	return (id&0xfffff)|code<<20
end

function Group.ForEach(g,f,...)
	for tc in aux.Next(g) do
		f(tc,...)
	end
end

function Auxiliary.Next(g)
	local first=true
	return	function()
				if first then first=false return g:GetFirst()
				else return g:GetNext() end
			end
end
Group.Iter=Auxiliary.Next

--used for Material Types Filter Bool (works for IsRace, IsAttribute, IsType)
function Auxiliary.FilterSummonCode(...)
	local params={...}
	return	function(c,scard,sumtype,tp)
				return c:IsSummonCode(scard,sumtype,tp,table.unpack(params))
			end
end

local function GetMulti(tab,key,...)
	if not key then return nil end
	return (tab[key]~=nil and tab[key]) or GetMulti(tab,...)
end
function Auxiliary.ParamsFromTable(tab,key,...)
	if key then
		local val
		if type(key)=="table" then
			val=GetMulti(tab,table.unpack(key))
		else
			val=tab[key]
		end
		if ... then
			return val,Auxiliary.ParamsFromTable(tab,...)
		else
			if key == "vaargs" and type(val)=="table" then
				return table.unpack(val)
			end
			return val
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
		if te:CheckCountLimit(tp) then
			local eg=te:GetValue()(0,summon_type,te,tp,sc)-mustg
			eg:KeepAlive()
			tg=tg+eg
			local efun=te:GetOperation() or aux.TRUE
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
		local val=type(te:GetValue())=='function' and te:GetValue()(te,eg,sump,sc,g) or te:GetValue()
		if val&r>0 then
			sg:AddCard(te:GetHandler())
		end
	end
	return sg
end

--for additional registers
Card.RegisterEffect=(function()
	local oldf=Card.RegisterEffect
	local function map_to_effect_code(val)
		if val==1 then return 511002571 end -- access to effects that activate that detach an Xyz Material as cost
		if val==2 then return 511001692 end -- access to Cardian Summoning conditions/effects
		if val==4 then return  12081875 end -- access to Thunder Dragon effects that activate by discarding
		if val==8 then return 511310036 end -- access to Allure Queen effects that activate by sending themselves to GY
		if val==16 then return 58858807 end -- access to tellarknights/constellar effects that activate when Normal Summoned
		if val==32 then return 4965193 end -- access to Dragon Ruler effects that activate by discarding
		return nil
	end
	return function(c,e,forced,...)
		local reg_e=oldf(c,e,forced)
		if not reg_e or reg_e<=0 then return reg_e end
		local resetflag,resetcount=e:GetReset()
		for _,val in ipairs{...} do
			local code=map_to_effect_code(val)
			if code then
				local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
				if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
				e2:SetCode(code)
				e2:SetLabelObject(e)
				e2:SetLabel(c:GetOriginalCode())
				if resetflag and resetcount then
					e2:SetReset(resetflag,resetcount)
				elseif resetflag then
					e2:SetReset(resetflag)
				end
				c:RegisterEffect(e2)
			end
		end
		return reg_e
	end
end)()

function Card.ListsCodeAsMaterial(c,...)
	if not c.material then return false end
	local codes={...}
	for _,code in ipairs(codes) do
		for _,mcode in ipairs(c.material) do
			if code==mcode then return true end
		end
	end
	return false
end
local function MatchSetcode(set_code,to_match)
	return (set_code&0xfff)==(to_match&0xfff) and (set_code&to_match)==set_code;
end
function Card.ListsArchetypeAsMaterial(c,...)
	if not c.material_setcode then return false end
	local setcodes={...}
	for _,setcode in ipairs(setcodes) do
		if type(c.material_setcode)=='table' then
			for _,v in ipairs(c.material_setcode) do
				if MatchSetcode(setcode,v) then return true end
			end
		else
			if MatchSetcode(setcode,c.material_setcode) then return true end
		end
	end
	return false
end
--Returns true if the Card "c" specifically lists any of the card IDs in "..."
function Card.ListsCode(c,...)
	if c.listed_names then
		local codes={...}
		for _,wanted in ipairs(codes) do
			for _,cardcode in ipairs(c.listed_names) do
				if wanted==cardcode then return true end
			end
		end
	elseif c.fit_monster then
		local codes={...}
		for _,wanted in ipairs(codes) do
			for _,listed in ipairs(c.fit_monster) do
				if wanted==listed then return true end
			end
		end
	end
	return false
end
--Returns true if the Card "c" specifically lists the name of a card that is part of an archetype in "..."
function Card.ListsCodeWithArchetype(c,...)
	if not c.listed_names then return false end
	local setcodes={...}
	for _,cardcode in ipairs(c.listed_names) do
		local match_setcodes={Duel.GetCardSetcodeFromCode(cardcode)}
		if #match_setcodes>0 then
			for _,setcode in ipairs(setcodes) do
				for _,to_match in ipairs(match_setcodes) do
					if MatchSetcode(setcode,to_match) then return true end
				end
			end
		end
	end
	return false
end
--Returns true if the Card "c" specifically lists any of the card types in "..."
function Card.ListsCardType(c,...)
	if not c.listed_card_types then return false end
	local card_types={...}
	for _,typ in ipairs(card_types) do
		for _,typp in ipairs(c.listed_card_types) do
			if (typ&typp)~=0 then return true end
		end
	end
	return false
end
--Returns true if the Card "c" lists any of the setcodes passed in "..."
function Card.ListsArchetype(c,...)
	if not c.listed_series then return false end
	local listed_archetypes={...}
	for _,wanted in ipairs(listed_archetypes) do
		for _,listed in ipairs(c.listed_series) do
			if wanted==listed then return true end
		end
	end
	return false
end
--"Can be negated" check for monsters
function Card.IsNegatableMonster(c)
	return c:IsFaceup() and not c:IsDisabled() and (not c:IsNonEffectMonster() or c:GetOriginalType()&TYPE_EFFECT~=0)
end
--"Can be negated" check for Spells/Traps
function Card.IsNegatableSpellTrap(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsSpellTrap()
end
--"Can be negated" check for cards
function Card.IsNegatable(c)
	return c:IsNegatableMonster() or c:IsNegatableSpellTrap()
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
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
--condition of EVENT_BATTLE_DESTROYING + opponent monster + to_grave
function Auxiliary.bdogcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
--condition of EVENT_TO_GRAVE + destroyed_by_opponent_from_field
function Auxiliary.dogcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and rp==1-tp
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
--filter for non-zero ATK monsters
function Card.HasNonZeroAttack(c)
	return c:IsFaceup() and c:GetAttack()>0
end
--filter for non-zero DEF monsters
function Card.HasNonZeroDefense(c)
	return c:IsFaceup() and c:GetDefense()>0
end
--flag effect for summon/sp_summon turn
function Auxiliary.sumreg(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	for tc in aux.Next(eg) do
		if tc:GetOriginalCode()==code then
			tc:RegisterFlagEffect(code,RESETS_STANDARD_PHASE_END,0,1)
		end
	end
end
function Auxiliary.sumlimit(sumtype)
	return function(e,se,sp,st)
		return (st&sumtype)==sumtype
	end
end
--sp_summon condition for fusion monster
function Auxiliary.fuslimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_FUSION)(e,se,sp,st)
end
--sp_summon condition for ritual monster
function Auxiliary.ritlimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_RITUAL)(e,se,sp,st)
end
--sp_summon condition for synchro monster
function Auxiliary.synlimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_SYNCHRO)(e,se,sp,st)
end
--sp_summon condition for xyz monster
function Auxiliary.xyzlimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_XYZ)(e,se,sp,st)
end
--sp_summon condition for pendulum monster
function Auxiliary.penlimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_PENDULUM)(e,se,sp,st)
end
--sp_summon condition for link monster
function Auxiliary.lnklimit(e,se,sp,st)
	return aux.sumlimit(SUMMON_TYPE_LINK)(e,se,sp,st)
end

--Registers a "Cannot be Special Summoned" Summoning condition to card "c"
function Card.AddCannotBeSpecialSummoned(c)
	--Cannot be Special Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	return e0
end

--Registers a "Must be X Summoned" Summoning condition to card "c"
Card.AddMustBeSpecialSummoned=Card.AddCannotBeSpecialSummoned

function Card.AddMustBeSpecialSummonedByCardEffect(c)
	--Must be Special Summoned by card effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return sum_eff:IsHasType(EFFECT_TYPE_ACTIONS) end)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustBeRitualSummoned(c)
	--Must be Ritual Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustBeFusionSummoned(c)
	--Must be Fusion Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustBeSynchroSummoned(c)
	--Must be Synchro Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustBeXyzSummoned(c)
	--Must be Xyz Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.xyzlimit)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustBePendulumSummoned(c)
	--Must be Pendulum Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.penlimit)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustBeLinkSummoned(c)
	--Must be Link Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.lnklimit)
	c:RegisterEffect(e0)
	return e0
end
--Registers a "Must first be X Summoned" Summoning condition to card "c"
function Card.AddMustFirstBeRitualSummoned(c)
	--Must first be Ritual Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return e:GetHandler():IsStatus(STATUS_PROC_COMPLETE) or (sum_type&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL end)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustFirstBeFusionSummoned(c)
	--Must first be Fusion Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sum_type&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION end)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustFirstBeSynchroSummoned(c)
	--Must first be Synchro Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sum_type&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO end)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustFirstBeXyzSummoned(c)
	--Must first be Xyz Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sum_type&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ end)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustFirstBePendulumSummoned(c)
	--Must first be Pendulum Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return e:GetHandler():IsStatus(STATUS_PROC_COMPLETE) or (sum_type&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM end)
	c:RegisterEffect(e0)
	return e0
end
function Card.AddMustFirstBeLinkSummoned(c)
	--Must first be Link Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sum_type&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK end)
	c:RegisterEffect(e0)
	return e0
end

--value for EFFECT_CANNOT_BE_MATERIAL
function Auxiliary.cannotmatfilter(val1,...)
	local allowed=val1
	if type(val1)~="table" then allowed={val1,...} end
	local tot=0
	for _,val in pairs(allowed) do
		tot = tot|val
	end
	return function(e,c,sumtype,tp)
		local sum=tot&sumtype
		for _,val in pairs(allowed) do
			if sum==val then return true end
		end
		return false
	end
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

function Auxiliary.BeginPuzzle()
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

function Auxiliary.StatChangeDamageStepCondition()
	return not (Duel.IsPhase(PHASE_DAMAGE) and Duel.IsDamageCalculated())
end

--Functions for commonly used costs:
Cost={}

function Cost.SelfBanish(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function Cost.SelfTribute(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function Cost.SelfToGrave(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function Cost.SelfToHand(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHandAsCost() end
	Duel.SendtoHand(c,nil,REASON_COST)
end
function Cost.SelfToDeck(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Cost.SelfToExtra(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Cost.SelfDiscard(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_DISCARD|REASON_COST)
end
function Cost.SelfDiscardToGrave(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_DISCARD|REASON_COST)
end
function Cost.SelfReveal(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
end
--Aliases for historical reasons:
Cost.SelfRelease=Cost.SelfTribute
Auxiliary.bfgcost=Cost.SelfBanish

function Cost.Discard(filter,other,count)
	count=count or 1
	filter=filter and aux.AND(filter,Card.IsDiscardable) or Card.IsDiscardable
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local exclude=other and e:GetHandler() or nil
		if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,LOCATION_HAND,0,count,exclude) end
		Duel.DiscardHand(tp,filter,count,count,REASON_COST|REASON_DISCARD,exclude)
	end
end
-- "Detach Xyz Material Cost Generator"
-- Generates a function to be used by Effect.SetCost in order to detach
-- a number of Xyz Materials from the Effect's handler.
-- `min` minimum number of materials to check for detachment.
-- `max` maximum number of materials to detach or a function that gets called
-- as if by doing max(e,tp) in order to get the value of max detachments.
-- `op` optional function that gets called by passing the effect and the operated
-- group of just detached materials in order to do some additional handling with
-- them.
function Cost.Detach(min,max,op)
	max=max or min
	do --Perform some sanity checks, simplifies debugging
		local max_type=type(max)
		local op_type=type(op)
		if type(min)~="number" then
			error("Parameter 1 should be an Integer",2)
		end
		if max_type~="number" and max_type~="function" then
			error("Parameter 2 should be Integer|function",2)
		end
		if op_type~="nil" and op_type~="function" then
			error("Parameter 2 should be nil|function",2)
		end
	end
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local nn=c:IsSetCard(SET_NUMERON) and c:IsType(TYPE_XYZ) and Duel.IsPlayerAffectedByEffect(tp,CARD_NUMERON_NETWORK)
		local crm=c:CheckRemoveOverlayCard(tp,min,REASON_COST)
		if chk==0 then return (nn and c:IsLocation(LOCATION_MZONE)) or crm end
		if nn and (not crm or Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1))) then
			--Do not execute `op`, hint at "Numeron Network" being applied
			return Duel.Hint(HINT_CARD,tp,CARD_NUMERON_NETWORK)
		end
		local m=type(max)=="number" and max or max(e,tp)
		if c:RemoveOverlayCard(tp,min,m,REASON_COST)>0 and op then
			op(e,Duel.GetOperatedGroup())
		end
	end
end

--Default cost for "You can pay X LP;"
function Cost.PayLP(lp_value,pay_until)
	if not pay_until then
		if lp_value>=1 then
			--Pay X LP, where X is any number equal to or higher than 1
			return function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.CheckLPCost(tp,lp_value) end
				Duel.PayLPCost(tp,lp_value)
			end
		else
			--Pay a fraction of your LP (half, one third, etc)
			return function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*lp_value))
			end
		end
	else
		--Pay LP so that you have X left
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			local pay_lp_value=math.floor(Duel.GetLP(tp)-lp_value)
			if chk==0 then return pay_lp_value>0 and Duel.CheckLPCost(tp,pay_lp_value) end
			Duel.PayLPCost(tp,pay_lp_value)
		end
	end
end

function Cost.SoftOncePerChain(flag)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return not c:HasFlagEffect(flag) end
		c:RegisterFlagEffect(flag,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	end
end

function Cost.HardOncePerChain(flag)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return not Duel.HasFlagEffect(tp,flag) end
		Duel.RegisterFlagEffect(tp,flag,RESET_CHAIN,0,1)
	end
end

function Cost.AND(...)
	local fns={...}
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		--when checking, stop at the first falsy value
		if chk==0 then
			for _,fn in ipairs(fns) do
				if not fn(e,tp,eg,ep,ev,re,r,rp,0) then return false end
			end
			return true
		end
		--when executing, run all functions regardless of what they return
		for _,fn in ipairs(fns) do
			fn(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end


function Card.EquipByEffectLimit(e,c)
	if e:GetOwner()~=c then return false end
	local eff={c:GetCardEffect(89785779+EFFECT_EQUIP_LIMIT)}
	for _,te in ipairs(eff) do
		if te==e:GetLabelObject() then return true end
	end
	return false
end
--register for "Equip to this card by its effect"
function Card.EquipByEffectAndLimitRegister(c,e,tp,tc,code,mustbefaceup)
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
	e1:SetValue(Card.EquipByEffectLimit)
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
		dbdmin[i]=aux//(10^mi)
		aux=aux%(10^mi)
		mi=mi-1
	end
	aux=max
	mi=maxdc-1
	for i=1,maxdc do
		dbdmax[i]=aux//(10^mi)
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

function Group.GetLinkedZone(g,tp)
	return g:GetBitwiseOr(Card.GetLinkedZone,tp)
end

function Group.GetToBeLinkedZone(g,c,tp,clink,emz)
	return g:GetBitwiseOr(Card.GetToBeLinkedZone,c,tp,clink,emz)
end

function Duel.AnnounceAnotherAttribute(g,tp)
	local att=g:GetBitwiseOr(Card.GetAttribute)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	return Duel.AnnounceAttribute(tp,1,att&(att-1)==0 and (~att&ATTRIBUTE_ALL) or ATTRIBUTE_ALL)
end

function Duel.AnnounceAnotherRace(g,tp)
	local race=g:GetBitwiseOr(Card.GetRace)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	return Duel.AnnounceRace(tp,1,race&(race-1)==0 and (~race&RACE_ALL) or RACE_ALL)
end

function Auxiliary.ResetEffects(g,eff)
	for c in aux.Next(g) do
		local effs={c:GetCardEffect(eff)}
		for _,v in ipairs(effs) do
			v:Reset()
		end
	end
end

--utility entry for SelectUnselect loops
--returns bool if chk==0, returns Group if chk==1
function Auxiliary.SelectUnselectLoop(c,sg,mg,e,tp,minc,maxc,rescon)
	local res=not rescon
	if #sg>=maxc then return false end
	sg:AddCard(c)
	if rescon then
		local stop
		res,stop=rescon(sg,e,tp,mg,c)
		if stop then
			sg:RemoveCard(c)
			return false
		end
	end
	if #sg<minc then
		res=mg:IsExists(Auxiliary.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	elseif #sg<maxc and not res then
		res=mg:IsExists(Auxiliary.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)
	local minc=minc or 1
	local maxc=maxc or #g
	if chk==0 then
		if #g<minc then return false end
		local eg=g:Clone()
		for c in g:Iter() do
			if Auxiliary.SelectUnselectLoop(c,Group.CreateGroup(),eg,e,tp,minc,maxc,rescon) then return true end
			eg:RemoveCard(c)
		end
		return false
	end
	local hintmsg=hintmsg or 0
	local sg=Group.CreateGroup()
	while true do
		local finishable = #sg>=minc and (not finishcon or finishcon(sg,e,tp,g))
		local mg=g:Filter(Auxiliary.SelectUnselectLoop,sg,sg,g,e,tp,minc,maxc,rescon)
		if (breakcon and breakcon(sg,e,tp,mg)) or #mg<=0 or #sg>=maxc then break end
		Duel.Hint(HINT_SELECTMSG,seltp,hintmsg)
		local tc=mg:SelectUnselect(sg,seltp,finishable,finishable or (cancelable and #sg==0),minc,maxc)
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
	end
	return sg
end
--check for Free Monster Zones
function Auxiliary.ChkfMMZ(sumcount)
	return	function(sg,e,tp,mg)
				return Duel.GetMZoneCount(tp,sg)>=sumcount
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
--where the new sequence is choosen during resolution
function Auxiliary.seqmovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	c:MoveAdjacent()
end
--target for effects that make the monster change its current sequence
--where the new sequence is choosen at target time
function Auxiliary.seqmovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(e:GetHandler():SelectAdjacent())
end
--operation for effects that make the monster change its current sequence
--where the new sequence is choosen at target time
function Auxiliary.seqmovtgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	Duel.MoveSequence(c,seq)
end


function Duel.MoveToDeckTop(obj)
	local typ=type(obj)
	if typ=="Group" then
		for c in aux.Next(obj:Filter(Card.IsLocation,nil,LOCATION_DECK)) do
			Duel.MoveSequence(c,SEQ_DECKTOP)
		end
	elseif typ=="Card" then
		if obj:IsLocation(LOCATION_DECK) then
			Duel.MoveSequence(obj,SEQ_DECKTOP)
		end
	else
		error("Parameter 1 should be \"Card\" or \"Group\"",2)
	end
end

function Duel.MoveToDeckBottom(obj,tp)
	local typ=type(obj)
	if typ=="number" then
		if type(tp)~="number" then
			error("Parameter 2 should be \"number\"",2)
		end
		for i=1,obj do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	elseif typ=="Group" then
		for c in aux.Next(obj:Filter(Card.IsLocation,nil,LOCATION_DECK)) do
			Duel.MoveSequence(c,SEQ_DECKBOTTOM)
		end
	elseif typ=="Card" then
		if obj:IsLocation(LOCATION_DECK) then
			Duel.MoveSequence(obj,SEQ_DECKBOTTOM)
		end
	else
		error("Parameter 1 should be \"Card\" or \"Group\" or \"number\"",2)
	end
end

function Duel.GetTargetCards(e)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return tg and tg:Filter(Card.IsRelateToEffect,nil,e) or nil
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
		[RACE_CYBERSE] = 1044,
		[RACE_ILLUSION] = 1045
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

function Auxiliary.GetCoinEffectHintString(coin)
	if coin==COIN_HEADS then
		return 62
	elseif coin==COIN_TAILS then
		return 63
	end
end
function Auxiliary.GetCoinCountFromEv(ev)
	return ev&0xff
end
function Auxiliary.GetCoinHeadsFromEv(ev)
	return (ev>>8)&0xff
end
function Auxiliary.GetCoinTailsFromEv(ev)
	return (ev>>16)&0xff
end
function Auxiliary.GetDiceCountSelfFromEv(ev)
	return ev&0xffff
end
function Auxiliary.GetDiceCountOppoFromEv(ev)
	return (ev>>16)&0xffff
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
--Checks whether a card (c) has an effect that mentions a certain type of counter
--This includes adding, removing, gaining ATK/DEF per counter, etc.
function Card.ListsCounter(c,counter_type)
	if c.counter_list then
		for _,ccounter in ipairs(c.counter_list) do
			if counter_type==ccounter then return true end
		end
	elseif c.counter_place_list then
		--if it places counters, it always lists them
		for _,ccounter in ipairs(c.counter_place_list) do
			if counter_type==ccounter then return true end
		end
	end
	return false
end
--Checks whether a card (c) has an effect that places a certain type of counter
function Card.PlacesCounter(c,counter_type)
	if not c.counter_place_list then return false end
	for _,ccounter in ipairs(c.counter_place_list) do
		if counter_type==ccounter then return true end
	end
	return false
end

--Checks for cards with different properties (to be used with Aux.SelectUnselectGroup)
function Auxiliary.dpcheck(fun)
	return function(sg,e,tp,mg)
		local c1=sg:GetClassCount(fun)
		local c2=#sg
		return c1==c2,c1~=c2
	end
end
--Checks for cards with different names (to be used with Aux.SelectUnselectGroup)
Auxiliary.dncheck=Auxiliary.dpcheck(Card.GetCode)

--Shortcut for functions that also check whether a card is face-up
function Auxiliary.FaceupFilter(f,...)
	local params={...}
	return 	function(target)
				return target:IsFaceup() and f(target,table.unpack(params))
			end
end
--Filter for "If a [filter] monster is Special Summoned to a zone this card points to"
--Includes non-trivial handling of self-destructing Burning Abyss monsters
function Auxiliary.zptgroup(eg,filter,c,tp)
	local fil=eg:Filter(function(cc)return not filter or filter(cc,tp) end,nil)
	return (fil&c:GetLinkedGroup()) + eg:Filter(Auxiliary.zptfilter,nil,c)
end
function Auxiliary.zptgroupcon(eg,filter,c,tp)
	local fil=eg:Filter(function(cc)return not filter or filter(cc,tp) end,nil)
	return #(fil&c:GetLinkedGroup())>0 or eg:IsExists(Auxiliary.zptfilter,1,nil,c)
end
function Auxiliary.zptfilter(c,ec)
	return not c:IsLocation(LOCATION_MZONE) and (ec:GetLinkedZone(c:GetPreviousControler())&(1<<c:GetPreviousSequence()))~=0
end
--Condition for "If a [filter] monster is Special Summoned to a zone this card points to"
--Includes non-trivial handling of self-destructing Burning Abyss monsters
--Passes tp so you can check control
function Auxiliary.zptcon(filter)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Auxiliary.zptgroupcon(eg,filter,e:GetHandler(),tp)
	end
end
--function to check if all the cards in a group have a common property
function Group.CheckSameProperty(g,f,...)
	local prop=nil
	for tc in aux.Next(g) do
		prop = prop and (prop&f(tc,...)) or f(tc,...)
		if prop==0 then return false,0 end
	end
	return prop~=0, prop
end
local function checkrecbin(c,g,val,f,...)
	local prop=f(c,...)&(~val)
	if prop==0 then return false end
	local i=1
	while i<=prop do
		if prop&i~=0 then
			if #g<2 or g:IsExists(checkrecbin,1,c,g-c,val|i,f,...) then return true end
		end
		i=i<<1
	end
	return false
end
--function to check if every card in a group has at least a different property from the others
--with a function that stores the properties in binary form
function Group.CheckDifferentPropertyBinary(g,f,...)
	if #g<2 then return true end
	return g:IsExists(checkrecbin,1,nil,g,0,f,...)
end
local function checkrec(c,g,t,f,...)
	for _,prop in ipairs({f(c,...)}) do
		if not t[prop] then
			t[prop]=true
			if #g<2 or g:IsExists(checkrec,1,c,g-c,t,f,...) then return true end
			t[prop]=nil
		end
	end
	return false
end
--function to check if every card in a group has at least a different property from the others
--with a function that stores the properties in multiple returns form
function Group.CheckDifferentProperty(g,f,...)
	if #g<2 then return true end
	return g:IsExists(checkrec,1,nil,g,{},f,...)
end
function Auxiliary.PropertyTableFilter(f,...)
	local cachetab={}
	local truthtable={}
	for _,elem in pairs({...}) do
		truthtable[elem]=true
	end
	return function(c,...)
		if not cachetab[c] then
			cachetab[c]={}
			for _,val in pairs({f(c,...)}) do
				if truthtable[val] then
					table.insert(cachetab[c],val)
				end
			end
		end
		return table.unpack(cachetab[c])
	end
end
function Duel.AskEveryone(stringid)
	local count0 = Duel.GetPlayersCount(0)
	local count1 = Duel.GetPlayersCount(1)
	--check if people want to duel
	local stop=not Duel.SelectYesNo(0,stringid)
	if not stop then
		for i=2,count0 do
			Duel.TagSwap(0)
			stop=stop or not Duel.SelectYesNo(0,stringid)
		end
		Duel.TagSwap(0)
	end
	if not stop then
			stop=not Duel.SelectYesNo(1,stringid)
			if not stop then
			for i=2,count1 do
				Duel.TagSwap(1)
				stop=stop or not Duel.SelectYesNo(1,stringid)
			end
			Duel.TagSwap(1)
		end
	end
	return not stop
end

function Duel.AskAny(stringid)
	local count0 = Duel.GetPlayersCount(0)
	local count1 = Duel.GetPlayersCount(1)
	--check if people want to duel
	local ok=Duel.SelectYesNo(0,stringid)
	if not ok then
		for i=2,count0 do
			Duel.TagSwap(0)
			ok=ok or Duel.SelectYesNo(0,stringid)
		end
		Duel.TagSwap(0)
	end
	if not ok then
			ok=Duel.SelectYesNo(1,stringid)
			if not ok then
			for i=2,count1 do
				Duel.TagSwap(1)
				ok=ok or Duel.SelectYesNo(1,stringid)
			end
			Duel.TagSwap(1)
		end
	end
	return ok
end

--Functions to automate consistent start-of-duel activations for Duel Modes like Speed Duel, Sealed Duel
function Auxiliary.EnableExtraRules(c,card,init,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(Auxiliary.EnableExtraRulesOperation(card,init,...))
	Duel.RegisterEffect(e1,0)
end
function Auxiliary.EnableExtraRulesOperation(card,init,...)
	local arg = {...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c = e:GetOwner()
		local p = c:GetControler()
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
		local ct = Duel.GetMatchingGroupCount(nil,p,LOCATION_HAND+LOCATION_DECK,0,c)
		if (Duel.IsDuelType(DUEL_MODE_SPEED) and ct < 20 or ct < 40) and Duel.SelectYesNo(1-p, aux.Stringid(4014,5)) then
			Duel.Win(1-p,0x55)
		end
		if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(p, 1, REASON_RULE) end
		if not card.global_active_check then
			Duel.ConfirmCards(1-p, c)
			if Duel.SelectYesNo(p,aux.Stringid(4014,6)) and Duel.SelectYesNo(1-p,aux.Stringid(4014,6)) then
				Duel.Hint(HINT_CARD,tp,c:GetCode())
				Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(4014,7))
				Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(4014,7))
				init(c,table.unpack(arg))
			else
				Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(4014,8))
				Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(4014,8))
			end
			card.global_active_check = true
		end
		e:Reset()
	end
end
--[[
Function to perform "Either add it to the hand or do X"
-card: affected card or group of cards to be moved;
-player: player performing the operation
-check: condition for the secondary action, if not provided the default action is "Send it to the GY";
oper: secondary action;
str: string to be used in the secondary option
]]
function Auxiliary.ToHandOrElse(card,player,check,oper,str,...)
	if card then
		if not check then check=Card.IsAbleToGrave end
		if not oper then oper=aux.thoeSend end
		if not str then str=574 end
		local b1,b2=true,true
		if type(card)=="Group" then
			for ctg in aux.Next(card) do
				if not ctg:IsAbleToHand() then
					b1=false
				end
				if not check(ctg,...) then
					b2=false
				end
			end
		else
			b1=card:IsAbleToHand()
			b2=check(card,...)
		end
		local opt
		if b1 and b2 then
			opt=Duel.SelectOption(player,573,str)
		elseif b1 then
			opt=Duel.SelectOption(player,573)
		else
			opt=Duel.SelectOption(player,str)+1
		end
		if opt==0 then
			local res=Duel.SendtoHand(card,nil,REASON_EFFECT)
			if res~=0 then Duel.ConfirmCards(1-player,card) end
			return res
		else
			return oper(card,...)
		end
	end
end
function Auxiliary.thoeSend(card)
	return Duel.SendtoGrave(card,REASON_EFFECT)
end

--Helper function to use with cards that normal summon or set a monster
function Duel.SummonOrSet(tp,...)
	local s1=Card.IsSummonable(...)
	local s2=Card.IsMSetable(...)
	if (s1 and s2 and Duel.SelectPosition(tp,(...),POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
		Duel.Summon(tp,...)
	else
		Duel.MSet(tp,...)
	end
end
--[[
Function to simplify registering EFFECT_FLAG_CLIENT_HINT to players
-card: card that creates the hintmsg;
-property: additional properties like EFFECT_FLAG_OATH
-tp: the player registering the effect;
-player1,player2: the players to whom the hint is registered
-str: the string called;
-reset: additional resets, other than RESET_PHASE+PHASE_END
]]
function Auxiliary.RegisterClientHint(card,property,tp,player1,player2,str,reset,ct)
	if not card then return end
	property=property or 0
	reset=reset or 0
	local eff=Effect.CreateEffect(card)
	eff:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT|property)
	eff:SetTargetRange(player1,player2)
	if str then
		eff:SetDescription(str)
	else
		eff:SetDescription(aux.Stringid(card:GetOriginalCode(),1))
	end
	eff:SetReset(RESET_PHASE+PHASE_END|reset,ct or 1)
	Duel.RegisterEffect(eff,tp)
	return eff
end
function Auxiliary.FieldSummonProcTg(fun1,fun2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,...)
		if not c then
			return not fun1 or fun1(e,tp)
		end
		return not fun2 or fun2(e,tp,eg,ep,ev,re,r,rp,chk,c,...)
	end
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
function Duel.ActivateFieldSpell(c,e,tp,eg,ep,ev,re,r,rp,target_p)
	if not target_p then target_p=tp end
	if c then
		local fc=Duel.GetFieldCard(target_p,LOCATION_FZONE,0)
		if Duel.IsDuelType(DUEL_1_FIELD) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			of=Duel.GetFieldCard(1-target_p,LOCATION_FZONE,0)
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
		Duel.MoveToField(c,tp,target_p,LOCATION_FZONE,POS_FACEUP,true)
		local te=c:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=c:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(c,4179255,te,0,tp,target_p,Duel.GetCurrentChain())
		return true
	end
	return false
end

function Duel.GoatConfirm(tp,loc)
	local dg,hg=Duel.GetFieldGroup(tp,loc&(LOCATION_HAND|LOCATION_DECK),0):Split(Card.IsLocation,nil,LOCATION_DECK)
	Duel.ConfirmCards(tp,dg)
	Duel.ConfirmCards(1-tp,hg)
	if #hg>0 then
		Duel.ShuffleHand(tp)
	end
	if #dg>0 then
		Duel.ShuffleDeck(tp)
	end
end

function Auxiliary.ChangeBattleDamage(player,value)
	return function(e,damp)
				if player==0 then
					if e:GetOwnerPlayer()==damp then
						return value
					else
						return -1
					end
				elseif player==1 then
					if e:GetOwnerPlayer()==1-damp then
						return value
					else
						return -1
					end
				end
		end
end
--Helper function to choose 1 among possible effects
--In input it takes tables of the form of {condition,stringid}
--and makes the player choose among the strings whose conditions are met
--it returns the index of the choosen element starting from 1, nil if none was selected
function Duel.SelectEffect(tp,...)
	local eff,sel={},{}
	for i,val in ipairs({...}) do
		if val[1] then
			table.insert(eff,val[2])
			table.insert(sel,i)
		end
	end
	if #eff==0 then return nil end
	return sel[Duel.SelectOption(tp,table.unpack(eff))+1]
end

--Makes the player call a coin and then toss a coin
--returns true if the player guessed right, false if he didn't
function Duel.CallCoin(tp)
	return Duel.AnnounceCoin(tp)==Duel.TossCoin(tp,1)
end

--Return the number of COIN_HEADS among the passed values
function Duel.CountHeads(result,...)
	if not ... then return (result==COIN_HEADS and 1 or 0) end
	return (result==COIN_HEADS and 1 or 0) + Duel.CountHeads(...)
end

--Return the number of COIN_TAILS among the passed values
function Duel.CountTails(result,...)
	if not ... then return (result==COIN_TAILS and 1 or 0) end
	return (result==COIN_TAILS and 1 or 0) + Duel.CountTails(...)
end

function Duel.CheckPendulumZones(player)
	return Duel.CheckLocation(player,LOCATION_PZONE,0) or Duel.CheckLocation(player,LOCATION_PZONE,1)
end

--[[
Returns the zone values (bitfield mask) of the Main Monster Zones on the field of "target_player"
that are pointed to by any Link Cards, which match the "by_filter" function/filter, in the locations "player_location"
and "oppo_location", from the perspective of "player".

- The first parameter, "player", is mandatory, all other parameters are optional, to use the default value of a parameter just pass it as nil.
- The filter by default checks that the card is face-up and is a Link Card, any additional check (e.g. archetype) is added onto that.
- Both locations default to LOCATION_MZONE if not provided since most cards care about zones that any Link Monster points to, if you want to
include Link Spells then use LOCATION_ONFIELD, or LOCATION_SZONE to exclude Link Monsters and check for Link Spells only.
- The second location defaults to the first one if not provided, if you want to not count a side of the field then you need to specifically pass 0 for that location.
- "target_player" defaults to "player" if not provided.
- Any additional parameters that "by_filter" might need can be passed to this function as "..." after "target_player".
--]]
local function link_card_filter(c,f,...)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and (not f or f(c,...))
end
function Auxiliary.GetMMZonesPointedTo(player,by_filter,player_location,oppo_location,target_player,...)
	local loc1=player_location==nil and LOCATION_MZONE or player_location
	local loc2=oppo_location==nil and loc1 or oppo_location
	target_player=target_player==nil and player or target_player
	return Duel.GetMatchingGroup(link_card_filter,player,loc1,loc2,nil,by_filter,...):GetLinkedZone(target_player)&ZONES_MMZ
end

--[[
	Performs an operation to a card(s) each time a given phase is entered.
	Returns the effect that would perform the operation, or nil if no card/group or an empty group is passed.

		Card|Group card_or_group: the cards that will be affected
		int phase: the phase when `oper` will be applied to the banished cards
		int flag: a unique integer to be registered as a flag on the affected cards
		Effect e: the effect performing the banishment
		int tp: the player performing the banishment, and will later perform `oper`
		function oper: a function with the signature (ag,e,tp,eg,ep,ev,re,r,rp)
			where `ag` is the group of affected cards
		function|nil cond: an additional condition function with the signature (ag,e,tp,eg,ep,ev,re,r,rp).
			`ag` is already checked if it's not empty.
		int|nil reset: the reset value. If not passed, the reset will be `RESET_PHASE+phase`.
		int|nil reset_count: how many times the reset value must happen.
			If not passed, the count will be 1.
		int|nil hint: a string to show on the affected cards
		int|nil effect_desc: a string to be used as the description of the delayed effect (useful when the same effect registers multiple different delayed effects)
--]]
function Auxiliary.DelayedOperation(card_or_group,phase,flag,e,tp,oper,cond,reset,reset_count,hint,effect_desc)
	local g=(type(card_or_group)=="Group" and card_or_group or Group.FromCards(card_or_group))
	if #g==0 then return end
	reset=reset or (RESET_PHASE|phase)
	reset_count=reset_count or 1
	local fid=e:GetFieldID()
	local function agfilter(c,lbl) return c:GetFlagEffectLabel(flag)==lbl end
	local function get_affected_group(e) return e:GetLabelObject():Filter(agfilter,nil,e:GetLabel()) end

	--Apply operation
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	if effect_desc then e1:SetDescription(effect_desc) end
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE|phase)
	e1:SetReset(reset,reset_count)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(function(e,...)
		local ag=get_affected_group(e)
		return #ag>0 and (not cond or cond(ag,e,...))
	end)
	e1:SetOperation(function(e,...)
		if oper then oper(get_affected_group(e),e,...) end
	end)
	Duel.RegisterEffect(e1,tp)

	--Flag cards
	local flagprop=hint and EFFECT_FLAG_CLIENT_HINT or 0
	local function flagcond() return not e1:IsDeleted() end
	for tc in g:Iter() do
		tc:RegisterFlagEffect(flag,RESET_EVENT+RESETS_STANDARD,flagprop,1,fid,hint):SetCondition(flagcond)
	end
	g:KeepAlive()

	return e1
end

--[[
	Banishes card(s) and performs an operation to them in a given phase (usually return them to their current location).
	Returns the effect that would perform the operation if a card is successfully banished, otherwise returns nil.

		Card|Group card_or_group: the cards to banish
		int|nil pos: the cards' position when banished. `nil` will use their current position
		int reason: the reason for banishing
		int phase: the phase when `oper` will be applied to the banished cards
		int flag: a unique integer to be registered as a flag on the affected cards
		Effect e: the effect performing the banishment
		int tp: the player performing the banishment, and will later perform `oper`
		function oper: a function with the signature (rg,e,tp,eg,ep,ev,re,r,rp)
			where `rg` is the group of cards that can be returned
		function|nil cond: an additional condition function with the signature (rg,e,tp,eg,ep,ev,re,r,rp).
			`rg` is already checked if it's not empty
		int|nil reset: the reset value. If not passed, the reset will be `RESET_PHASE+phase`.
		int|nil reset_count: how many times the reset value must happen.
			If not passed, the count will be 1.
		int|nil hint: a string to show on the affected cards
		int|nil effect_desc: a string to be used as the description of the delayed effect (useful when the same effect registers multiple different delayed effects)
--]]
function Auxiliary.RemoveUntil(card_or_group,pos,reason,phase,flag,e,tp,oper,cond,reset,reset_count,hint,effect_desc)
	local g=(type(card_or_group)=="Group" and card_or_group or Group.FromCards(card_or_group))
	if #g>0 and Duel.Remove(g,pos,reason|REASON_TEMPORARY)>0 and #g:Match(Card.IsLocation,nil,LOCATION_REMOVED)>0 then
		return aux.DelayedOperation(g,phase,flag,e,tp,oper,cond,reset,reset_count,hint,effect_desc)
	end
end

local function select_field_return_cards(p,g)
	if #g==0 then return end
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if ft>0 and #g>ft then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)
		local tg=g:Select(p,ft,ft,nil)
		for tc in tg:Iter() do
			Duel.ReturnToField(tc)
		end
		g:Sub(tg)
	end
	for tc in g:Iter() do
		Duel.ReturnToField(tc)
	end
end

--[[
	An operation function to be used with `aux.RemoveUntil`.
	Will return the banished cards to the monster zone, starting with the turn player.
	Makes each player select cards to return if they have fewer available zones than returnable cards.
--]]
function Auxiliary.DefaultFieldReturnOp(rg)
	if #rg==0 then return end
	local turn_p=Duel.GetTurnPlayer()
	local g0,g1=rg:Split(Card.IsPreviousControler,nil,turn_p)
	select_field_return_cards(turn_p,g0)
	select_field_return_cards(1-turn_p,g1)
end

Duel.LoadScript("debug_utility.lua")
Duel.LoadScript("cards_specific_functions.lua")
Duel.LoadScript("proc_fusion.lua")
Duel.LoadScript("proc_fusion_spell.lua")
Duel.LoadScript("proc_ritual.lua")
Duel.LoadScript("proc_synchro.lua")
Duel.LoadScript("proc_union.lua")
Duel.LoadScript("proc_xyz.lua")
Duel.LoadScript("proc_pendulum.lua")
Duel.LoadScript("proc_link.lua")
Duel.LoadScript("proc_equip.lua")
Duel.LoadScript("proc_persistent.lua")
Duel.LoadScript("proc_workaround.lua")
Duel.LoadScript("proc_normal.lua")
Duel.LoadScript("proc_skill.lua")
Duel.LoadScript("proc_rush.lua")
Duel.LoadScript("proc_maximum.lua")
Duel.LoadScript("proc_gemini.lua")
Duel.LoadScript("proc_spirit.lua")
Duel.LoadScript("proc_unofficial.lua")
Duel.LoadScript("deprecated_functions.lua")
pcall(dofile,"init.lua")
