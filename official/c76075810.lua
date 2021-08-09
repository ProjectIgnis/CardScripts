--投石部隊
--Throwstone Unit
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.descost)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.descfilter(c)
	return c:IsRace(RACE_WARRIOR)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetAttack())
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.descfilter,1,false,aux.ReleaseCheckTarget,c,dg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.descfilter,1,1,false,aux.ReleaseCheckTarget,c,dg)
	Duel.Release(g,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg-g,1,0,0)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk-1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetAttack()):GetFirst()
	if tc then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
