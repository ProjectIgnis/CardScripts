--闇の侯爵ベリアル
--Belial - Marquis of Darkness
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent cannot target any face-up monster you control, except "Belial - Marquis of Darkness", for an attack, or with Spell/Trap effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(0,LOCATION_MZONE)
	e1a:SetValue(function(e,c) return c:IsFaceup() and not c:IsCode(id) end)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetTargetRange(LOCATION_MZONE,0)
	e1b:SetTarget(function(e,c) return c:IsFaceup() and not c:IsCode(id) end)
	e1b:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() and re:IsSpellTrapEffect() end)
	c:RegisterEffect(e1b)
end
s.listed_names={id}