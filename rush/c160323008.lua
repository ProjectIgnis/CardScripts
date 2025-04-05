--光を誘うグリフォール
--Light-Calling Griffore
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Set 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.revealfilter(c,tp)
	return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsType(TYPE_RITUAL) and c:IsDefenseAbove(2500) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.setfilter(c,tc)
	return c:IsRitualSpell() and c:ListsCode(tc:GetCode()) and c:IsSSetable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleExtra(tp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc)
	if #g==0 then return end
	Duel.SSet(tp,g)
end
