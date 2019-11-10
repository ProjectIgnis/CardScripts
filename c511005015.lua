--Sneak Attack
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.CanAttack,tp,LOCATION_MZONE,0,1,nil) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(Card.CanAttack,tp,LOCATION_MZONE,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,524)
	local ac=Duel.SelectMatchingCard(tp,Card.CanAttack,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local tc=nil
	local tg_ok=Duel.IsExistingMatchingCard(Card.IsCanBeBattleTarget,tp,0,LOCATION_MZONE,1,nil,ac)
	local direct_ok=false
	if ac:IsHasEffect(EFFECT_DIRECT_ATTACK) or not tg_ok then
		direct_ok=Duel.SelectYesNo(tp,31)
	end
	if direct_ok then
		Duel.Damage(1-tp,ac:GetAttack(),REASON_BATTLE)
	elseif tg_ok then
		Duel.Hint(HINT_SELECTMSG,tp,525)
		tc=Duel.SelectMatchingCard(tp,Card.IsCanBeBattleTarget,tp,0,LOCATION_MZONE,1,1,nil,ac):GetFirst()
		Duel.CalculateDamage(ac,tc)
	end
end