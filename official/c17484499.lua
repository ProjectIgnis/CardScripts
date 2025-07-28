--現世と冥界の逆転
--Exchange of the Spirit
local s,id=GetID()
function s.initial_effect(c)
	--Each player swaps the cards in their GY with the cards in their Deck, then shuffles their Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=15 and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=15 end)
	e1:SetCost(Cost.PayLP(1000))
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				local turn_player=Duel.GetTurnPlayer()
				Duel.SwapDeckAndGrave(turn_player)
				Duel.SwapDeckAndGrave(1-turn_player)
			end)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E|TIMING_CHAIN_END)
	c:RegisterEffect(e1)
end