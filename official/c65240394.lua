--ビッグ・シールド・ガードナー
--Big Shield Gardna (Pre-Errata)
--The negate effect is a continuous effect rather than quick
local s,id=GetID()
function s.initial_effect(c)
	--to attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	if not c:IsStatus(STATUS_COPYING_EFFECT) then s[c]=true end
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_CHAIN_ACTIVATING)
		ge:SetOperation(s.negop)
		Duel.RegisterEffect(ge,0)
	end)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c==Duel.GetAttackTarget() and c:IsDefensePos() and c:IsRelateToBattle() then
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetChainInfo(ev,CHAININFO_TYPE)==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if #g~=1 then return end
		local tc=g:GetFirst()
		if s[tc] and tc:IsLocation(LOCATION_MZONE) and tc:IsFacedown() then
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			Duel.NegateActivation(ev)
		end
	end
end