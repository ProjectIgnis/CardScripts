--Ｅ・ＨＥＲＯ フレイム・ウィングマン
--Elemental HERO Flame Wingman (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:AddMustBeFusionSummoned()
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,21844576,58932615)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
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