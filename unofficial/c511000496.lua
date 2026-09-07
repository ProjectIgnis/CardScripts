--亜空間バトル
--Subspace Battle (anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Each player reveals 3 monsters in their Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.rvlfilter(c)
	return c:IsMonster() and c:GetTextAttack()>=0 and c:IsAbleToHand() and c:IsAbleToGrave() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvlfilter,tp,LOCATION_DECK,0,3,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	local c=e:GetHandler()
	local usages=c:GetFlagEffect(id)
	if usages>=2 then
		local cat=e:GetCategory()
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
	--Each player reveals 3 monsters from their Deck, one at a time (simultaneously)
	local b1=Duel.IsExistingMatchingCard(s.rvlfilter,tp,LOCATION_DECK,0,3,nil)
	local b2=Duel.IsExistingMatchingCard(s.rvlfilter,tp,0,LOCATION_DECK,3,nil)
	if not (b1 and b2) then return end
	--Register a flag to identify the number of times it has been used:
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local your_monsters=Duel.SelectMatchingCard(tp,s.rvlfilter,tp,LOCATION_DECK,0,3,3,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
	local opp_monsters=Duel.SelectMatchingCard(1-tp,s.rvlfilter,tp,0,LOCATION_DECK,3,3,nil)
	local your_exc=Group.CreateGroup()
	local opp_exc=Group.CreateGroup()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local your_card=your_monsters:Select(tp,1,1,your_exc):GetFirst()
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local opp_card=opp_monsters:Select(1-tp,1,1,opp_exc):GetFirst()
		your_monsters:RemoveCard(your_card)
		your_exc:AddCard(your_card)
		opp_monsters:RemoveCard(opp_card)
		opp_exc:AddCard(opp_card)
		Duel.ConfirmCards(1-tp,your_card)
		Duel.ConfirmCards(tp,opp_card)
		--The player who reveals a monster with lower ATK than their opponent's takes 500 damage and sends that card to the Graveyard, while the player who reveals a monster with higher ATK adds that card to their hand (If they have the same ATK, both cards are sent to the Graveyard)
		if your_card:GetAttack()==opp_card:GetAttack() then
			Duel.SendtoGrave(Group.FromCards(your_card,opp_card),REASON_EFFECT)
		else
			if your_card:GetAttack()>opp_card:GetAttack() then
				your_card,opp_card=opp_card,your_card
			end
			Duel.Damage(your_card:GetControler(),500,REASON_EFFECT)
			Duel.SendtoGrave(your_card,REASON_EFFECT)
			Duel.SendtoHand(opp_card,nil,REASON_EFFECT)
		end
	end
	--After this effect is used 3 times, destroy this card
	local usages=c:GetFlagEffect(id)
	if usages==3 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Destroy(c,REASON_EFFECT)
	end
end