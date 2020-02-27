--Session Draw
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)	
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)	
	e1:SetCountLimit(1)
	if Duel.GetTurnPlayer()==tp and ph==PHASE_DRAW then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.con)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
	end
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(nil,mg,2,2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or Duel.GetCurrentPhase()~=PHASE_DRAW or Duel.GetTurnPlayer()~=tp 
		or (r&REASON_RULE)==0 then return end
	Duel.Hint(HINT_CARD,0,id)
	local tc1=eg:GetFirst()
	local tc2=Duel.GetDecktopGroup(tp,1):GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc1 and tc2 then
		local g=Group.FromCards(tc1,tc2)
		Duel.ConfirmCards(1-tp,g)
		if tc1:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) and tc1:GetLevel()==tc2:GetLevel() then
			local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
			if #xyzg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
				Duel.XyzSummon(tp,xyz,nil,g)
			end
		end
	end
	Duel.ShuffleHand(tp)
end
