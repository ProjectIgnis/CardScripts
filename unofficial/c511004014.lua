--バトル・シティ
--Battle City
--Scripted by Edo9300
--Updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.op)
end
function s.op(oc)
	--To controler's grave
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	Duel.RegisterEffect(e1,0)
	local e1a=Effect.GlobalEffect()
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1a:SetCode(EVENT_ADJUST)
	e1a:SetCondition(s.grepcon)
	e1a:SetOperation(s.grepop)
	Duel.RegisterEffect(e1a,0)
	local e1b=Effect.GlobalEffect()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1b:SetCode(EVENT_CHAIN_END)
	e1b:SetCondition(s.grepcon2)
	e1b:SetOperation(s.grepop2)
	Duel.RegisterEffect(e1b,0)
	--Double Tribute
	local e2=Effect.GlobalEffect()
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetTarget(function(e,c)return c:IsSummonLocation(LOCATION_EXTRA) and c:GetMaterialCount()==2 end)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,0)
	--Triple Tribute
	local e2a=Effect.GlobalEffect()
	e2a:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2a:SetCode(EFFECT_TRIPLE_TRIBUTE)
	e2a:SetTarget(function(e,c)return c:IsSummonLocation(LOCATION_EXTRA) and c:GetMaterialCount()>=3 end)
	e2a:SetValue(1)
	Duel.RegisterEffect(e2a,0)
	--faceup def
	local e3=Effect.GlobalEffect()
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetTargetRange(1,1)
	Duel.RegisterEffect(e3,0)
	--summon with 3 tribute
	local e4=Effect.GlobalEffect()
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e4:SetTargetRange(0xff,0xff)
	e4:SetCondition(Auxiliary.NormalSummonCondition1(3,3))
	e4:SetTarget(aux.FieldSummonProcTg(s.tttg1,Auxiliary.NormalSummonTarget(3,3)))
	e4:SetOperation(Auxiliary.NormalSummonOperation(3,3))
	e4:SetValue(SUMMON_TYPE_TRIBUTE)
	Duel.RegisterEffect(e4,0)
	local e5=e4:Clone()
	e5:SetCondition(Auxiliary.NormalSetCondition1(3,3))
	e5:SetTarget(aux.FieldSummonProcTg(s.tttg2,Auxiliary.NormalSetTarget(3,3)))
	e5:SetOperation(Auxiliary.NormalSetOperation(3,3))
	e5:SetCode(EFFECT_LIMIT_SET_PROC)
	Duel.RegisterEffect(e5,0)
	--Cannot Attack
	local e6=Effect.GlobalEffect()
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(function(e,c) return c:IsStatus(STATUS_SPSUMMON_TURN) and (c:IsSummonLocation(LOCATION_EXTRA) or (c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsSummonLocation(LOCATION_GRAVE))) and not c:IsHasEffect(511004016) end)
	Duel.RegisterEffect(e6,0)
	--Quick
	local e7=Effect.GlobalEffect()
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_BECOME_QUICK)
	e7:SetTargetRange(0xff,0xff)
	e7:SetCondition(function(e)return Duel.IsBattlePhase() end)
	Duel.RegisterEffect(e7,0)
	local e7a=Effect.GlobalEffect()
	e7a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e7a:SetType(EFFECT_TYPE_FIELD)
	e7a:SetCode(EFFECT_BECOME_QUICK)
	e7a:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e7a:SetTarget(function(e,c) return c:IsSpell() and not c:IsType(TYPE_QUICKPLAY) and c:IsFacedown() and Duel.GetTurnPlayer()~=c:GetControler() end)
	Duel.RegisterEffect(e7a,0)
	local e7b=e7a:Clone()
	e7b:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e7b:SetTarget(function(e,c) return c:IsSpell() and not c:IsType(TYPE_QUICKPLAY) and c:IsHasEffect(EFFECT_BECOME_QUICK) and (Duel.IsBattlePhase() or Duel.GetTurnPlayer()~=c:GetControler()) end)
	Duel.RegisterEffect(e7b,0)
	--Negate
	local e8=Effect.GlobalEffect()
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetCode(EVENT_CHAIN_SOLVING)
	e8:SetOperation(s.negop)
	Duel.RegisterEffect(e8,0)
	local e9=e8:Clone()
	e9:SetCode(EVENT_DESTROYED)
	e9:SetOperation(s.negop2)
	Duel.RegisterEffect(e9,0)
	--block
	local e10=Effect.GlobalEffect()
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e10:SetCode(EVENT_SUMMON_SUCCESS)
	e10:SetOperation(s.block)
	Duel.RegisterEffect(e10,0)
	local e10a=e10:Clone()
	e10a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	Duel.RegisterEffect(e10a,0)
	local e10b=e10:Clone()
	e10b:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e10b,0)
	--Attack
	local e11=Effect.GlobalEffect()
	e11:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e11:SetCode(EVENT_LEAVE_FIELD)
	e11:SetCondition(s.sacrificeEscapeCon)
	e11:SetOperation(function() Duel.NegateAttack() end)
	Duel.RegisterEffect(e11,0)
	local e11a=e11:Clone()
	e11a:SetCode(EVENT_BE_MATERIAL)
	Duel.RegisterEffect(e11a,0)
	if Duel.SelectYesNo(0,aux.Stringid(id,0)) and Duel.SelectYesNo(1,aux.Stringid(id,0)) then
		Duel.Hint(HINT_MESSAGE,0,aux.Stringid(id,1))
		Duel.Hint(HINT_MESSAGE,1,aux.Stringid(id,1))
		--manga rules
		local e12=Effect.GlobalEffect()
		e12:SetType(EFFECT_TYPE_FIELD)
		e12:SetCode(EFFECT_HAND_LIMIT)
		e12:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
		e12:SetTargetRange(1,1)
		e12:SetValue(7)
		Duel.RegisterEffect(e12,0)
		local e13=e12:Clone()
		e13:SetCode(EFFECT_MAX_MZONE)
		e13:SetValue(s.mvalue)
		Duel.RegisterEffect(e13,0)
		local e14=e12:Clone()
		e14:SetCode(EFFECT_MAX_SZONE)
		e14:SetValue(s.svalue)
		Duel.RegisterEffect(e14,0)
		local e15=e12:Clone()
		e15:SetCode(EFFECT_CANNOT_ACTIVATE)
		e15:SetValue(s.aclimit)
		Duel.RegisterEffect(e15,0)
		local e16=Effect.GlobalEffect()
		e16:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e16:SetCode(EVENT_CHAINING)
		e16:SetOperation(s.aclimit1)
		Duel.RegisterEffect(e16,0)
		local e17=e16:Clone()
		e17:SetCode(EVENT_CHAIN_NEGATED)
		e17:SetOperation(s.aclimit2)
		Duel.RegisterEffect(e17,0)
		local e18=e16:Clone()
		e18:SetCode(EVENT_SSET)
		e18:SetOperation(s.checkop)
		Duel.RegisterEffect(e18,0)
		local e19=Effect.GlobalEffect()
		e19:SetType(EFFECT_TYPE_FIELD)
		e19:SetCode(EFFECT_CANNOT_TURN_SET)
		e19:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e19:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		Duel.RegisterEffect(e19,0)
		local e20=e19:Clone()
		e20:SetCode(EFFECT_CANNOT_MSET)
		e20:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
		e20:SetTargetRange(1,1)
		Duel.RegisterEffect(e20,0)
		local e21=e20:Clone()
		e21:SetCode(EFFECT_CANNOT_SSET)
		e21:SetTarget(s.setlimit)
		Duel.RegisterEffect(e21,0)
		local e22=e19:Clone()
		e22:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e22:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e22:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
		Duel.RegisterEffect(e22,0)
	end
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsHasEffect),0,0xff,0xff,nil,EFFECT_LIMIT_SUMMON_PROC)
	local g2=Duel.GetMatchingGroup(aux.NOT(Card.IsHasEffect),0,0xff,0xff,nil,EFFECT_LIMIT_SET_PROC)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(511004015,0,0,0)
	end
	for tc2 in aux.Next(g2) do
		tc2:RegisterFlagEffect(511004017,0,0,0)
	end
	local proc=Duel.SendtoGrave
	Duel.SendtoGrave=function(tg,r,tp)
		if tp then
			if type(tg)=='Card' then
				tg:RegisterFlagEffect(511004018,RESET_EVENT+RESETS_STANDARD,0,1)
			elseif type(tg)=='Group' then
				for tc in aux.Next(tg) do tc:RegisterFlagEffect(511004018,RESET_EVENT+RESETS_STANDARD,0,1) end
			end
			return proc(tg,r,tp)
		end
		return proc(tg,r,tp)
	end
end
function s.tttg1(e,c)
	return c==0 or c==1 or c:GetLevel()>=10 and c:GetFlagEffect(511004015)==1
end
function s.tttg2(e,c)
	return c==0 or c==1 or c:GetLevel()>=10 and c:GetFlagEffect(511004017)==1
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():GetFlagEffect(511000173)>0 and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and not re:GetHandler():IsRelateToEffect(re) and re:GetHandler():GetReasonEffect()~=re then
		Duel.NegateEffect(ev)
	end
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		ec:RegisterFlagEffect(511000173,0,RESET_CHAIN,1)
	end
end
function s.tgfilter(c,te,p)
	return c:IsCanBeEffectTarget(te) and c:IsControler(p)
end
function s.atgfilter(c,ap)
	return Duel.GetAttacker():GetAttackableTarget():IsContains(c) and c:IsControler(ap)
end
function s.block(e,tp,eg,ep,ev,re,r,rp)
	local te,tg=Duel.GetChainInfo(ev+1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TARGET_CARDS)
	if te and te~=re and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and #tg==1 then
		local g=eg:Filter(s.tgfilter,nil,te,tg:GetFirst():GetControler())
		if #g>0 and Duel.SelectYesNo(g:GetFirst():GetSummonPlayer(),aux.Stringid(68823957,1)) then
			local p=g:GetFirst():GetSummonPlayer()
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TARGET)
			local rg=g:Select(p,1,1,nil)
			Duel.ChangeTargetCard(ev+1,rg)
		end
	end
	local ac=Duel.GetAttacker()
	if (Duel.CheckEvent(EVENT_BE_BATTLE_TARGET) or Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE))
		and not ac:IsStatus(STATUS_ATTACK_CANCELED) then
		local ap=1-ac:GetControler()
		local at=Duel.GetAttackTarget()
		local ag=eg:Filter(s.atgfilter,nil,ap)
		if #ag>0 and Duel.SelectYesNo(ag:GetFirst():GetSummonPlayer(),aux.Stringid(68823957,0)) then
			local p=ag:GetFirst():GetSummonPlayer()
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATTACKTARGET)
			local atg=ag:Select(p,1,1,nil)
			Duel.HintSelection(atg)
			Duel.ChangeAttackTarget(atg:GetFirst())
			atg:GetFirst():RegisterFlagEffect(511004019,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
		else
			Duel.ChangeAttackTarget(at)
			if at then at:RegisterFlagEffect(511004019,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1) end
		end
	end
end
function s.repfilter(c)
	return c:GetDestination()==LOCATION_GRAVE and c:GetFlagEffect(511004018)==0 and c:GetControler()~=c:GetOwner()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil) end
	local g=eg:Filter(s.repfilter,nil)
	for c in aux.Next(g) do
		if c:GetReason()&REASON_DESTROY==REASON_DESTROY then
			c:RegisterFlagEffect(511000173,RESET_CHAIN,0,1)
		end
		Duel.SendtoGrave(c,c:GetReason(),c:GetControler())
	end
	return true
end
function s.repval(e,c)
	return c:GetControler()~=c:GetOwner() and c:GetDestination()==LOCATION_GRAVE and c:GetFlagEffect(511004018)==0
end
function s.grepcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsStatus,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,STATUS_LEAVE_CONFIRMED)
end
function s.grepop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,STATUS_LEAVE_CONFIRMED)
	for c in aux.Next(g) do
		c:CancelToGrave()
		c:RegisterFlagEffect(STATUS_LEAVE_CONFIRMED,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.grepfilter(c)
	return c:GetFlagEffect(STATUS_LEAVE_CONFIRMED)>0
end
function s.grepcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.grepfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.grepop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.grepfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for c in aux.Next(g) do
		c:CancelToGrave(false)
		Duel.SendtoGrave(c,REASON_RULE,c:GetControler())
	end
end
function s.mvalue(e,fp,rp,r)
	return 5-Duel.GetFieldGroupCount(fp,LOCATION_SZONE,0)
end
function s.svalue(e,fp,rp,r)
	local ct=5
	for i=5,7 do
		if Duel.GetFieldCard(fp,LOCATION_SZONE,i) then ct=ct-1 end
	end
	return ct-Duel.GetFieldGroupCount(fp,LOCATION_MZONE,0)
end
function s.acfilter(c)
	return c:GetFlagEffect(EFFECT_TYPE_ACTIVATE)>0
end
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsLocation(LOCATION_HAND) then
		return Duel.IsExistingMatchingCard(s.acfilter,tp,0xff,0,1,nil)
	end
	if re:IsActiveType(TYPE_FIELD) then
		return not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
	elseif re:IsActiveType(TYPE_PENDULUM) then
		return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4
	end
	return false
end
function s.setlimit(e,c,tp)
	return (c:IsLocation(LOCATION_HAND) and ((c:IsSpell() and Duel.GetFlagEffect(tp,TYPE_SPELL)>0)
		or (c:IsTrap() and Duel.GetFlagEffect(tp,TYPE_TRAP)>(Duel.IsPlayerAffectedByEffect(tp,511004017) and 1 or 0))))
		or (c:IsType(TYPE_FIELD) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>4)
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsPreviousLocation(LOCATION_HAND) then
		re:GetHandler():RegisterFlagEffect(EFFECT_TYPE_ACTIVATE,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsPreviousLocation(LOCATION_HAND) then
		re:GetHandler():ResetFlagEffect(EFFECT_TYPE_ACTIVATE)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_HAND)
	if #hg>0 then
		if hg:IsExists(Card.IsSpell,1,nil) then
			Duel.RegisterFlagEffect(rp,TYPE_SPELL,RESET_PHASE|PHASE_END,0,1)
		end
		if hg:IsExists(Card.IsTrap,1,nil) then
			Duel.RegisterFlagEffect(rp,TYPE_TRAP,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.sacrificeEscapeCon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local at=Duel.GetAttackTarget()
	return ph>=PHASE_BATTLE_STEP and ph<PHASE_DAMAGE and at~=nil and eg:IsContains(at)
		and not at:IsReason(REASON_BATTLE) and at:GetFlagEffect(511004019)==0
end