--セブンスロード・メイジ
--Sevens Road Mage
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of opponent's monsters lose 400 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SEVENS_ROAD_MAGICIAN}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
		if #g==0 then return end
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		--Reduce ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(-400)
		tc:RegisterEffect(e1)
		local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_SPELLCASTER)
		if ct>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SEVENS_ROAD_MAGICIAN),tp,LOCATION_MZONE,0,1,nil) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			e2:SetValue(-100*ct)
			tc:RegisterEffect(e2)
		end
	end
end