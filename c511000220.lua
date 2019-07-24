--Chaos Barrier Field (ANIME)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,2,nil,POS_FACEUP_ATTACK)
end
function s.filter(c)
	return c:IsAttackPos()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,2,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
	local g2=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
	if #g1==0 or #g2==0 then return end
	local ga=g1:GetMaxGroup(Card.GetAttack)
	local gd=g2:GetMinGroup(Card.GetAttack)
	if #ga>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		ga=ga:Select(tp,1,1,nil)
	end
	if #gd>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		gd=gd:Select(tp,1,1,nil)
	end
	Duel.NegateAttack()
	Duel.GetControl(gd,tp,PHASE_END,1)
	if Duel.GetControl(gd,tp,PHASE_END,1) then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)	
	Duel.CalculateDamage(ga:GetFirst(),gd:GetFirst())
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
end
end
