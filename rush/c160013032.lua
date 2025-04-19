--顕現術師ドルテオ
--Summoning Sorcerer Doretheo
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_SPELLCASTER) and c:IsMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)~=2 then return end
	local ct=Duel.GetOperatedGroup():FilterCount(s.cfilter,nil)
	if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct*300,REASON_EFFECT)
	end
end