--翻弄するエルフの剣士
--Obnoxious Celtic Guard
local s,id=GetID()
function s.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
end
function s.indes(e,c)
	return c:GetAttack()>=1900
end
