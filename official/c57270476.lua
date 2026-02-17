--墓場からの誘い
--Grave Lure
local s,id=GetID()
function s.initial_effect(c)
	--Turn the top card of your opponent's Deck face-up, then your opponent shuffles their Deck. When your opponent draws the face-up card, immediately send it to the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	local top_c=Duel.GetDecktopGroup(opp,1):GetFirst()
	if not top_c then return end
	Duel.ConfirmDecktop(opp,1)
	top_c:ReverseInDeck()
	Duel.ShuffleDeck(opp)
	local c=e:GetHandler()
	--If the opponent draws that card, it is sent to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(
		function()
			if not Duel.IsChainSolving() then
				Duel.Hint(HINT_CARD,0,id)
				Duel.SendtoGrave(top_c,REASON_EFFECT,PLAYER_NONE,tp)
			else
				--If it's drawn while resolving a Chain, send it to the GY at the end of the Chain Link
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_CHAIN_SOLVED)
				e2:SetRange(LOCATION_HAND)
				e2:SetOperation(function() Duel.Hint(HINT_CARD,0,id) Duel.SendtoGrave(top_c,REASON_EFFECT,PLAYER_NONE,tp) e2:Reset() end)
				e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOHAND)|RESET_CHAIN)
				top_c:RegisterEffect(e2)
			end
		end)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOHAND))
	top_c:RegisterEffect(e1)
end