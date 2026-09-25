--ダウンバースト
--Down Burst
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
function s.setfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsCanTurnSet() and not c:IsType(TYPE_PENDULUM)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_ONFIELD,nil)
	for tc in g:Iter() do
		tc:CancelToGrave()
		Duel.ChangePosition(tc,POS_FACEDOWN)
		tc:SetStatus(STATUS_SET_TURN,false)
	end
	Duel.RaiseEvent(g,EVENT_SSET,e,REASON_EFFECT,1-tp,tp,0)
end
