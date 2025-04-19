--虎死眈々
--Tiger Glare
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change opponent's attacking monster to defense position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.zfilter(c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR|RACE_BEAST) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsCanChangePositionRush() and Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsControler(1-tp) and at:IsAttackPos() and at:IsOnField() and at:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,at,1,0,0)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local at=Duel.GetAttacker()
	if at and at:IsAttackPos() and at:IsRelateToBattle() and Duel.ChangePosition(at,POS_FACEUP_DEFENSE)>0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		if Duel.GetLP(tp)<=Duel.GetLP(1-tp) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			if #sg==0 then return end
			Duel.HintSelection(sg,true)
			Duel.BreakEffect()
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				Duel.Damage(1-tp,sg:GetFirst():GetTextAttack(),REASON_EFFECT)
			end
		end
	end
end

