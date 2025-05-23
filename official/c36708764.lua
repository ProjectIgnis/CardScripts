--ルーレット・スパイダー
--Roulette Spider
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local at=Duel.GetAttacker()
	Duel.SetTargetCard(at)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.TossDice(tp,1)
	if dc==1 then
		local lp=Duel.GetLP(tp)
		Duel.SetLP(tp,math.ceil(lp/2))
		return
	elseif dc==2 then
		Duel.ChangeAttackTarget(nil)
		return
	elseif dc==3 then
		local bc=Duel.GetAttackTarget()
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,bc)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
			local tc=g:Select(tp,1,1,nil):GetFirst()
			local at=Duel.GetAttacker()
			if at:CanAttack() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				Duel.CalculateDamage(at,tc)
			end
		end
		return
	elseif dc==4 then
		local at=Duel.GetAttacker()
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,at)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			local at=Duel.GetAttacker()
			if at:CanAttack() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				Duel.CalculateDamage(at,tc)
			end
		end
		return
	elseif dc==5 then
		local at=Duel.GetFirstTarget()
		if at and at:IsRelateToEffect(e) and Duel.NegateAttack() and at:GetAttack()>0 then
			Duel.Damage(1-tp,at:GetAttack(),REASON_EFFECT)
		end
		return
	else
		local at=Duel.GetFirstTarget()
		if at and at:IsRelateToEffect(e) and at:IsControler(1-tp) and at:IsMonster() then
			Duel.Destroy(at,REASON_EFFECT)
		end
	end
end