--Anime card constants

-------------------------------------------------------------
--Rank-Up related functions
FLAG_RANKUP =   511001822
EFFECT_RANKUP_EFFECT	=   511001822

function Auxiliary.EnableCheckRankUp(c,condition,operation,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(Auxiliary.RankUpCheckCondition(condition,...))
	e1:SetOperation(Auxiliary.RankUpCheckOperation(operation,...))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(Auxiliary.RankUpCheckValue(...))
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end

function Auxiliary.RankUpCheckValue(...)
	local monsterFilter={...}
	return function(e,c)
		e:GetLabelObject():SetLabel(0)
		local g=c:GetMaterial():Filter(Auxiliary.RankUpBaseFilter,nil,c)
		if #g==0 then return end
		if #monsterFilter==0 and #g>0 then e:GetLabelObject():SetLabel(1) return end
		for _,filter in ipairs(monsterFilter) do
			if type(filter)=="function" and g:IsExists(filter,1,nil) then
				e:GetLabelObject():SetLabel(1) return
			elseif type(filter)=="number" then
				if g:IsExists(Card.IsSummonCode,1,nil,c,c:GetSummonType(),c:GetSummonPlayer(),filter) then
					e:GetLabelObject():SetLabel(1) return
				end
			end
		end
	end
end

function Auxiliary.RankUpCheckCondition(condition,...)
	local monsterFilter={...}
	local nameFilter={}
	for _,filter in ipairs(monsterFilter) do
		if type(filter)=="number" then
			nameFilter[filter]=true
		end
	end
	return function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():GetFlagEffect(511015134)>0 then return true end
		local flagLabels={e:GetHandler():GetFlagEffectLabel(511000685)}
		for _,flagLabel in ipairs(flagLabels) do
			if nameFilter[flagLabel] then return true end
		end
		return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
			and (not condition or condition(e,tp,eg,ep,ev,re,r,rp))
	end
end

function Auxiliary.RankUpCheckOperation(operation,...)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local rankupEffects={c:GetCardEffect(EFFECT_RANKUP_EFFECT)}
		for _,rankupEffect in ipairs(rankupEffects) do
			local te=rankupEffect:GetLabelObject():Clone()
			te:SetReset(te:GetLabel())
			c:RegisterEffect(te)
		end
		if operation then operation(e,tp,eg,ep,ev,re,r,rp) end
	end
end

function Auxiliary.RankUpBaseFilter(c,sc)
	return not c:IsPreviousLocation(LOCATION_OVERLAY) and c:GetRank()<sc:GetRank()
end

function Auxiliary.RankUpUsing(cg,id,hint)
	if type(cg)=="Group" then
		for c in aux.Next(cg) do
			c:RegisterFlagEffect(511000685,RESET_EVENT|RESETS_STANDARD&(~RESET_TOFIELD),hint and EFFECT_FLAG_CLIENT_HINT or 0,1,id,hint)
		end
	else
		cg:RegisterFlagEffect(511000685,RESET_EVENT|RESETS_STANDARD&(~RESET_TOFIELD),hint and EFFECT_FLAG_CLIENT_HINT or 0,1,id,hint)
	end
end

function Auxiliary.RankUpComplete(cg,hint)
	if type(cg)=="Group" then
		for c in aux.Next(cg) do
			c:RegisterFlagEffect(511015134,RESET_EVENT|RESETS_STANDARD&(~RESET_TOFIELD),hint and EFFECT_FLAG_CLIENT_HINT or 0,1,nil,hint)
		end
	else
		cg:RegisterFlagEffect(511015134,RESET_EVENT|RESETS_STANDARD&(~RESET_TOFIELD),hint and EFFECT_FLAG_CLIENT_HINT or 0,1,nil,hint)
	end
end


-------------------------------------------------------------
--Number battle protection
function Auxiliary.AddNumberBattleIndes(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
end


-------------------------------------------------------------
--Armor monsters
FLAG_ARMOR  =   110000103
if not aux.ArmorProcedure then
	aux.ArmorProcedure={}
	Armor=aux.ArmorProcedure
end
if not Armor then
	Armor=aux.ArmorProcedure
end
function Armor.AddProcedure(c)
--  c:Type(c:Type()|TYPE_ARMOR)
	--You can only attack with 1 Armor monster per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetCondition(Armor.CannotAttack)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(Armor.AttackRegister)
	c:RegisterEffect(e2)
	--When your Armor monster is targeted for an attack: You can target 1 other Armor monster you control with a different name; change the attack target to it.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(549)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(Armor.RedirectAttackCondition)
	e3:SetTarget(Armor.RedirectAttackTarget)
	e3:SetOperation(Armor.RedirectAttackOperation)
	c:RegisterEffect(e3)
end
function Armor.CannotAttack(e)
	return Duel.HasFlagEffect(e:GetHandlerPlayer(),FLAG_ARMOR) and Duel.GetFlagEffectLabel(e:GetHandlerPlayer(),FLAG_ARMOR)~=e:GetHandler():GetFieldID()
end
function Armor.AttackRegister(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,FLAG_ARMOR,RESET_PHASE|PHASE_END,0,1,e:GetHandler():GetFieldID())
end
function Armor.RedirectAttackCondition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return r~=REASON_REPLACE and at:IsFaceup() and at:IsControler(tp) and at:IsType(TYPE_ARMOR)
end
function Armor.RedirectAttackFilter(c,code)
	return c:IsFaceup() and c:IsType(TYPE_ARMOR) and not c:IsCode(code)
end
function Armor.RedirectAttackTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=Duel.GetAttackTarget()
	local code=at:GetCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=at
		and Armor.RedirectAttackFilter(chkc,code) end
	if chk==0 then return Duel.IsExistingTarget(Armor.RedirectAttackFilter,tp,LOCATION_MZONE,0,1,at,code) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
	Duel.SelectTarget(tp,Armor.RedirectAttackFilter,tp,LOCATION_MZONE,0,1,1,at,code)
end
function Armor.RedirectAttackOperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ChangeAttackTarget(tc)
	end
end


-------------------------------------------------------------
--Plus and Minus monsters
TYPE_PLUSMINUS  =   (TYPE_PLUS|TYPE_MINUS)
function Card.IsPlusOrMinus(c)
	local tpe=c:GetType()&TYPE_PLUSMINUS
	return tpe~=0 and tpe~=TYPE_PLUSMINUS
end
if not aux.PlusMinusProcedure then
	aux.PlusMinusProcedure={}
	PlusMinus=aux.PlusMinusProcedure
end
if not PlusMinus then
	PlusMinus=aux.PlusMinusProcedure
end
local PlusMi	nus={}
function Auxiliary.AddPlusMinusProcedure(c)
	--Negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(PlusMinus.nacon)
	e1:SetOperation(PlusMinus.naop)
	c:RegisterEffect(e1)
	--Must attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetCondition(PlusMinus.attractcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(PlusMinus.attract)
	c:RegisterEffect(e3)
end
function PlusMinus.nacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPlusOrMinus() then return false end
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsType(c:GetType()&TYPE_PLUSMINUS)
		and (Duel.GetCurrentPhase()<PHASE_DAMAGE or Duel.GetCurrentPhase()>PHASE_DAMAGE_CAL)
end
function PlusMinus.naop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,e:GetHandler():GetOriginalCode())
	Duel.NegateAttack()
end
function PlusMinus.attractcon(e)
	local c=e:GetHandler()
	return c:IsPlusOrMinus() and c:CanAttack()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,(~c:GetType())&TYPE_PLUSMINUS),c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function PlusMinus.attract(e,c)
	return c:IsFaceup() and c:IsType((~e:GetHandler():GetType())&TYPE_PLUSMINUS)
end


-------------------------------------------------------------
Cardian={}
function Cardian.check(c,tp,eg,ep,ev,re,r,rp)
	if c:IsSetCard(0xe6) and c:IsMonster() then
		local eff={c:GetCardEffect(511001692)}
		for _,te2 in ipairs(eff) do
			local te=te2:GetLabelObject()
			local con=te:GetCondition()
			local cost=te:GetCost()
			local tg=te:GetTarget()
			if te:GetType()==EFFECT_TYPE_FIELD then
				if not con or con(te,c) then
					return true
				end
			else
				if (not con or con(te,tp,eg,ep,ev,re,r,rp)) and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0) 
					and (not tg or tg(te,tp,eg,ep,ev,re,r,rp,0))) then
					return true
				end
			end
		end
	end
	return false
end


function Duel.EnableUnofficialRace(race)
	RACE_ALL=(RACE_ALL|race)
end
function Duel.EnableUnofficialAttribute(att)
	ATTRIBUTE_ALL=(ATTRIBUTE_ALL|att)
end


-------------------------------------------------------------
--Global handlings
local UnofficialProc={}
PROC_ATKDEF_CHANGED   =   1
PROC_CANNOT_BATTLE_INDES	=   2 
PROC_ICE_PILLAR =   3
PROC_DIVINE_HIERARCHY   =   4 
PROC_EVENT_LP0  =   5

RACE_YOKAI = 0x4000000000000000
ATTRIBUTE_LAUGH = 0x80
RACE_CHARISMA = 0x8000000000000000
  
Duel.EnableUnofficialProc=function(...)
	for _,proc in ipairs({...}) do
		if proc==PROC_ATKDEF_CHANGED and not UnofficialProc[PROC_ATKDEF_CHANGED] then
			UnofficialProc[PROC_ATKDEF_CHANGED]=true
			UnofficialProc.atkdefchanged()
		elseif proc==PROC_CANNOT_BATTLE_INDES and not UnofficialProc[PROC_CANNOT_BATTLE_INDES] then
			UnofficialProc[PROC_CANNOT_BATTLE_INDES]=true
			UnofficialProc.cannotBattleIndes()
		elseif proc==PROC_EVENT_LP0 and not UnofficialProc[PROC_EVENT_LP0] then
			UnofficialProc[PROC_EVENT_LP0]=true
			UnofficialProc.onLP0Trigger()
		elseif proc==PROC_ICE_PILLAR and not UnofficialProc[PROC_ICE_PILLAR] then
			UnofficialProc[PROC_ICE_PILLAR]=true
			UnofficialProc.icePillar()
		end
	end
end


function UnofficialProc.atkdefchanged()
	local e5=Effect.GlobalEffect()
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetOperation(UnofficialProc.op5)
	Duel.RegisterEffect(e5,0)
	local atkeff=Effect.GlobalEffect()
	atkeff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	atkeff:SetCode(EVENT_CHAIN_SOLVED)
	atkeff:SetOperation(UnofficialProc.atkraiseeff)
	Duel.RegisterEffect(atkeff,0)
	local atkadj=Effect.GlobalEffect()
	atkadj:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	atkadj:SetCode(EVENT_ADJUST)
	atkadj:SetOperation(UnofficialProc.atkraiseadj)
	Duel.RegisterEffect(atkadj,0)
end

function UnofficialProc.cannotBattleIndes()
	local IndesTable={}
	EFFECT_CANNOT_BATTLE_INDES = 511010508
	local regeff=Card.RegisterEffect
	function Card.RegisterEffect(c,e,forced,...)
		if e:GetCode()==EFFECT_DESTROY_REPLACE then
			local resetflag,resetcount=e:GetReset()
			local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
			if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
			e2:SetCode(EFFECT_DESTROY_REPLACE+EFFECT_CANNOT_BATTLE_INDES)
			e2:SetLabelObject(e)
			e2:SetLabel(c:GetOriginalCode())
			if resetflag and resetcount then
				e2:SetReset(resetflag,resetcount)
			elseif resetflag then
				e2:SetReset(resetflag)
			end
			c:RegisterEffect(e2)
		end
		return regeff(c,e,forced,table.unpack({...}))
	end

	local function newBatConSingle(con)
		return function(e)
			if not e then return false end
			local c=e:GetHandler()
			if c:IsHasEffect(EFFECT_CANNOT_BATTLE_INDES) and (c:IsReason(REASON_BATTLE) or e:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE) then
				local effs={c:GetCardEffect(EFFECT_CANNOT_BATTLE_INDES)}
				for _,eff in ipairs(effs) do
					local val=eff:GetValue()
					if not val then
						error("val in EFFECT_CANNOT_BATTLE_INDES cannot be nil",2)
					end
					if val==1 or (type(val)=='function' and val(eff,e,c)) then return false end
				end
			end
			return not con or con(e)
		end
	end
	local function newBatConEquip(con)
		return function(e,c)
			if not e then return false end
			local c=e:GetHandler()
			local ec=c:GetEquipTarget()
			if not ec then return false end
			if ec:IsHasEffect(EFFECT_CANNOT_BATTLE_INDES) and (ec:IsReason(REASON_BATTLE) or e:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE) then
				local effs={ec:GetCardEffect(EFFECT_CANNOT_BATTLE_INDES)}
				for _,eff in ipairs(effs) do
					local val=eff:GetValue()
					if not val then
						error("val in EFFECT_CANNOT_BATTLE_INDES cannot be nil",2)
					end
					if val==1 or (type(val)=='function' and val(eff,e,ec)) then return false end
				end
			end
			return not con or con(e)
		end
	end
	local function newBatTg(tg)
		return function(e,c)
			if not e or not c then return false end
			if c:IsHasEffect(EFFECT_CANNOT_BATTLE_INDES) and (c:IsReason(REASON_BATTLE) or e:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE) then
				local effs={c:GetCardEffect(EFFECT_CANNOT_BATTLE_INDES)}
				for _,eff in ipairs(effs) do
					local val=eff:GetValue()
					if not val then
						error("val in EFFECT_CANNOT_BATTLE_INDES cannot be nil",2)
					end
					if val==1 or val(eff,e,c) then return false end
				end
			end
			return not tg or tg(e,c)
		end
	end
	local function newBatNotRepReg(eff)
		if not IndesTable[eff] then
			IndesTable[eff]=true
			if eff:IsHasType(EFFECT_TYPE_SINGLE) then
				local con=eff:GetCondition()
				eff:SetCondition(newBatConSingle(con))
			elseif eff:IsHasType(EFFECT_TYPE_EQUIP) then
				local con=eff:GetCondition()
				eff:SetCondition(newBatConEquip(con))
			elseif eff:IsHasType(EFFECT_TYPE_FIELD) then
				local tg=eff:GetTarget()
				eff:SetTarget(newBatTg(tg))
			end
		end
	end
	local function replaceFilter(c,e)
		if c:IsHasEffect(EFFECT_CANNOT_BATTLE_INDES) then
			local effs={c:GetCardEffect(EFFECT_CANNOT_BATTLE_INDES)}
			for _,eff in ipairs(effs) do
				local val=eff:GetValue()
				if not val then
					error("val in EFFECT_CANNOT_BATTLE_INDES cannot be nil",2)
				end
				if val==1 or val(eff,e,c) then return false end
			end
		end
		return true
	end
	local function newBatTgReplaceField(tg)
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			if r&REASON_BATTLE==REASON_BATTLE then
				return tg(e,tp,eg:Filter(replaceFilter,nil,e),ep,ev,re,r,rp,chk)
			else
				return tg(e,tp,eg,ep,ev,re,r,rp,chk)
			end
		end
	end
	local function newBatTgReplaceFieldVal(val)
		return function(e,c)
			return (not c:IsReason(REASON_BATTLE) or replaceFilter(c,e)) and val(e,c)
		end
	end
	local function newBatTgReplaceSingle(tg)
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			return (not e:GetHandler():IsReason(REASON_BATTLE) or replaceFilter(e:GetHandler(),e))
				and tg(e,tp,eg,ep,ev,re,r,rp,chk)
		end
	end
	local function newBatTgReplaceEquip(tg)
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			return (not e:GetHandler():GetEquipTarget():IsReason(REASON_BATTLE)
				or replaceFilter(e:GetHandler():GetEquipTarget(),e))
				and tg(e,tp,eg,ep,ev,re,r,rp,chk)
		end
	end
	local function batregop(e,tp,eg,ep,ev,re,r,rp)
		local tg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		for tc in aux.Next(tg) do
			local indes={tc:GetCardEffect(EFFECT_INDESTRUCTABLE)}
			local indesBattle={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
			local indesCount={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_COUNT)}
			local desSubstitude={tc:GetCardEffect(EFFECT_DESTROY_SUBSTITUTE)}
			local desReplace={tc:GetCardEffect(EFFECT_DESTROY_REPLACE+EFFECT_CANNOT_BATTLE_INDES)}
			for _,eff in ipairs(indes) do
				newBatNotRepReg(eff)
			end
			for _,eff in ipairs(indesBattle) do
				newBatNotRepReg(eff)
			end
			for _,eff in ipairs(indesCount) do
				newBatNotRepReg(eff)
			end
			for _,eff in ipairs(desSubstitude) do
				newBatNotRepReg(eff)
			end
			for _,tempe in ipairs(desReplace) do
				local eff=tempe:GetLabelObject()
				if not IndesTable[eff] then
					IndesTable[eff]=true
					if eff:IsHasType(EFFECT_TYPE_SINGLE) then
						local tg=eff:GetTarget()
						eff:SetTarget(newBatTgReplaceSingle(tg))
					elseif eff:IsHasType(EFFECT_TYPE_EQUIP) then
						local tg=eff:GetTarget()
						eff:SetTarget(newBatTgReplaceEquip(tg))
					elseif eff:IsHasType(EFFECT_TYPE_FIELD) then
						local tg=eff:GetTarget()
						local val=eff:GetValue()
						eff:SetTarget(newBatTgReplaceField(tg))
						eff:SetValue(newBatTgReplaceFieldVal(val))
					end
				end
			end
		end
	end

	--Ignore Battle Indestructability
	local batIndes=Effect.GlobalEffect()
	batIndes:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	batIndes:SetCode(EVENT_ADJUST)
	batIndes:SetOperation(batregop)
	Duel.RegisterEffect(batIndes,0)
end

function UnofficialProc.onLP0Trigger()
	EVENT_LP0 = EVENT_CUSTOM|511002521
	function Auxiliary.LP0ActivationValidity(eff)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		ge1:SetTargetRange(1,0)
		ge1:SetCode(511000793)
		ge1:SetCondition(function(e) return eff:IsActivatable(e:GetHandlerPlayer()) end)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		Duel.RegisterEffect(ge2,1)
	end

	local function relayop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		for p=0,1 do
			if Duel.GetLP(p)<=0 and not Duel.IsPlayerAffectedByEffect(p,EFFECT_CANNOT_LOSE_LP)
				and Duel.GetFlagEffect(p,511002521)==0 and Duel.IsPlayerAffectedByEffect(p,511000793) then
				local ct=0
				local ge1=Effect.GlobalEffect()
				ge1:SetType(EFFECT_TYPE_FIELD)
				ge1:SetCode(EFFECT_CANNOT_LOSE_LP)
				ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				ge1:SetTargetRange(1,0)
				Duel.RegisterEffect(ge1,p)
				local ge2=Effect.GlobalEffect()
				ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				ge2:SetCode(EVENT_ADJUST)
				ge2:SetOperation(function()
					if Duel.GetCurrentChain()==0 or ct>0 then
						ct=ct+1
					end
					if (ct==2 and Duel.GetCurrentPhase()&PHASE_DAMAGE==0) or ct==3 then
						Duel.ResetFlagEffect(p,511002521)
						ge1:Reset()
						ge2:Reset()
					end
				end)
				Duel.RegisterEffect(ge2,p)
				Duel.RaiseEvent(Duel.GetMatchingGroup(aux.TRUE,p,LOCATION_ALL,0,nil),EVENT_LP0,nil,0,0,p,0)
				Duel.RegisterFlagEffect(p,511002521,0,0,0)
			end
		end
	end

	--Relay Soul/Zero Gate
	local rs1=Effect.GlobalEffect()
	rs1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	rs1:SetCode(EVENT_ADJUST)
	rs1:SetOperation(relayop)
	Duel.RegisterEffect(rs1,0)
	local rs2=rs1:Clone()
	rs2:SetCode(EVENT_CHAIN_SOLVED)
	Duel.RegisterEffect(rs2,0)
	local rs3=rs2:Clone()
	rs3:SetCode(EVENT_DAMAGE)
	Duel.RegisterEffect(rs3,0)
end

function UnofficialProc.op5(e,tp,eg,ep,ev,re,r,rp)
	--ATK = 285, prev ATK = 284
	--LVL = 585, prev LVL = 584
	--DEF = 385, prev DEF = 384
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xff,0xff,nil)
	for tc in aux.Next(g) do
		if tc:GetFlagEffect(285)==0 and tc:GetFlagEffect(585)==0 then
			local atk=tc:GetAttack()
			local def=tc:GetDefense()
			if atk<0 then atk=0 end
			if def<0 then def=0 end
			tc:RegisterFlagEffect(285,0,0,1,atk)
			tc:RegisterFlagEffect(284,0,0,1,atk)
			tc:RegisterFlagEffect(385,0,0,1,def)
			tc:RegisterFlagEffect(384,0,0,1,def)
			local lv=tc:GetLevel()
			tc:RegisterFlagEffect(585,0,0,1,lv)
			tc:RegisterFlagEffect(584,0,0,1,lv)
		end
	end
end
function UnofficialProc.atkcfilter(c)
	if c:GetFlagEffect(285)==0 then return false end
	return c:GetAttack()~=c:GetFlagEffectLabel(285)
end
function UnofficialProc.defcfilter(c)
	if c:GetFlagEffect(385)==0 then return false end
	return c:GetDefense()~=c:GetFlagEffectLabel(385)
end
function UnofficialProc.lvcfilter(c)
	if c:GetFlagEffect(585)==0 then return false end
	return c:GetLevel()~=c:GetFlagEffectLabel(585)
end
function UnofficialProc.atkraiseeff(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(UnofficialProc.atkcfilter,tp,0x7f,0x7f,nil)
	local g1=Group.CreateGroup() --change atk
	local g2=Group.CreateGroup() --gain atk
	local g3=Group.CreateGroup() --lose atk
	local g4=Group.CreateGroup() --gain atk from original
	local g9=Group.CreateGroup() --lose atk from original
	
	local dg=Duel.GetMatchingGroup(UnofficialProc.defcfilter,tp,0x7f,0x7f,nil)
	local g5=Group.CreateGroup() --change def
	local g6=Group.CreateGroup() --gain def
	--local g7=Group.CreateGroup() --lose def
	--local g8=Group.CreateGroup() --gain def from original
	for tc in g:Iter() do
		local prevatk=0
		if tc:GetFlagEffect(285)>0 then prevatk=tc:GetFlagEffectLabel(285) end
		g1:AddCard(tc)
		if prevatk>tc:GetAttack() then
			g3:AddCard(tc)
		else
			g2:AddCard(tc)
			if prevatk<=tc:GetBaseAttack() and tc:GetAttack()>tc:GetBaseAttack() then
				g4:AddCard(tc)
			end
			if prevatk>=tc:GetBaseAttack() and tc:GetAttack()<tc:GetBaseAttack() then
				g9:AddCard(tc)
			end
		end
		tc:ResetFlagEffect(284)
		tc:ResetFlagEffect(285)
		if prevatk>0 then
			tc:RegisterFlagEffect(284,0,0,1,prevatk)
		else
			tc:RegisterFlagEffect(284,0,0,1,0)
		end
		if tc:GetAttack()>0 then
			tc:RegisterFlagEffect(285,0,0,1,tc:GetAttack())
		else
			tc:RegisterFlagEffect(285,0,0,1,0)
		end
	end
	
	for dc in dg:Iter() do
		local prevdef=0
		if dc:GetFlagEffect(385)>0 then prevdef=dc:GetFlagEffectLabel(385) end
		g5:AddCard(dc)
		if prevdef>dc:GetDefense() then
			--g7:AddCard(dc)
		else
			g6:AddCard(dc)
			if prevdef<=dc:GetBaseDefense() and dc:GetDefense()>dc:GetBaseDefense() then
				--g8:AddCard(dc)
			end
		end
		dc:ResetFlagEffect(384)
		dc:ResetFlagEffect(385)
		if prevdef>0 then
			dc:RegisterFlagEffect(384,0,0,1,prevdef)
		else
			dc:RegisterFlagEffect(384,0,0,1,0)
		end
		if dc:GetDefense()>0 then
			dc:RegisterFlagEffect(385,0,0,1,dc:GetDefense())
		else
			dc:RegisterFlagEffect(385,0,0,1,0)
		end
	end
	
	if #g1>0 then
		Duel.RaiseEvent(g1,511001265,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g1,511001441,re,REASON_EFFECT,rp,ep,0)
	end
	if #g2>0 then
		Duel.RaiseEvent(g2,511000377,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g2,511001762,re,REASON_EFFECT,rp,ep,0)
	end
	if #g3>0 then
		Duel.RaiseEvent(g3,511000883,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g3,511009110,re,REASON_EFFECT,rp,ep,0)
	end
	if #g4>0 then
		Duel.RaiseEvent(g4,511002546,re,REASON_EFFECT,rp,ep,0)
	end
	if #g5>0 then
		Duel.RaiseEvent(g5,511009053,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseEvent(g5,511009565,re,REASON_EFFECT,rp,ep,0)
	end
	if #g9>0 then
		Duel.RaiseEvent(g9,511010103,re,REASON_EFFECT,rp,ep,0)
	end
	--Duel.RaiseEvent(g6,,re,REASON_EFFECT,rp,ep,0)
	
	local lvg=Duel.GetMatchingGroup(UnofficialProc.lvcfilter,tp,0x7f,0x7f,nil)
	if #lvg>0 then
		for lvc in lvg:Iter() do
			local prevlv=lvc:GetFlagEffectLabel(585)
			lvc:ResetFlagEffect(584)
			lvc:ResetFlagEffect(585)
			lvc:RegisterFlagEffect(584,0,0,1,prevlv)
			lvc:RegisterFlagEffect(585,0,0,1,lvc:GetLevel())
		end
		Duel.RaiseEvent(lvg,511002524,re,REASON_EFFECT,rp,ep,0)
	end
	
	Duel.RegisterFlagEffect(tp,285,RESET_CHAIN,0,1)
	Duel.RegisterFlagEffect(1-tp,285,RESET_CHAIN,0,1)
end
function UnofficialProc.atkraiseadj(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,285)~=0 or Duel.GetFlagEffect(1-tp,285)~=0 then return end
	local g=Duel.GetMatchingGroup(UnofficialProc.atkcfilter,tp,0x7f,0x7f,nil)
	local g1=Group.CreateGroup() --change atk
	local g2=Group.CreateGroup() --gain atk
	local g3=Group.CreateGroup() --lose atk
	local g4=Group.CreateGroup() --gain atk from original
	local g9=Group.CreateGroup() --lose atk from original
	
	local dg=Duel.GetMatchingGroup(UnofficialProc.defcfilter,tp,0x7f,0x7f,nil)
	local g5=Group.CreateGroup() --change def
	--local g6=Group.CreateGroup() --gain def
	--local g7=Group.CreateGroup() --lose def
	--local g8=Group.CreateGroup() --gain def from original
	for tc in g:Iter() do
		local prevatk=0
		if tc:GetFlagEffect(285)>0 then prevatk=tc:GetFlagEffectLabel(285) end
		g1:AddCard(tc)
		if prevatk>tc:GetAttack() then
			g3:AddCard(tc)
		else
			g2:AddCard(tc)
			if prevatk<=tc:GetBaseAttack() and tc:GetAttack()>tc:GetBaseAttack() then
				g4:AddCard(tc)
			end
			if prevatk>=tc:GetBaseAttack() and tc:GetAttack()<tc:GetBaseAttack() then
				g9:AddCard(tc)
			end
		end
		tc:ResetFlagEffect(284)
		tc:ResetFlagEffect(285)
		if prevatk>0 then
			tc:RegisterFlagEffect(284,0,0,1,prevatk)
		else
			tc:RegisterFlagEffect(284,0,0,1,0)
		end
		if tc:GetAttack()>0 then
			tc:RegisterFlagEffect(285,0,0,1,tc:GetAttack())
		else
			tc:RegisterFlagEffect(285,0,0,1,0)
		end
	end
	
	for dc in dg:Iter() do
		local prevdef=0
		if dc:GetFlagEffect(385)>0 then prevdef=dc:GetFlagEffectLabel(385) end
		g5:AddCard(dc)
		if prevdef>dc:GetDefense() then
			--g7:AddCard(dc)
		else
			--g6:AddCard(dc)
			if prevdef<=dc:GetBaseDefense() and dc:GetDefense()>dc:GetBaseDefense() then
				--g8:AddCard(dc)
			end
		end
		dc:ResetFlagEffect(284)
		dc:ResetFlagEffect(285)
		if prevdef>0 then
			dc:RegisterFlagEffect(284,0,0,1,prevdef)
		else
			dc:RegisterFlagEffect(284,0,0,1,0)
		end
		if dc:GetAttack()>0 then
			dc:RegisterFlagEffect(285,0,0,1,dc:GetAttack())
		else
			dc:RegisterFlagEffect(285,0,0,1,0)
		end
	end
	
	if #g1>0 then
		Duel.RaiseEvent(g1,511001265,e,REASON_EFFECT,rp,ep,0)
	end
	if #g2>0 then
		Duel.RaiseEvent(g2,511001762,e,REASON_EFFECT,rp,ep,0)
	end
	if #g3>0 then
		Duel.RaiseEvent(g3,511009110,e,REASON_EFFECT,rp,ep,0)
	end
	if #g4>0 then
		Duel.RaiseEvent(g4,511002546,e,REASON_EFFECT,rp,ep,0)
	end
	if #g5>0 then
		Duel.RaiseEvent(g5,511009053,e,REASON_EFFECT,rp,ep,0)
	end
	if #g9>0 then
		Duel.RaiseEvent(g9,511010103,e,REASON_EFFECT,rp,ep,0)
	end
	
	local lvg=Duel.GetMatchingGroup(UnofficialProc.lvcfilter,tp,0x7f,0x7f,nil)
	if #lvg>0 then
		for lvc in lvg:Iter() do
			local prevlv=lvc:GetFlagEffectLabel(585)
			lvc:ResetFlagEffect(584)
			lvc:ResetFlagEffect(585)
			lvc:RegisterFlagEffect(584,0,0,1,prevlv)
			lvc:RegisterFlagEffect(585,0,0,1,lvc:GetLevel())
		end
		Duel.RaiseEvent(lvg,511002524,e,REASON_EFFECT,rp,ep,0)
	end
end





--Ice Pillar Mechanic
--edo9300 and Larry126
function UnofficialProc.icePillar()
	IcePillarZone = {}
	IcePillarZone[1]=0
	IcePillarZone[2]=0
	--disable field
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetCondition(function()return IcePillarZone[1]|(IcePillarZone[2]<<16)>0 end)
	e1:SetValue(function()
		return IcePillarZone[1]|(IcePillarZone[2]<<16)
	end)
	Duel.RegisterEffect(e1,0)
	--negate attack
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(function(e,tp)
		if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) then
			local tc=Duel.GetAttacker()
			if CheckPillars(tp,1) and tc and tc:GetControler()~=tp
				and tc:IsRelateToBattle() and not tc:IsStatus(STATUS_ATTACK_CANCELED)
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				IcePillarZone[tp+1]=IcePillarZone[tp+1] & ~Duel.SelectFieldZone(tp,1,LOCATION_MZONE,LOCATION_MZONE,~IcePillarZone[tp+1])
				Duel.NegateAttack()
			end
		end
	end)
	Duel.RegisterEffect(e2,0)
	Duel.RegisterEffect(e2:Clone(),1)
	local e3=Effect.GlobalEffect()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetOperation(function(e,tp)
		local tc=Duel.GetAttacker()
		if CheckPillars(tp,1) and tc and tc:GetControler()~=tp and Duel.SelectYesNo(tp,aux.Stringid(422,0)) then
			IcePillarZone[tp+1]=IcePillarZone[tp+1] & ~Duel.SelectFieldZone(tp,1,LOCATION_MZONE,LOCATION_MZONE,~IcePillarZone[tp+1])
			Duel.NegateAttack()
		end
	end)
	Duel.RegisterEffect(e3,0)
	Duel.RegisterEffect(e3:Clone(),1)
	CheckPillars=function(tp,c,zone)
		local chkzone = zone and zone&IcePillarZone[1+tp] or IcePillarZone[1+tp]
		local seq=0
		for seq=0,7 do
			if(chkzone&(1<<seq))>0 then
				c=c-1
			end
		end
		return c<1
	end
end
