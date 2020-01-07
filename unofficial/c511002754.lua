--Spirit Foresight
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and #eg>1 and tp~=ep
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=#eg-1
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Select(tp,1,1,nil)
	local g=eg:Clone()
	g:Sub(sg)
	Duel.NegateSummon(g)
	Duel.Draw(tp,#g,REASON_EFFECT)
end
