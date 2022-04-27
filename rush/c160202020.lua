--量子ホール
--Quantum Hole

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Draw 2 card, then return 2 cards from hand to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--If your cyberse monster was destroyed by opponent's attack
function s.filter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_CYBERSE~=0 and (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
	--If it ever happened
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
	--Draw 2 card, then return 2 cards from hand to the deck
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.Draw(tp,2,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
		Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		Duel.SortDeckbottom(tp,tp,#dg)
	end
end