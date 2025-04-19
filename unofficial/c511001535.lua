--ヘイル・サイバー
--Cyber Valkyrie
local s,id=GetID()
function s.initial_effect(c)
	--ATK change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	e1:SetValue(-300)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.atktg(e,c)
	return Duel.GetAttacker()==c and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsCode(id)
end