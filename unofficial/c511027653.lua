--次元均衡
--Dimension Equilibrium (Anime) 
--Made by Mirror Imagine Catadioptricker 7
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
	return c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,e,tp,r,rp)
	local sp=g:GetFirst()
	local rc=sp:GetReasonCard()
	if chk==0 then return rc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g3=Group.FromCards(rc,g:GetFirst())
	Duel.SetTargetCard(g3)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g:GetFirst(),1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=eg:Filter(s.cfilter,nil,e,tp,r,rp)
	local sp=g:GetFirst()
	local rc=sp:GetReasonCard()
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	Duel.BreakEffect()
	if sp:IsRelateToEffect(e) then
		Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
	end
	if rc:IsRelateToEffect(e) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end	