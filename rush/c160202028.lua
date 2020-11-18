--Cat's Eyes
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsRace,RACE_BEAST),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)==3 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	local tc=Duel.GetOperatedGroup():GetFirst()
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)>0 then
		if (e:GetLabel()==0 and tc:IsType(TYPE_MONSTER)) or (e:GetLabel()==1 and tc:IsType(TYPE_SPELL)) or (e:GetLabel()==2 and tc:IsType(TYPE_TRAP)) then 
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
			local tc=g:GetFirst()
			for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end