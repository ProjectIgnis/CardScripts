--ジュラシック・インパクト
--Jurassic Impact (anime)
local s,id=GetID()
function s.initial_effect(c)
	--Destroy all monsters on the field and inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g1=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,#g1*1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g2*1000)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function s.filter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsMonster()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Neither player can Normal/Special Summon monsters until the end of the next turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	e1:SetTargetRange(1,1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	--Destroy all monsters and inflict damage per each sent to the GY
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local ct1=og:FilterCount(s.filter,nil,tp)
		local ct2=og:FilterCount(s.filter,nil,1-tp)
		Duel.BreakEffect()
		Duel.Damage(tp,ct1*1000,REASON_EFFECT)
		Duel.Damage(1-tp,ct2*1000,REASON_EFFECT)
	end
end