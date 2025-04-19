--Ｅ・ＨＥＲＯ シャイニング・フレア・ウィングマン
--Elemental HERO Shining Flare Wingman (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:AddMustBeFusionSummoned()
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,35809262,20721928)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkup)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.atkup(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_WARRIOR)*300
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsLocation(LOCATION_GRAVE) then
		local atk=bc:GetTextAttack()
		if bc:WasMaximumMode() then
			atk=bc:GetMaximumAttack()
		end
		if atk>0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end