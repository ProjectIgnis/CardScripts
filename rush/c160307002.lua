-- 星戦騎アスボロス
-- Star Battle Knight Asbolus
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Make a monster on the field gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcostfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_FIEND)
		and c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local cg=Duel.SelectMatchingCard(tp,s.atkcostfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #cg>0 and Duel.ChangePosition(cg,POS_FACEUP_DEFENSE)==#cg then
		-- Effect
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			-- ATK increase
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffectRush(e1)
		end
	end
end
