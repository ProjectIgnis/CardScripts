--ねこかぶら
--Cat in Cobra's Clothing
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top card of your Deck to gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:GetFirst()
	if ct and ct:IsMonster() and ct:IsLevelBelow(9) and ct:IsAttackAbove(100) then
		local c=e:GetHandler()
		--Gains ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct:GetAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
