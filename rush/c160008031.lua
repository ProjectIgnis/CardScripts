--雷闘騎トリガードラゴ
--Thunder Cavalry Triggerdrago
--Scripted by Hatter
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
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		e1:SetValue(300)
		c:RegisterEffect(e1)
		-- Piercing Damage
		if Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)==0 then
			c:AddPiercing(RESETS_STANDARD_PHASE_END)
		end
	end
end