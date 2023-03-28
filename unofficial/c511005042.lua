--地獄大百足 (Manga)
--Hundred-Footed Horror (Manga)
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x567)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return c:GetLevel()>4
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end