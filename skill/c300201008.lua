--Mind Scan
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==3 and Duel.GetLP(tp)>=3000
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Ask if you want to activate this Skill
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Flag registration for active Skill
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--You can look at your opponent's Set Spell/Traps at any time
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(0x5f)
	e1:SetCondition(function(e) return Duel.HasFlagEffect(e:GetHandlerPlayer(),id) and Duel.GetLP(e:GetHandlerPlayer())>=3000 end)
	e1:SetTargetRange(0,LOCATION_SZONE)
	Duel.RegisterEffect(e1,tp)
	--If your LP fall below 3000, flip this card face-down.
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetCondition(function(e,tp) return Duel.HasFlagEffect(tp,id) and Duel.GetLP(tp)<3000 end)
	e2:SetOperation(s.flipdownop)
	Duel.RegisterEffect(e2,tp)
end
function s.flipdownop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	Duel.ResetFlagEffect(tp,id)
end
