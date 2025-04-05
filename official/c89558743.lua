--スモール・ワールド
--Small World
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Banish and search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.singleprop(c,d)
	local ct=0
	if c:IsRace(d:GetRace()) then ct=ct+1 end
	if c:IsAttribute(d:GetAttribute()) then ct=ct+1 end
	if c:IsLevel(d:GetLevel()) then ct=ct+1 end
	if c:IsAttack(d:GetTextAttack()) and d:IsAttack(c:GetTextAttack()) then ct=ct+1 end
	if c:IsDefense(d:GetTextDefense()) and d:IsDefense(c:GetTextDefense()) then ct=ct+1 end
	return ct==1
end
function s.thfilter(c,mc)
	return c:IsMonster() and c:IsAbleToHand() and s.singleprop(c,mc)
end
function s.showfilter(c,tp,mc)
	return c:IsMonster() and not c:IsPublic() and c:IsAbleToRemove() and s.singleprop(c,mc)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
function s.revfilter(c,tp)
	return c:IsMonster() and not c:IsPublic() and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_DECK,0,1,nil,tp,c)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if not rc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sc=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATION_DECK,0,1,1,nil,tp,rc):GetFirst()
	if not sc then return end
	Duel.ConfirmCards(1-tp,rc)
	Duel.ConfirmCards(1-tp,sc)
	if Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)>0 and rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local th=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,sc,sc)
		if #th>0 then
			Duel.BreakEffect()
			if Duel.SendtoHand(th,nil,REASON_EFFECT)>0 and th:GetFirst():IsLocation(LOCATION_HAND) then
				Duel.ConfirmCards(1-tp,th)
				Duel.Remove(sc,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end