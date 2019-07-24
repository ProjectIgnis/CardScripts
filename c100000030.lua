--次元均衡
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE) and c~=Duel.GetAttacker() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	 and a:IsCanBeEffectTarget(e) end
	local g=Group.FromCards(a,tc)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,a,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	if tg1:GetFirst():IsRelateToEffect(e) then
		Duel.SpecialSummon(tg1,0,tp,tp,false,false,POS_FACEUP)
	end
	if tg2:GetFirst():IsRelateToEffect(e) then
		Duel.Remove(tg2,POS_FACEUP,REASON_EFFECT)
	end
end
