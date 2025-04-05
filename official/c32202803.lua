--武神器－タルタ
--Bujingi Wolf
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function s.indtg(e,c)
	return c~=e:GetHandler() and c:IsRace(RACES_BEAST_BWARRIOR_WINGB)
end