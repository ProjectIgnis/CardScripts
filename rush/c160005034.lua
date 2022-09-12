-- 幻書鳩の騎士ナイト・ヴィジョン
-- Phantom Dove Night Vision
local s,id=GetID()
function s.initial_effect(c)
	--gain atk
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
	--Check for card in deck to send to GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_WINGEDBEAST),tp,LOCATION_MZONE,0,1,nil)
	and Duel.IsExistingMatchingCard(Card.IsTrap,tp,LOCATION_GRAVE,0,1,nil) end
end
	--Send 1 top card of deck to GY to this card gain 200 atk for each trap and inflict 1000 damage
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.DiscardDeck(tp,1,REASON_COST)
	--Effect
	local ct=Duel.GetMatchingGroupCount(Card.IsTrap,c:GetControler(),LOCATION_GRAVE,0,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(ct*200)
	c:RegisterEffect(e1)
	if ct>4 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
