--Moth to the Flame
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={58192742,40240595,87756343,14141448,48579379}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0
end
function s.eqfilter(c,tp)
	return c:IsCode(40240595) and c:GetEquipTarget():IsCode(58192742) and c:GetEquipTarget():IsControler(tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Turn counts forward
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(0x5f)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
	--Add cards
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(0x5f)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetCountLimit(1)
	e2:SetLabel(0)
	e2:SetCondition(s.thcon)
	e2:SetOperation(s.thop)
	Duel.RegisterEffect(e2,tp) 
end
function s.con(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_SZONE,0,nil,tp)
	if #g==0 then return end
	 for tc in aux.Next(g) do
		tc:SetTurnCounter(tc:GetTurnCounter()+1)
	end
end
function s.thcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_SZONE,0,nil,tp)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and #g>0
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		local tc1=Duel.CreateToken(tp,87756343)
		Duel.SendtoHand(tc1,tp,REASON_EFFECT)
		e:SetLabel(1)
	elseif e:GetLabel()==1 then
		local tc2=Duel.CreateToken(tp,14141448)
		Duel.SendtoHand(tc2,tp,REASON_EFFECT)
		e:SetLabel(2)
	elseif e:GetLabel()==2 and c:GetFlagEffect(id)==0 then
		local tc3=Duel.CreateToken(tp,48579379)
		Duel.SendtoHand(tc3,tp,REASON_EFFECT)
		c:RegisterFlagEffect(id,0,0,0)
	end
end