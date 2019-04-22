--煉獄の落とし穴
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAttackAbove(2000) and c:GetSummonPlayer()==tp and not c:IsDisabled()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:IsExists(s.filter,1,nil,1-tp) end
	Duel.SetTargetCard(eg)
	local g=eg:Filter(s.filter,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.filter2(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAttackAbove(2000)
		and c:GetSummonPlayer()==tp and c:IsRelateToEffect(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if not tc:IsDisabled() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		Duel.AdjustInstantly()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		if tc:IsImmuneToEffect(e1) then return end
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
