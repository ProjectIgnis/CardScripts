--通販売員
--Two-Man Salesman
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_HAND,0,nil)*Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_HAND,nil)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local hg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	local hg2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_HAND,nil)
	if #hg1==0 or #hg2==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc1=hg1:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc2=hg2:Select(1-tp,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc1)
	Duel.ConfirmCards(tp,tc2)
	if tc1:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
		local ask1=Duel.SelectYesNo(tp,aux.Stringid(id,1))
		local ask2=Duel.SelectYesNo(1-tp,aux.Stringid(id,1))
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) and ask1 then
			Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		end
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc2:IsCanBeSpecialSummoned(e,0,1-tp,false,false) and ask2 then
			Duel.SpecialSummonStep(tc2,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	elseif tc1:IsType(TYPE_SPELL) and tc2:IsType(TYPE_SPELL)
		and Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) then
		Duel.Draw(tp,2,REASON_EFFECT)
		Duel.Draw(1-tp,2,REASON_EFFECT)
	elseif tc1:IsType(TYPE_TRAP) and tc2:IsType(TYPE_TRAP)
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,2,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_DECK,2,nil) then
		for p=0,1 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(p,Card.IsAbleToGrave,p,LOCATION_DECK,0,2,2,nil)
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
