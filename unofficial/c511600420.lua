--グランエルＡ (TF5)
--Granel Attack (TF5)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--selfdes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(s.sdcon)
	c:RegisterEffect(e1)
	--chain attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.cacon)
	e2:SetOperation(s.caop)
	c:RegisterEffect(e2)
end
s.listed_series={0x562}
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsInfinity),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.cacon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and d:IsPreviousPosition(POS_DEFENSE) and a:IsControler(tp) and a:IsInfinity() and a:CanChainAttack()
end
function s.caop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if tc and tc:IsFaceup() and tc:IsRelateToBattle() and tc:CanChainAttack() then
		Duel.ChainAttack()
	end
end