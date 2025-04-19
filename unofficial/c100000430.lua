--地縛解放
--Earthbound Release
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={SET_EARTHBOUND_IMMORTAL}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,aux.ReleaseCheckTarget,nil,dg,SET_EARTHBOUND_IMMORTAL) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,aux.ReleaseCheckTarget,nil,dg,SET_EARTHBOUND_IMMORTAL)
	Duel.Release(g,REASON_COST)
end
function s.filter(c,p)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsControler(p)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,1-tp) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	local dam=g:GetSum(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
		local dam=Duel.GetOperatedGroup():GetSum(Card.GetPreviousAttackOnField)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end