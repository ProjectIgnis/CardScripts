--千手遊び
--Finger Game
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Each player places 2 cards from their Deck on top of their Deck in any order, then they declare a number from 0 to 4, then they excavate the top 2 cards of their Deck. The player(s) whose declared number is the same as the number of monsters among all 4 excavated cards adds 1 of their excavated cards to their hand, also they place the other on the bottom of their Deck. The player(s) whose declared number is not the same places their excavated cards on the bottom of their Deck in any order. You can only activate 1 "Finger Game" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.select_cards(player)
	Duel.Hint(HINT_SELECTMSG,player,HINTMSG_TODECK)
	local selected_cards=Duel.SelectMatchingCard(player,nil,player,LOCATION_DECK,0,2,2,nil)
	Duel.ShuffleDeck(player)
	Duel.MoveToDeckTop(selected_cards)
	return selected_cards
end
function s.compare_numbers(declared_number,monster_count,selected_cards,player)
	if declared_number==monster_count then
		local hint=HINTMSG_ATOHAND
		local filter=Card.IsAbleToHand
		if not selected_cards:IsExists(Card.IsAbleToHand,1,nil) then
			hint=HINTMSG_TOGRAVE
			filter=aux.TRUE
		end
		Duel.Hint(HINT_SELECTMSG,player,hint)
		local sc=selected_cards:FilterSelect(player,filter,1,1,nil):GetFirst()
		Duel.DisableShuffleCheck()
		if sc:IsAbleToHand() then
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			Duel.ShuffleHand(player)
		else
			Duel.SendtoGrave(sc,REASON_RULE)
		end
		Duel.MoveToDeckBottom(selected_cards-sc)
	else
		Duel.MoveToDeckBottom(selected_cards)
		Duel.SortDeckbottom(player,player,2)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<2 then return end
	local opp=1-tp
	local your_cards=s.select_cards(tp)
	local oppo_cards=s.select_cards(opp)
	Duel.BreakEffect()
	local your_number=Duel.AnnounceNumberRange(tp,0,4)
	local oppo_number=Duel.AnnounceNumberRange(opp,0,4)
	Duel.BreakEffect()
	Duel.ConfirmDecktop(tp,2)
	Duel.ConfirmDecktop(opp,2)
	local monster_count=(your_cards+oppo_cards):FilterCount(Card.IsMonster,nil)
	s.compare_numbers(your_number,monster_count,your_cards,tp)
	s.compare_numbers(oppo_number,monster_count,oppo_cards,opp)
end