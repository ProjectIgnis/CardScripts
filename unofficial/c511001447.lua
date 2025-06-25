--セッション・ドロー
--Session Draw
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 extra card during your next Draw Phase, then Xyz Summon 1 Xyz Monster if both drawn cards are monsters with the same Level
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1)
	if Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_DRAW) then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
		e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,1)
	end
	e1:SetOperation(s.drawxyzop)
	Duel.RegisterEffect(e1,tp)
end
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(nil,mg,2,2)
end
function s.drawxyzop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not Duel.IsPhase(PHASE_DRAW) or not Duel.IsTurnPlayer(tp)
		or (r&REASON_RULE)==0 then return end
	Duel.Hint(HINT_CARD,0,id)
	local tc1=eg:GetFirst()
	local tc2=Duel.GetDecktopGroup(tp,1):GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc1 and tc2 then
		local mg=Group.FromCards(tc1,tc2)
		Duel.ConfirmCards(1-tp,mg)
		if tc1:IsMonster() and tc2:IsMonster() and tc1:GetLevel()==tc2:GetLevel() then
			local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
			if #xyzg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
				Duel.XyzSummon(tp,xyz,mg,mg,2,2)
			end
		end
	end
	Duel.ShuffleHand(tp)
end
