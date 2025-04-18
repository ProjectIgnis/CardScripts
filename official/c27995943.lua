--Dr.フランゲ
--Dr. Frankenderp
local s,id=GetID()
function s.initial_effect(c)
	--Look at the top card from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.PayLP(500))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)
	Duel.ConfirmCards(tp,g)
	local b1=g:GetFirst():IsAbleToHand()
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,1)},
		{b1,aux.Stringid(id,2)})
	if op==1 then
		Duel.MoveSequence(g:GetFirst(),1)
	else
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		if Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_DRAW) then
			e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN)
		end
		Duel.RegisterEffect(e1,tp)
	end
end