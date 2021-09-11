--Elements Unite!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1) 
   
end
s.listed_names={25833572,98434877,62340868,25955164}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Debug.SetPlayerInfo(tp,500,0,Duel.GetDrawCount(tp))
	-- add starting cards
	local gate=Duel.CreateToken(tp,25833572)
	Duel.SendtoHand(gate,tp,REASON_EFFECT)
	for i,code in ipairs({98434877,62340868,25955164}) do
		local tk=Duel.CreateToken(tp,code)
		Duel.MoveToField(tk,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,false,1<<i)
		local e1=Effect.CreateEffect(e:GetHandler()) 
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tk:RegisterEffect(e1)
	end
end