--クリスタルウィング・シンクロ・ドラゴン
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,nil,nil,nil,s.matfilter)
	c:EnableReviveLimit()
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82044279,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil,sc,tp)
end
function s.cfilter(c,sc,tp)
	return c:IsLevelAbove(5) and c:IsType(TYPE_SYNCHRO,sc,SUMMON_TYPE_SYNCHRO,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc and tc:IsCanBeEffectTarget(e) and te:IsActiveType(TYPE_MONSTER) then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		return g:IsContains(chkc) end
	if chk==0 then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc and tc:IsCanBeEffectTarget(e) and te:IsActiveType(TYPE_MONSTER) then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		return #g>0 end
	local g=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc and tc:IsCanBeEffectTarget(e) and te:IsActiveType(TYPE_MONSTER) then
			local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
			local check=false
			g:AddCard(tc)
			if check then tc:RegisterFlagEffect(51102034,RESET_CHAIN,0,1,i) end
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(sg)
	local i=sg:GetFirst():GetFlagEffectLabel(51102034)
	local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	if sg:GetFirst():IsRelateToEffect(te) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsDisabled() then return end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	local e3=nil
	if tc:IsType(TYPE_TRAPMONSTER) then
		e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	local i=tc:GetFlagEffectLabel(51102034)
	local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
	if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) and (not e3 or not tc:IsImmuneToEffect(e3)) and tc:IsRelateToEffect(te) 
		and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetPreviousAttackOnField()
		if atk<=0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsLevelAbove(5) and bc:IsControler(1-tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc and bc:IsRelateToBattle() and bc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
