--真紅眼の凶星竜－メテオ・ドラゴン
--Meteor Dragon Red-Eyes Impact
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Other "Red-Eyes" monsters cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RED_EYES}
function s.indtg(e,c)
	return c:IsSetCard(SET_RED_EYES) and c~=e:GetHandler()
end