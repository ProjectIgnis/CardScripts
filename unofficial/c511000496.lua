--亜空間バトル
--Subspace Battle
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Each player reveals 3 monsters in their Deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
    	e2:SetType(EFFECT_TYPE_IGNITION)
    	e2:SetRange(LOCATION_SZONE)
    	e2:SetTarget(s.target)
    	e2:SetOperation(s.operation)
    	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsMonster() and c:GetTextAttack()>=0 and c:IsAbleToHand() and c:IsAbleToGrave() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    	local c=e:GetHandler()
    	local ct=c:GetFlagEffect(id)
    	local cat=e:GetCategory()
    	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) end
    	if ct==2 then
        	cat=cat|CATEGORY_DESTROY
        	e:SetCategory(cat)
        	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
    	end
    	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
    	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_DECK)
    	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffect(id)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_DECK,3,nil)
	if not (b1 and b2) then return end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,3,3,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
	local g2=Duel.SelectMatchingCard(1-tp,s.filter,tp,0,LOCATION_DECK,3,3,nil)
	local exg1=Group.CreateGroup()
	local exg2=Group.CreateGroup()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sc1=g1:Select(tp,1,1,exg1):GetFirst()
		exg1:AddCard(sc1)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
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
	if ct==2 then
        	Duel.Hint(HINT_CARD,0,id)
        	Duel.Destroy(c,REASON_EFFECT)
    	end
end