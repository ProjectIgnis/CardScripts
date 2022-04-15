-- プレデター・ガンレオン
-- Predator Gunleon
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,5) end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local lp=Duel.GetLP(tp)
		return lp<=1000 and lp~=Duel.GetLP(1-tp)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if Duel.DiscardDeck(tp,5,REASON_COST)<1 then return end
	-- Effect
	local c=e:GetHandler()
	local atk=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	if atk>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Gain ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		c:RegisterEffectRush(e1)
	end
end