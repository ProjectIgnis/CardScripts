--強欲で謙虚な壺
--Pot of Duality
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 3 cards of your Deck, add 1 of them to your hand, also, after that, shuffle the rest back into your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon during the turn you activate this card
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetDecktopGroup(tp,3)
		return #g==3 and g:IsExists(Card.IsAbleToHand,1,nil)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local affected_player=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local decktop3=Duel.GetDecktopGroup(affected_player,3)
	if #decktop3==0 then return end
	Duel.ConfirmDecktop(affected_player,3)
	local hint=HINTMSG_ATOHAND
	local filter=Card.IsAbleToHand
	if not decktop3:IsExists(Card.IsAbleToHand,1,nil) then
		hint=HINTMSG_TOGRAVE
		filter=aux.TRUE
	end
	Duel.Hint(HINT_SELECTMSG,affected_player,hint)
	local sc=decktop3:FilterSelect(affected_player,filter,1,1,nil):GetFirst()
	if sc:IsAbleToHand() then
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-affected_player,sc)
		Duel.ShuffleHand(affected_player)
	else
		Duel.SendtoGrave(sc,REASON_RULE)
	end
	Duel.BreakEffect()
	Duel.ShuffleDeck(affected_player)
end