--狡猾な落とし穴
--Treacherous Trap Hole (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) and not Duel.IsExistingMatchingCard(Card.IsTrap,tp,LOCATION_GRAVE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(aux.TRUE),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>1 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(aux.TRUE),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,2,2,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end