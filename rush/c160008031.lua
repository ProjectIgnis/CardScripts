-- 雷闘騎トリガードラゴ
-- Blitzkrieg Cavalry Triggerdrago
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Increase self ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if not Duel.IsPlayerCanDiscardDeck(1-tp,1) or Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	-- Effect
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Gain ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(300)
		c:RegisterEffectRush(e1)
		-- Piercing Damage
		c:AddPiercing(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end