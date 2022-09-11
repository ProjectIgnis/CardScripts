--亜空間バトル
--Subspace Battle
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE+CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsMonster() and c:GetTextAttack()>=0 and c:IsAbleToHand() and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) or not Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_DECK,3,nil) then
		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,0))
		Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(id,0))
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,3,3,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,1))
	local g2=Duel.SelectMatchingCard(1-tp,s.filter,tp,0,LOCATION_DECK,3,3,nil)
	local exg1=Group.CreateGroup()
	local exg2=Group.CreateGroup()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,526)
		local sc1=g1:Select(tp,1,1,exg1):GetFirst()
		exg1:AddCard(sc1)
		Duel.Hint(HINT_SELECTMSG,1-tp,526)
		local sc2=g2:Select(1-tp,1,1,exg2):GetFirst()
		exg2:AddCard(sc2)
		Duel.ConfirmCards(1-tp,sc1)
		Duel.ConfirmCards(tp,sc2)
		if sc1:GetAttack()==sc2:GetAttack() then
			Duel.SendtoGrave(Group.FromCards(sc1,sc2),REASON_EFFECT)
		else
			if sc1:GetAttack()>sc2:GetAttack() then sc1,sc2=sc2,sc1 end
			Duel.Damage(sc1:GetControler(),500,REASON_EFFECT)
			Duel.SendtoGrave(sc1,REASON_EFFECT)
			Duel.SendtoHand(sc2,nil,REASON_EFFECT)
		end
	end
	Duel.BreakEffect()
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
