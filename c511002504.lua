--カードを狩る死神
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_CARD,0,id)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.MoveToField(sc,sc:GetControler(),sc:GetControler(),LOCATION_MZONE,POS_FACEDOWN_DEFENSE,true)
		Duel.BreakEffect()
		if sc:IsControler(tp) then
			Duel.GetControl(sc,1-tp,PHASE_END)
		end
		Duel.ChangeAttackTarget(sc)
	end
end
