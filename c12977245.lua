--オルターガイスト・フィフィネラグ
--Altergeist Fifinellag
--anime version scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--cannot target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.imtg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.imtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
s.listed_series={0x103}
s.listed_names={id}
function s.imtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x103) and not c:IsCode(id)
end

