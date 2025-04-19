--仲裁の代償
--Compensation Mediation
local s,id=GetID()
function s.initial_effect(c)
	--Place this card and 2 cards from your opponent's GY on their field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_GRAVE,2,nil) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>2 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,2,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_GRAVE,nil)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=2 or #g<2 then return end
	if #g>1 then
		local sg=g:Select(1-tp,2,2,nil)
		sg:AddCard(c)
		local tc=sg:GetFirst()
		while tc do
			Duel.MoveToField(tc,tp,1-tp,LOCATION_MZONE,POS_FACEDOWN_ATTACK,true)
			tc=sg:GetNext()
		end
		Duel.ShuffleSetCard(sg)
		local rsel=sg:RandomSelect(tp,1)
		Duel.ConfirmCards(tp,rsel)
		Duel.ConfirmCards(1-tp,rsel)
		if rsel:IsContains(c) then
			if Duel.IsTurnPlayer(tp) then
				Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
				sg:RemoveCard(c)
				Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
				Duel.SendtoGrave(c,REASON_EFFECT)
			else
				Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
				sg:RemoveCard(c)
				Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
				Duel.SendtoGrave(c,REASON_EFFECT)
			end
		else
			sg:RemoveCard(rsel+c)
            		Duel.SendtoGrave(rsel+c,REASON_EFFECT)
            		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
	
end