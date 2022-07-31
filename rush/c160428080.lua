--呪いのファンレター
--Frightening Fan Mail
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
end
function s.posfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAttackPos() and c:IsType(TYPE_NORMAL) and c:IsCanChangePosition() and c:IsFaceup()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.defposfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsPosition(POS_FACEUP_DEFENSE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	local res=0
	if #g>0 then
		res=Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
	if res~=#g or res==0 then return end --if at least 1 was not changed, the cost was not paid, right?
	--Effect
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local mct=Duel.GetMatchingGroupCount(s.defposfilter,tp,LOCATION_MZONE,0,nil)
	local ct=math.min(mct,#hg)
	if ct==0 then return end
	local total=Duel.AnnounceNumberRange(tp,1,ct)
	local tg=hg:RandomSelect(tp,total)
	if Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		--Inflict 300 Damage per card sent
		if og>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,og*300,REASON_EFFECT)
		end
	end
end