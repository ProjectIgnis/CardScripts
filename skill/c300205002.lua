--Into the Darkness Below
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local b1=Duel.IsPlayerCanDraw(tp,1)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local b2=(Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and ct>3)
	return aux.CanActivateSkill(tp)	and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.DiscardHand(tp,s.filter,1,1,REASON_COST+REASON_DISCARD)
	local b1=Duel.IsPlayerCanDraw(tp,1)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local b2=(Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and ct>3)
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else return end
	if opt==0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end
function s.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
function s.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsMonster() and c:IsRace(RACE_FIEND)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
