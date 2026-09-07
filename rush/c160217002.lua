--叛骨装剣ガイガスベルグ
--Sphraruda the Defiant Soulclad Scripture
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual monster
	c:EnableReviveLimit()
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:GetOriginalRace()==RACE_ZOMBIE
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker():GetBattleTarget()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	if bc and bc:IsLocation(LOCATION_GRAVE) and #g>0 then
		local sg=g:GetMaxGroup(Card.GetLevel)
		local lvl=sg:GetFirst():GetLevel()
		if lvl>0 then
			Duel.Damage(1-tp,lvl*200,REASON_EFFECT)
		end
	end
end
function s.indcon(e)
	return e:GetHandler():IsDefensePos() and Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,160018031)
end