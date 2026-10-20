--Ｅ－ＨＥＲＯ インフェルノ・ウィング (Rush)
--Evil HERO Inferno Wing (Rush)
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Elemental HERO Avian" + "Elemental HERO Burstinatrix"
	Fusion.AddProcMix(c,true,true,21844576,58932615) 
	--Must be Special Summoned by the effect of "Dark Fusion" or "Super Polymerization".
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--This card inflicts piercing battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--If this card destroys a monster by battle and sends it to the Graveyard, inflict damage to your opponent equal to [that monster's original ATK or DEF (whichever is higher)]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}
s.listed_names={CARD_DARK_FUSION,CARD_SUPER_POLYMERIZATION,58932615,21844576}
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(CARD_DARK_FUSION,CARD_SUPER_POLYMERIZATION)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsLocation(LOCATION_GRAVE) then
		local dam=bc:GetTextAttack()
		if bc:WasMaximumMode() then
			dam=bc:GetMaximumAttack()
		end
		if dam<bc:GetTextDefense() and not bc:WasMaximumMode() then dam=bc:GetTextDefense() end
		if dam>0 then
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end