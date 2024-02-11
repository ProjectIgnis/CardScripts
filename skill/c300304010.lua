--Looking into the Future
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
function s.chainfilter(re,ep,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect())
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and not Duel.HasFlagEffect(tp,id) and Duel.GetCustomActivityCount(id,ep,ACTIVITY_CHAIN)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Look at the top 3 cards of your deck and rearrange them
	Duel.SortDecktop(tp,tp,3)
	--OPT register
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--Cannot activate Spell Cards for the rest of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Flip this card during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetOperation(function(e,tp) Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32)) end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
