--クリアウィング・シンクロ・ドラゴン (Anime)
--Clear Wing Synchro Dragon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If a Level 5 or higher monster activates its effect on the field, or a monster effect is activated that targets a Level 5 or higher monster(s) on the field, during this chain (Quick Effect): 
	--You can target 1 monster that activated 1 of those effects; negate that monster's effects, and if you do, destroy it, then this card gains ATK equal to the ATK that monster had when it was destroyed until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82044279,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsLevelAbove(5) and c:IsLocation(LOCATION_MZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc and tc:IsCanBeEffectTarget(e) and te:IsActiveType(TYPE_MONSTER) then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				if tc:IsLevelAbove(5) and loc==LOCATION_MZONE then g:AddCard(tc) end
				if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
					local tg=Duel.GetChainInfo(i,CHAININFO_TARGET_CARDS)
					if tg and tg:IsExists(s.cfilter,1,nil) then g:AddCard(tc) end
				end
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
				if tc:IsLevelAbove(5) and loc==LOCATION_MZONE then g:AddCard(tc) end
				if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
					local tg=Duel.GetChainInfo(i,CHAININFO_TARGET_CARDS)
					if tg and tg:IsExists(s.cfilter,1,nil) then g:AddCard(tc) end
				end
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
			if tc:IsLevelAbove(5) and loc==LOCATION_MZONE then check=true end
			if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
				local tg=Duel.GetChainInfo(i,CHAININFO_TARGET_CARDS)
				if tg and tg:IsExists(s.cfilter,1,nil) then check=true end
			end
			if check then
				g:AddCard(tc)
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1,i)
			end
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(sg)
	local i=sg:GetFirst():GetFlagEffectLabel(id)
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
	tc:NegateEffects(c)
	local i=tc:GetFlagEffectLabel(id)
	local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
	if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) and (not e3 or not tc:IsImmuneToEffect(e3)) and tc:IsRelateToEffect(te) 
		and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetPreviousAttackOnField()
		if atk<=0 then return end
		c:UpdateAttack(atk,RESETS_STANDARD_DISABLE_PHASE_END)
	end
end
