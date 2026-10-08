--鉄壁氷山－ディフェンドアイスバーグ－
--Defender Iceberg
local s,id=GetID()
local RACES_AQUA_FISH_SEASERPENT=RACE_AQUA|RACE_FISH|RACE_SEASERPENT
function s.initial_effect(c)
	--As long as "Defender Iceberg" remains face-up on the field, all other Aqua, Fish, and Sea Serpent-Type monsters cannot be selected as an attack target. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsRace(RACES_AQUA_FISH_SEASERPENT) and not c:IsCode(id) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If the ATK of a monster that attacks a Defense Position Defender Iceberg is lower than the DEF of Defender Iceberg, damage calculation is not applied.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.nodamcon)
	e2:SetOperation(s.nodamop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.nodamcon(e)
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	local p=a:GetControler()
	local acatk,atdef=a:GetAttack(),at:GetDefense()
	return a and Duel.GetBattleDamage(p)>0 and at and at:IsDefensePos() and at:IsCode(id) and atdef>acatk
end
function s.nodamop(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	local p=a:GetControler()
	local acatk,atdef=a:GetAttack(),at:GetDefense()
	if a and at and at:IsDefensePos() and at:IsCode(id) and atdef>acatk then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetLabel(p)
		e1:SetOperation(s.damop)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	if Duel.GetBattleDamage(p)>0 then
		Duel.ChangeBattleDamage(p,0)
	end
end
