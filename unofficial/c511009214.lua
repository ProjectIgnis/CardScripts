--メタル・リフレクト・スライム (Anime)
--Metal Reflect Slime (Anime)
--Scripted by eclair11
--Re-scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetAttacker():IsControler(1-tp)
		and Duel.GetBattleDamage(ep)>=(Duel.GetLP(tp)+Duel.GetBattleDamage(ep))/2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,e:GetHandler():Alias(),0,0x21,0,Duel.GetAttacker():GetAttack()*3/4,10,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToBattle() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,e:GetHandler():Alias(),0,0x21,0,tc:GetAttack()*3/4,10,RACE_AQUA,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(tc:GetAttack()*3/4)
	c:RegisterEffect(e2)
	Duel.SpecialSummonComplete()
end