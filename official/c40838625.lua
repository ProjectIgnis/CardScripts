--砂塵のバリア －ダスト・フォース－
--Quaking Mirror Force

local s,id=GetID()
function s.initial_effect(c)
	--When opponent's monster declares an attack, change all of their attack position monsters to face-down defense position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c)
	return c:IsAttackPos() and c:IsCanTurnSet()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		for tc in aux.Next(og) do
			--Cannot change their battle positions
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3313)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end