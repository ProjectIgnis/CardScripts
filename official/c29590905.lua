--スーパージュニア対決！
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_DEFENSE) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
	local g2=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
	if #g1==0 or #g2==0 then return end
	local ga=g1:GetMinGroup(Card.GetAttack)
	local gd=g2:GetMinGroup(Card.GetDefense)
	if #ga>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		ga=ga:Select(tp,1,1,nil)
	end
	if #gd>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		gd=gd:Select(tp,1,1,nil)
	end
	Duel.NegateAttack()
	local a=ga:GetFirst()
	local d=gd:GetFirst()
	if a:CanAttack() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then 
		Duel.CalculateDamage(a,d)
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end
