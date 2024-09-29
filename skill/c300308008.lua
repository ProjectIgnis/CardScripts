--Dig Site Inspection
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--Flip this card over at the start of the Duel
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
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Choose to excavate the top card of your Deck, then place it on the top or bottom
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.GetFlagEffect(tp,id)<2 end)
	e1:SetOperation(s.excavop)
	Duel.RegisterEffect(e1,tp)
	--Flip this Skill over if you've place a 2nd card with this effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.GetFlagEffect(tp,id)==2 end)
	e2:SetOperation(function(_,tp) Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32)) end) 
	Duel.RegisterEffect(e2,tp)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.ConfirmDecktop(tp,1)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	if op==0 then 
		Duel.MoveSequence(tc,0)
	elseif op==1 then
		Duel.MoveSequence(tc,1)
		Duel.RegisterFlagEffect(tp,id,0,0,0)
	end
end

	