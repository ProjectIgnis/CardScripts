--ギミック・ボックス
--Gimmick Box
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(function(e,tp) return Duel.GetBattleDamage(tp)>0 or Duel.GetBattleDamage(1-tp)>0 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_NORMAL,-2,0,8,RACE_MACHINE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_NORMAL,-2,0,8,RACE_MACHINE,ATTRIBUTE_DARK) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	c:AddMonsterAttribute(TYPE_NORMAL|TYPE_TRAP)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_ATTACK)
	if Duel.GetBattleDamage(tp)>0 and Duel.GetBattleDamage(1-tp)==0 then
		e2:SetValue(Duel.GetBattleDamage(tp))
	elseif Duel.GetBattleDamage(1-tp)>0 and Duel.GetBattleDamage(tp)==0 then
		e2:SetValue(Duel.GetBattleDamage(1-tp))
	elseif Duel.GetBattleDamage(tp)>0 and Duel.GetBattleDamage(1-tp)>0 then
		e2:SetValue(Duel.GetBattleDamage(tp)+Duel.GetBattleDamage(1-tp))
	end
	e2:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TOFIELD)
	c:RegisterEffect(e2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetBattleDamage(tp)>0 then
		Duel.ChangeBattleDamage(tp,0)
	elseif Duel.GetBattleDamage(1-tp)>0 then
		Duel.ChangeBattleDamage(1-tp,0)
	end
end
