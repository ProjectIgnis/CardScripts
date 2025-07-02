--ＳＮｏ．３９ 希望皇ホープＯＮＥ
--Number S39: Utopia Prime
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 LIGHT monsters OR 1 "Number 39: Utopia" you control
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),4,3,s.ovfilter,aux.Stringid(id,0))
	--Destroy as many Special Summoned monsters your opponent controls as possible, and if you do, banish them, then inflict 300 damage to your opponent for each monster banished
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp) return Duel.GetLP(1-tp)>=Duel.GetLP(tp)+3000 end)
	e1:SetCost(Cost.AND(Cost.Detach(3),Cost.PayLP(10,true)))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.xyz_number=39
s.listed_names={84013237} --"Number 39: Utopia"
function s.ovfilter(c,tp,lc)
	return c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,84013237) and c:IsFaceup()
end
function s.desfilter(c)
	return c:IsSpecialSummoned() and c:IsAbleToRemove()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*300)
end
function s.rmctfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)>0 then
		local ct=Duel.GetOperatedGroup():FilterCount(s.rmctfilter,nil)
		if ct>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end