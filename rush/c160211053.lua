--ラヴ・ミリオン
--Love Million
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent monster's attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_FAIRY) and tc:GetBaseAttack()==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsControler(1-tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	local tc=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000000)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsDefense,0),tp,LOCATION_MZONE,0,1,nil) and d and d:IsRelateToBattle() and d:IsFaceup() then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(100)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		d:RegisterEffect(e2)
	end
end