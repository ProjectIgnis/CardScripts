--サバイバル・ソードフィッシュ
--Survival Swordfish

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Make up to 2 fish monsters gain 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
	--Check for level 7 fish monster
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(7) and c:IsRace(RACE_FISH)
end
	--If player controls a level 7 fish monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
	--Check for fish monster
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FISH) and c:IsAbleToDeckAsCost()
end
	--If player has a fish monster to return to deck
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_FISH),tp,LOCATION_MZONE,0,1,nil) end
end
	--Make up to 2 fish monsters gain 500 ATK
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)~0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local sg=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsRace,RACE_FISH),tp,LOCATION_MZONE,0,1,2,nil)
		local tc=sg:GetFirst()
		for tc in aux.Next(sg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
