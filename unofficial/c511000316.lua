--魔人の落とし穴
--Fiendish Trap Hole
local s,id=GetID()
function s.initial_effect(c)
	--Destroyed 1 monster Special Summoned via card effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if #eg==1 then
		local tc=eg:GetFirst()
		Duel.HintSelection(tc)
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=eg:Select(tp,1,1,nil)
		local tc=g:GetFirst()
		Duel.HintSelection(tc)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
