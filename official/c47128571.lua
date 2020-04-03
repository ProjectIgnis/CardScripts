--報復の隠し歯
--Hidden Fangs of Revenge
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_ONFIELD)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE) and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttackBelow,c:GetDefense()),tp,0,LOCATION_MZONE,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,2,nil)
	if #dg~=2 or Duel.Destroy(dg,REASON_EFFECT)~=2 or not Duel.NegateAttack() then return end
	local og=Duel.GetOperatedGroup()
	if og:IsExists(s.filter,1,nil,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tc=og:FilterSelect(tp,s.filter,1,1,nil,tp):GetFirst()
		local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsAttackBelow,tc:GetDefense()),tp,0,LOCATION_MZONE,nil)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			local turnp=Duel.GetTurnPlayer()
			Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
			Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
		end
	end
end
