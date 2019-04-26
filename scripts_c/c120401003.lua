--セイント・ファイアー・ギガ
--Fearsome Fire Blast
--Scripted by Eerie Code
function c120401003.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c120401003.condition)
	e1:SetOperation(c120401003.activate)
	c:RegisterEffect(e1)
end
function c120401003.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsSetCard(0x64)
end
function c120401003.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c120401003.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c120401003.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--double damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(c120401003.damcon)
	e1:SetOperation(c120401003.damop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetValue(math.floor(tc:GetAttack()/2))
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e3:SetValue(math.floor(tc:GetDefense()/2))
		tc:RegisterEffect(e3)
	end
end
function c120401003.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsSetCard(0x64) and tc:GetBattleTarget()~=nil
end
function c120401003.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end
